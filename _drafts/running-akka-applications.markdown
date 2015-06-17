---
tags: scala sbt akka docker sbt activator
---

With *akka* becoming more and more popular, *akka kernel* being deprecated,
*docker* rocking the word, *Typesafe* releasing *ConductR* and more folks
getting to scala, I wanted to write a post about how to run akka applications.
Akka applications aren't servlet applications java developers are used to,
normally those are main class applications in a jar file and have other jars as
dependencies. So it's no-brainer that we can just use java command and
no container like tomcat or jetty is need. I will cover how to run in
development while iterating on a task. How to run it in development and tunnel
the port and let others point to your code before you even go to production
or pre production environment and how to run it inside a docker container in
production and pre production environments. Unforunatly I didn't get hold of
*ConductR* to try it myself, so I won't be writing about it in
this post. Btw, most of this should be to relevant other scala/java main class
applications not only *akka* and *akka http* applications.

## How to run in development

Since it's development environment things are easier because we have the tools
installed and those are making thing easier for us. The easiest thing to
do would be to use *sbt run* command. sbt run is fine when I just want to bring
my server up but while developing I always have sbt loaded, then I run comments
there, be it compile, test, it:test, etc. What I want is to run it, and every
time I go and add more code, come back to sbt and restart my app.
This way I don't have to reload sbt every time I just need to wait for compiler
to compile the files I modified. This approach makes development much faster.
The problem with sbt run (no matter if you're running *run* target from sbt
that's loaded or running *sbt run* from terminal) is that in order for you to
restart your running app you have to kill stb and load it again, which takes
some time.

You can also run your app using activator ui. When you make a change to
your code it will restart your app.

One sbt plugin I use is *sbt-revolver* from spray and it's *reStart* is sure my
favorite. Basically as I said I always have sbt running and when I need to start or
restart my app I just run *reStart* command from sbt. I can exactue other sbt
targets while it's running since I still have my sbt shell avaliable, or stop it
using *reStop*. *~reStart* also works if you prefer it to automaticly restart
when you make a change.
To configure *sbt-revolver* add *Revolver.settings* to your build file.

Another good plugin is *sbt-native-packager*. You either stage or distribute
your build. To stage it run *stage* command and it will
create *target/universal/stage* folder in your project with *bin* and *lib*
subdirectories. *bin* has bash and windows cmd files with your project name
that will run your application. *lib* directory has all your dependency jars.
You see where this is going? No one jar, fat jar, big jar business. We have
clean and lightweight jar file with only things that needs to be in it.
We can put in nexus (or whatever else you're using), lib is clean and
shows what the dependencies are with their versions. I like to use *stage* to
create executable and use it to run my application when I'm doing the final
testing before I push my change since this is the most production like version
(well unless we're using docker).  To distribute it you run *dist* command.
It produces exactly what *stage* does but instead of making stage folder it
creates a zip file with your application name and version. I never run it in
development because in order for me to run my app I have to unzip it first,
which is what stage is for. This is for CI server to run and store produces
zip artifact on S3 (or whatever else you're using).
To configure *sbt-native-packager* add *enablePlugins(JavaAppPackaging)* to
your build file.

If you don't need to iterate fast in development, you just need to run it
and use it, you have all those options, sbt run, activator, reStart, stage,
docker. Although I do recommend for final testing to stage and run the staged
files or run docker container since this how your app is gonna run in next
environments.

## Running in production and pre production environments

We already know what we get when we run *dist* command from
*sbt-native-packager*. We can just deploy it to all our environments, expend
it and run the bash file (build once run it everywhere). This is one option.

Better option is *Docker*. *sbt-native-packager* can help you generate
*Dockerfile*, build and push your image.

* *docker:stage* will create *target/docker* folder with *Dockerfile*,
  executable, and dependency jars.
* *docker:publishLocal* will build a docker images with your application name and
  tag it with version you have in your sbt build file.
* *docker:publish*  will push docker image to *DockerHub* or your configured
  registry tagging it with the version in build file (This one you should
  run from your CI server).

Now we're treating docker images as our artifacts. We can pull the same
artifact (docker image), and run it in all our environments. Again build once
run it everywhere. If you're using docker in production it's a good idea to
run your app in docker container locally for final testing instead of using
*sbt stage*, since that's the whole point of docker, you're running the whole
container, same that will run in production, not just your application.
What you need to do is to run *docker:publishLocal* target to create the image
locally. Then use *docker run*
(```docker run -t -i --rm -p 9000:9000 yeghishe/running-akka-apps-sample:0.0.1 /bin/bash```).

## Sample app

To demo those options and to make it easier for folks to reference the
configuration I created a sample akka http app based on my
*minimal-scala-akka-http-seed* activator template (to create a project based
on it do ```activator new <YOU PROJECT NAME> minimal-scala-akka-http-seed```).
It has activator already in it, has the plugins I mentioned in project
directory and a simple service that returns the mandatory Hello World when doing
get request on root path. I'll be demonstrating all the options I talked about.
After you have it running, you can validate it by hitting it with
```curl localhost:9000``` command.


### sbt run
Execute ```sbt run``` from terminal or load sbt then exacute *run* target.

### Typesafe activator
Execute ```./activator ui``` which will start a server (listening on port 8888
by default) and open your browser pointing to it.
Go to *Ran* tab and hit *Start* button.

### sbt-revolver
Load sbt and execute *reStart* or *~reStart*.

* *reStart* starts or restarts the app.
* *reStop* stops the running app.
* *reStatus* shows if the app is running or it's stopped.

### sbt-native-packager with zip packages
Execute *stage* target from sbt and run executable in
*target/universal/stage/bin/* directory.

### Docker
I pushed a docker images for this sample app to my DockerHub account for your
convinice. Just run ```docker pull yeghishe/running-akka-apps-sample:latest```
to bring down the lastest image.

To start the container:

    docker run -d -p 9000:9000 yeghishe/running-akka-apps-sample:latest

Or to run interactivly and automaticly remove the container when you stop it:

    docker run -t -i --rm -p 9000:9000 yeghishe/running-akka-apps-sample:latest /bin/bash
