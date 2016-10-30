---
tags: scala opensource
---

Ammonite is such a great project, especially [Ammonite-REPL](http://www.lihaoyi.com/Ammonite/#Ammonite-REPL){:target="_blank"}. It brings many great things to scala console: syntax highlighting, better editing, dynamically loading dependencies, loading scripts, etc. It comes very handy if you want to play with a some library without creating an sbt project. Or you want to try something out without necessarily loading IntelliJ. I happen to do it often and decided to start an open source project called [ammonite-modules](https://github.com/yeghishe/ammonite-modules){:target="_blank"}. The idea is to have pre-defined modules you can load in Ammonite Repl. Modules will have all the dependencies needed at latest versions and do some basic setup.

<!--more-->

The structure of the project is simple:
{% highlight text %}
├── base.sc
├── modules
│   ├── project1
│   │   ├── project1-module1.sc
│   │   ├── project1-module2.sc
│   │   └── project1-module3.sc
│   ├── project2
│   │   ├── project2-module1.sc
│   │   └── project2-module2.sc
│   ├── project3
│   │   └── project3.sc
{% endhighlight %}

`Base.sc` file contains all the versions (hopefully it will be maintained so all latest versions will be in master). Modules directory has all the modules. The idea here is that each project may have different modules and user chooses which module to load. For example this:
{% highlight text %}
├── Base.sc
├── modules
│   ├── akka
│   │   ├── akka-actor.sc
│   │   ├── akka-http.sc
│   │   └── akka-stream.sc
│   ├── cats
│   │   ├── cats-core.sc
│   │   └── cats.sc
│   ├── circe
│   │   └── circe.sc
{% endhighlight %}

Here use can load `akka-actor`, `akka-http`, `akka-stream`, etc. All three are different modules. Or user may want to load only `cats-core` vs `cats` (all cats projects). Or it can be a simple project with only one module, like `circe` in this example.

To load a module run `loadM("<PROJECT>" -> "<MODULE>")` (for example, loadM("cats" -> "cats-core")). To use `loadM` method you need to have it in `predef.sc` file. Simply run following to have the proper predefs created: 

{% highlight bash %}
curl https://raw.githubusercontent.com/yeghishe/ammonite-modules/master/predef.sc > ~/.ammonite/predef.sc
{% endhighlight %}

You can start `amm` in `ammonite-modules` directory to laod a module or have `AMMONITE_MODULES` environment variable to point to the directory where you checked out `ammonite-modules`. Environemt variable will give more flexibility.

Modules don't stop by just loading needed dependencies and importing classes. Each module can also do a reasonable setup for the project. For example, `akka-actor` may want to create an implicit actor system, `akka-http` and `akka-stream` may want to create implicit actor system and materializer, etc. You get the idea.

To demonstrate this let's write an akka application right in Ammonite Repl. First things first, let's load `akka-actor` module:
{% highlight scala %}
loadM("akka" -> "akka-actor")
{% endhighlight %}

Then let's write this simple akka actor and start it: 
{% highlight scala %}
class DemoActor extends Actor with ActorLogging {
  case object Hello

  override def preStart(): Unit = {
    import context.dispatcher
    context.system.scheduler.schedule(1 second, 1 second, self, Hello)
  }

  override def receive: Receive = {
    case Hello => println("Hello ammonite-modules")
  }
}

system.actorOf(Props(new DemoActor), "demo")
{% endhighlight %}

You should see `Hello ammonite-modules` message print every one second. Note that we didn't create the actor system nor we imported `scala.concurrent.duration._` or any akka classes, `akka-actor` module has it predefined for us. In a production app you would want to keep the messages and props method for the actor in it's companion object but to just play with akka this is good enough code.

Hope others will find it helpful and use it. Also see the next section if you would like to contribute.

## How to contribute

* Each now project should have it's sub directory under `modules` folder and at least one scala file in it. See above how modules are named.
* `Versions` case object in `Base.sc` file should include a public val for the project with latest version.
* Add those three lines to the top of the file:
  {% highlight scala %}
  interp.load.module(wd / "Base.sc")
  @
  {% endhighlight %}
* Send pull requests, be it a bug fix, improvement, upgrading a version to the latest or adding more modules. All pull requests are welcome.
