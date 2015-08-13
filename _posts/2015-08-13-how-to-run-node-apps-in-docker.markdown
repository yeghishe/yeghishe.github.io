---
tags: nodejs docker devops
---

I like to use docker to run my server side apps and my node apps aren't
exception. Decided to show the docker file I use for my node apps and explain
what I'm doing there. I copy the entire source, having the files I want to
exclude in docker ignore file. The most important thing to note is I don't copy
*node_modules* directories, I do fresh install in docker. Main reason is that
docker container is kinda different operating system and potentially a different
distro (Debian in this instance, because I love it!) than dev or CI box.
So why not build the code where it's gonna run and if there are issues I'll
know about it sooner. Also note that I run *npm install* with *production*
switch so it doesn't install dev dependencies, which I don't really need to run
my app.

## Dockerfile
{% highlight text %}
FROM yeghishe/nodejs:0.12.7
MAINTAINER Yeghishe
EXPOSE 80

COPY . /src/
RUN cd /src && npm install --production

VOLUME /logs
WORKDIR /src
CMD ["forever", "-a", "-o", "/logs/mydemoapp.log", "-e", "/logs/mydemoapp.log", "-c", "coffee", "server.coffee"]
{% endhighlight %}

I also expose logs directory to be mounted on host so it can be tailed easily,
forwarded to centralized log box (rsyslog, kibana, splunk, whatever you use),
rotated. Everything else doesn't really have a state so no need to provide
option to be mounted on host.
I do run it in forever which isn't strictly required, you can have the main
process run the container and when it crashes have upstart or monit restart the
container  but I feel like forever way would be faster to recover and forever
has always worked for me, so why not.

If you're using JavaScript just use *node* executable instead of *coffee*.

Also here is my docker ignore file.

## .dockerignore file
{% highlight text %}
build/
node_modules/
test/
Dockerfile
gulpfile.coffee
README.md
{% endhighlight %}

Feel free to use my public *nodejs* image for your own node applications.

* [yeghishe/nodejs](https://hub.docker.com/r/yeghishe/nodejs/){:target="_blank"}
* [Dockerfile](https://github.com/yeghishe/docker-files/blob/master/nodejs/Dockerfile){:target="_blank"}

Also check my other post out about [running akka applications in docker]({% post_url 2015-06-24-running-akka-applications %}).
