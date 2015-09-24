---
tags: scala akka
---

Recently I needed to cache some lightweight data into actor's local memory to
not make unnecessary calls to third party service over the internet. I think what I
came up with is a pretty simple implementation (hence I named the article
simple caching in akka). But the idea can be expended with small changes
if any to use it to cache actor messages. Let's imagine the word of actors where
we have one actor per user and we send messages to user actors to get some info
back. Now when we say each user (actor) is responsible to cache it's own data
it means each actor will use even more memory so at some point we'll need to
scale out because we'll run out of memory (not that we didn't have that
problem without cache at first place). But it's a good thing that we know we
need to scale out from the beginning because I didn't mention about high
availability yet, so we at least need two boxes.

<!--more-->

Pros of caching result in actor's own memory is one
it's gonna be fast and more reliable since it doesn't have to go to a
centralize cache box over the network, and do you even wanna have to manage
boxes for cache and write all that boilerplate code to read and write to cache.
But of course not everything is as simple as it seems to be. With caching in
memory we're still left with at least two historical problems, how to invalidate
cache when you have more than one instance running and other problem is
big cache means big memory and big memory is big heap that GC need
to manage, so at some point you'll at very least have to spin up visual jvm or
turn on GC log or whatever you prefer to see what the heck is going on under
the hood, not even talking about trying to tune GC.

So how does akka help with those problems. What if we don't have same
user actor run on more than one box like we usually do with traditional
architecture. We're used to running same code on more than one box and
there we get both hight availability and that's how we scale out. But
having user A run on a single box do we have high availability problem?
What if that box goes down. Since we designed it in a way where we have all
those small actors,
one per user in this case, we can spread those across many boxes and if one
goes down we'll just start actors what were running on that box on the boxes
that or online, akka clustering so to speak. So this idea should take as pretty
far in theory. Let's dive deep to see how it's simple.

We well start by writing our user actor. As I mentioned we're gonna create one
actor per user. Let's make *userId* a constructor parameter so actor knows it's
id. Also let's say that is there is a data actor we can send
*GetUserData(userId)* to get user data and
*GetUserCredits(userId)* message to get user
credits. In real world this would be like a web service or if this data comes
form DB it would make more sense to let user actor manage it's data also.
But this should be good for the demo.

### DataActor

{% gist yeghishe/453e1557e78b707efe58 %}

Data actor is simple, user N will have userN user name and N credits.

### UserActor

{% gist yeghishe/b8861d848ff11f3bb2ac %}

User actor will take *GetUserData* and *GetUserCredits* case object as
messages. Let's say credits is really important and we don't want to cache it
ever but we do want to cache user data. The normal way to send that data back
would be to do this:

{% highlight scala %}
  dataActorRef.ask(DataActor.GetUserData(userId)).pipeTo(self)(sender())
{% endhighlight %}

For caching we're doing this:

{% highlight scala %}
  cacheAndRespond(msg, dataActorRef ? DataActor.GetUserData(userId))
{% endhighlight %}

For just responding without caching:

{% highlight scala %}
  respond(dataActorRef ? DataActor.GetUserCredits(userId))
{% endhighlight %}

As you can see it can't get simpler than this, it's actually a shorter syntax.


Let's prove that this is actually working. And what is a better way to do it
than write unit tests? There are few cases we want to test:

* If cache is enabled first time we send *GetUserData* message to user actor
  it will call data actor to get the data but next time it won't.
  We'll have a configuration option to tell as for how long to
  cache, when it's set to zero we say cache is disabled for whole actor.
* If cache is disabled first time we send *GetUserData* it will call data
  actor and it will do it also when we call it second time, nothing was cached
  so to speak.
* We want to test that nothing would be cached if we use *respond* method
  instead of *cacheAndRespond*

### UserActorTest

{% gist yeghishe/81b2803acd8616b84505 %}

Pretty nice and simple, no crazy plumbing going, no boilerplate code and no
complexity. Let's look at *ActorCaching* since it's the base trait for our
actors with caching and it's doing all the heavy lifting for us. First we create
a type alias for our cache *type Cache = Map[Any, Any]*(mainly to hide this
ugly map of any to any thing.) If cache is enabled (we define it as enabled if 
duration isn't set to zero) we're setting up a schedule to send *ExpireCache*
message to self every *cacheDuration* period of time (which comes from
*Config* trait) where we're gonna set our cache to an empty map (initial state.)
Looking in receive partial function, when we get a message that we have cache
we're gonna respond with cached version. When we receive *(NoCache, msg)* we're
not gonna cache and will reply with the message. When getting *(msg, response)*
message we're gonna store the response in cache under msg key
(yey case classes, getting so much for free.). When *ExpireCache* is received,
which is coming from the scheduler as I already mentioned we're simply reseting
cache.

### ActorCaching trait

{% gist yeghishe/517aec06a43119141a65 %}

Now let's look at *respond* and *cacheAndRespond* which we're calling with
child class to send the respond back to caller. Those are getting a future,
mapping it to tuple of *NoCache -> T* or *msg -> T* and piping it to self where
receive function will take care of the rest.

One other small detail is in *onMessageWithResponse* where we don't store the
message in cache if cache is disabled. This gives us an ability to turn of the
cache by setting cached duration to zero without changing the code.
*cacheDuration* is coming from *Config* trait and defined as following so child
actor can override it if it doesn't want to live with the globally set cache
duration:

{% highlight scala %}
  trait Config {
    private val config = ConfigFactory.load()
    val simpleCacheConfig = config.getConfig("scalasnippets.akkasnippets.simplecache")
    def askTimeout = Duration(simpleCacheConfig.getDuration("ask-timeout", SECONDS), SECONDS)
    def cacheDuration = Duration(simpleCacheConfig.getDuration("cache-duration", MINUTES), MINUTES)
  }
{% endhighlight %}

Another small detail that's very important is in *UserActor* that I didn't cover.
Notice that receive method is defined as
*override def receive: Receive = super.receive orElse {}*
This give base trait a chance to check the cache first, if it's found in cache,
partial function after *orElse* won't event hit.

Although we already know what it's working by proving it with unit tests it
would be no fun if we don't actually run it. Here in configuration I'm going to
put cache-duration as one minute.

### Configuration

{% gist yeghishe/358167c30ffd88a48545 %}

I created another actor called *DriverActor*, when it starts it's gonna hit
our user actor asking for user data every 10 seconds. In *Main* class we're
creating our actor system, creating data actor, creating one user actor for
user with id 10 and giving it to driver actor to hit ever 10 seconds.

### Main class

{% gist yeghishe/58421205c1a42f325d06 %}

### The output

    [akka://simple-cache-demo-system/user/driver] Calling to get user data
    [akka://simple-cache-demo-system/user/user-10] Getting user data
    [akka://simple-cache-demo-system/user/driver] got UserData(user10)
    [akka://simple-cache-demo-system/user/driver] Calling to get user data
    [akka://simple-cache-demo-system/user/driver] got UserData(user10)
    [akka://simple-cache-demo-system/user/driver] Calling to get user data
    [akka://simple-cache-demo-system/user/driver] got UserData(user10)
    [akka://simple-cache-demo-system/user/driver] Calling to get user data
    [akka://simple-cache-demo-system/user/driver] got UserData(user10)
    [akka://simple-cache-demo-system/user/driver] Calling to get user data
    [akka://simple-cache-demo-system/user/driver] got UserData(user10)
    [akka://simple-cache-demo-system/user/driver] Calling to get user data
    [akka://simple-cache-demo-system/user/driver] got UserData(user10)
    [akka://simple-cache-demo-system/user/driver] Calling to get user data
    [akka://simple-cache-demo-system/user/driver] got UserData(user10)
    [akka://simple-cache-demo-system/user/user-10] Expiring cache. Cache duration is set to 1 minute
    [akka://simple-cache-demo-system/user/driver] Calling to get user data
    [akka://simple-cache-demo-system/user/user-10] Getting user data
    [akka://simple-cache-demo-system/user/driver] got UserData(user10)
    [akka://simple-cache-demo-system/user/driver] Calling to get user data
    [akka://simple-cache-demo-system/user/driver] got UserData(user10)

As we can see from the log, the first time driver hits user actor, user actor logs
*Getting user data* message which is logged from receive partial function.
Consequent times driver hit's it we don't see that message but we see that
data is being received. Which means receive block isn't being hit and
data is being returned from the cache. After about a minute we see our debug
line that we're writing when we're expiring cache. After cache was expired we
the log message from user-10 actor and everything repeats again.

### Source

* [main](https://github.com/yeghishe/scala-snippets/tree/master/src/main/scala/io/github/yeghishe/scalasnippets/akkasnippets/simplecache){:target="_blank"}
* [test](https://github.com/yeghishe/scala-snippets/tree/master/src/test/scala/io/github/yeghishe/scalasnippets/akkasnippets/simplecache){:target="_blank"}


