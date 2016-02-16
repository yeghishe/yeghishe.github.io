---
tags: docker
---

Recently folks at [Replicated](https://www.replicated.com/){:target="_blank"}
created an oper source tool called [FROM:latest](https://www.fromlatest.io/#/){:target="_blank"},
which is a linting tool for docker files. You put the content of your docker
file and it tries to find issues you have in it. Such a cool idea, I never
came across a tool like this for docker files before. I decided to try it with
the docker files I wrote in past to find potential issues in them and it
actually found few issues.

<!--more-->

This docker file I
wrote a while back to build docker containers for nodejs applications.
{% img posts/{{page.slug}}/before.png alt:'docker file before linting' %}

With first error, it points out that I never bothered putting my email address
in MAINTAINER directive. A better version would be
`MAINTAINER Yeghishe Piruzyan ypiruzyan@gmai.com`.

Next two are optimizations tricks it suggests, for example,
using `--no-install-recommends` will sure make my image size smaller.

And last one is probably the most important one. Definitely agree that
`from:latest` is a bad practice (I guess that's where the name of the tool
cames from to begin with.)

After applying suggested changes this is what my docker file looks like now.

{% img posts/{{page.slug}}/after.png alt:'docker file after linting' %}

It's time to commit those changes to my docker files.

Another reason why I like the idea of having such a tool is the fact that docker
is moving so fast. For someone like me, who's not writing a docker file every
day it's not always easy to be on top of new changes docker introduces. I'm sure if
in future docker adds a new directive or changes something about existing ones
the tool will be able to tell about those also.
