---
tags: scala
---

Here at [Ad Hoc Labs](http://adhoclabs.co/){:target="_blank"} we open sourced
one of the projects I start to handle reliable execution of different tasks.
I wanted to build a library that would be higher level abstraction than queuing,
will allow implementing new type of tasks with only config changes, will be
backend independent, so backends like RabbitMQ and Kafka can be chosen based on
config, will allow flexibility to have publishers running in one project and
consumers running in other project, has flexibility to decide which projects
will run what consumers and producers and how many of them. All with only
config changes.
To give an idea what we do, we build privacy layer for phone numbers and
there are many things we want to run in reliable manner, queue tasks, execute
things in an asynchronous way. We are a scala shop and among many scala libraries
we use akka also. Idea was simple, if in akka world we have actor A sending a
message to actor B, there are many things that can go wrong, even if both are
running in same JVM. Actor B may be down when actor A is sending the message.
Actor B may fail to process the task, so there is a need for retries. Some
tasks can take long time to process so there is a need to run things
asynchronously. You may want to scala out and have many instances of actor B, etc.
This actor model is very clean and suited for this type of things. And if
you're familiar with akka, you know that some of those akka handles out of the
box, some can be accomplished by akka persistence and some things simply aren't
there. So I wanted to have a very simple library so you won't need to have
Cassandra cluster, write lot of boilerplate, be forced to use one specific
message queue and have it be extremely flexible and extendable.
The core idea is same, actor A sends a task to actor B to process, and actor B
will *eventually* get the task. I wanted it to be very similar to the way you
send a message from actor A to actor B in akka and have no other complexity
there.

This is how messages is sent between two actors in Akka.
![diagram 1]({% asset_path d1.png %})

And this is how that same message is sent from actor A to actor B using Task
library. You just wrap it in *Task* envelope, specifying the type of task
(push message for example) and send it to *TaskActor*. Actor B will *eventually*
receive that message.
![diagram 2]({% asset_path d2.png %})

What's happening under the hood is following:
![diagram 3]({% asset_path d3.png %})
Based on configuration, where Task library is embedded, we specify
producers and consumers the project will run. Here is an example config,
it specifies that this project is running *sometask* producer,
*sometask* consumer(just for simplicity in this example both producer and
consumers are running in some project) and destination actor which is actor B.
This type of consumer is called proxy consumer since it's not processing
messages (we'll see that there are consumers that process tasks on their own
also), it get's messages and forwards them to another actor that will do the
processing and respond (actor B in this instance). Once response is successful
consumer marks the task as successfully completed, if it fails some other
consumer of same type (most likely running on another box) will pick it up to
process.

{% highlight scala %}
task {
  producers = ["sometask"]
  consumers = ["sometask"]
  consumer-proxy-actors= {
    sometask {
      target-actor = "akka://my-system/user/actor-b"
    }
  }
}
{% endhighlight %}

For all the producers and consumers specified in config, Task library will
create consumer and producer actors which become children of *TaskActor* and
are supervised by it. When *TaskActor* receives *Task* message it forwards it
to the right producers based on type of the task, specified in *Task* messag.
The actually message payload that's in *Task* messages will be send to the
right queue (based on task type) in the backend (RabbitMQ for example.) From
there the consumer for that type, that's listening on that queue, will
receive the message, forward it to the actor specified in config and mark that
task as completed when target actor finishes processing the message without
failure. A thing to note here is that we're able to send any case class in
queued manner to any destination actor just by adding configuration.

This is simple and clean, at least user facing part. This is more of a generic
model that allows to implement any type of task. There are more specific or
common cases also, for example sending a push notification,
publishing analytic events, downloading a file and putting it on s3, etc. For
those it can be simplified even farther, and the way to do it to have regular
consumers instead of proxy consumers. For example consumer for push
notifications when getting the message it can send the push itself instead of
forwarding it to another actor. And that's what gives the library another
vector of extensibility. People can add this type of reusable consumers into Task
library directly and it'll be able to do lot of things out of the box.
With this type of common tasks all we have is this:
![diagram 4]({% asset_path d4.png %})

And under the hood it will do:
![diagram 5]({% asset_path d5.png %})

Those are the features we have in current version of Ad Hoc Labs Task library.
There are lot of other things I want to build for it and open sourcing it was
the first stage. Hopping other people will be excited about the library and
will contribute. My plan is to have
[Ad Hoc Labs version](https://github.com/adhoclabs/task){:target="_blank"} be
the stable version and build all new feature in
[my fork](https://github.com/yeghishe/task){:target="_blank"} without worrying
about backward compatibility. When version 1.0.0 is reached, then merge back.
To just give some idea what I would like to build for v1.0.0:

* Implement Kafka and Redis backends. Right now only RabbitMQ backend is supported
* Cleaner way to configure number of workers
* Retries
* More built in consumers, Mixpanel, S3, etc...
* Use travis CI for builds since Ad Hoc Labs Jenkins is private
* Artifacts to be published in Maven central since Ad Hoc Labs Nexus is private
* Separate project for examples code

And the biggest change is to make the project relevant to non Scala shops also.
More about that, when you think about it there are two clear partitions there,
one is publisher side and other is consumer side.
![diagram 6]({% asset_path d6.png %})

Built in or common consumers
will be built right into Task library and it'll always be Scala. Producer side
however doesn't have to be Scala. As long as message gets to the backend and
there is predefined protocol for messages, task library workers can pick it up
and process the task.
![diagram 7]({% asset_path d7.png %})

That would be a good idea if some people already have infrastructure that talks
to RabbitMQ or Kafka. A cleaner approach would be to put an HTTP layer on top of
task library, which will take the massages from rest layer and use publisher
infrastructure that's already in Task library. This way backend will still be
encapsulated and plugable. A couple servers will run Task HTTP service behind
the load balancer for producing and set of servers will run Task library directly
as workers (which it already is able to do.)
![diagram 8]({% asset_path d8.png %})

This will make the project go beyond being a nice scala library but also a
project that's able to process common tasks in reliable manner and can be used
from any codebase written in any language. Current open items will be tracked
in [Github issues](https://github.com/yeghishe/task/issues){:target="_blank"} 
and if you're interested in contributing or have a question feel free to jump
into the [Gitter room](https://gitter.im/yeghishe/task){:target="_blank"}.
