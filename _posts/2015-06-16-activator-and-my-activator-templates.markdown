---
tags: scala activator
---

When activator just came out I wasn't really excited about it. I'm more of a
command line guy and using a web UI to help me build, test, run my code isn't
very useful to me. Activate also allows you to browse the code from web IDE. I
usually use Vim, IntelliJ or GitHub for it, but I get the idea, for someone who
doesn't have his or her environment setup and maybe got a project that's not
even in github yet, web IDE can be helpful. I have to give more credit to
activator though, because of couple really cool things. Recently my colleague
who's not a scala developer (and of course he doesn't have his scala
environment setup with latest sbt and all that) needed to run one of the
projects we have in his local computer and asked me how to do it.
And of course first thing that came to my mind was get the latest sbt and do sbt
run. Then I remembered that I started that project from one of the activator
templates I created, so it must have activator there. So he ran ```./activator```
and magic! It went and downloaded needed sbt version and loaded sbt environment
for him. And the reason I started my own activator templates at first place is
because it solves another big problem for me.

<!--more-->

I'm usually working on three type of projects in scala world, simple libraries,
akka applications or akka http applications. I found myself on copy pasting
build files, sbt plugins file, dependencies, configuration, etc.. from other
projects, every time I was starting a new project. The issue isn't only that
it's lot of work but you often miss things. Activator has two type of
templates, tutorials or seed projects. Developers create a project from a
template and start customizing it for their own needs, changing things,
removing not needed code and dependecies, adding their own dependencies etc.
I didn't really want to solve one problem of lot of manual work and create a new
one, so I decided to create my own templates. Very minimal, folder structure,
package hiearchy with my github uri, build file, dependencies I use for every
project, sbt plugins I use and their configuration,
integration tests configuration, etc. This way all my new project will need
is already there. Also I can keep the depenedencies upgraded to newer
versions and every time I start a new project I don't have to do all that work
again and again.

Here are my templates:

### Minimal Scala Lib Seed
Designed to create simple scala libraries. To create a project run:

    activator new <YOUR PROJECT NAME> minimal-scala-lib-seed

* [Activator page](https://www.lightbend.com/activator/template/minimal-scala-lib-seed){:target="_blank"}
* [Github repo](https://github.com/yeghishe/minimal-scala-lib-seed){:target="_blank"}


### Minimal Scala Akka Seed
Designed to create Akka projects. To create a project run:

    activator new <YOUR PROJECT NAME> minimal-scala-akka-seed

* [Activator page](https://www.lightbend.com/activator/template/minimal-scala-akka-seed){:target="_blank"}
* [Github repo](https://github.com/yeghishe/minimal-scala-akka-seed){:target="_blank"}

### Minimal Scala Akka Http Seed
Designed to create Akka Http projects. To create a project run:

    activator new <YOUR PROJECT NAME> minimal-scala-akka-http-seed

* [Activator page](https://www.lightbend.com/activator/template/minimal-scala-akka-http-seed){:target="_blank"}
* [Github repo](https://github.com/yeghishe/minimal-scala-akka-http-seed){:target="_blank"}

### Scala AWS Lambda Seed
Designed to create Aws Lambdas using Scala projects. To create a project run:

    activator new <YOUR PROJECT NAME> scala-aws-lambda-seed

* [Activator page](https://www.lightbend.com/activator/template/scala-aws-lambda-seed){:target="_blank"}
* [Github repo](https://github.com/yeghishe/scala-aws-lambda-seed){:target="_blank"}
