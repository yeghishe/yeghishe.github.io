---
tags: sbt scala
---

If you work in an organization or doing your personal project sooner or latter
you're gonna need an artifact server. And few reasons this would be you want to
host your build artifacts but not make those available to the public, you want
to have a proxy server to use when you download your artifacts, this is
particularly
helpful when you have more than one person working on the project or you simply
have some jars that aren't in maven central or other public repos and you want
to host those so you can list them as dependencies from your build tool.

<!--more-->

My favorite artifact server is nexus for many reasons. It's feature reach, easy
to use and can support npm, gem, NuGet artifacts besides jars. So for our scala
projects I decided to go with nexus. After artifacts are produced those aren't
any different from java ones so most of the work nexus already done for me when
it came to setting up the repos. There is already a public repo which a group
repo and combines Releases, Snapshots, Third Party and proxy for Central.
Releases is where your release artifacts are stored, Snapshots for for snapshot
deploys, Third Party is good to put your existing jars that aren't in maven
central or in any other public repo. Proxy for maven central repo is good so you
can have the jars you're using from community hosted in your server. You can add
more proxy repos if you feel it's appropriate.

For sbt I did need to create a separate group repo which is a combination of two
proxy repos, one for *http://repo.typesafe.com/typesafe/ivy-releases/* and other
for *http://repo.scala-sbt.org/scalasbt/sbt-plugin-releases/*.

Also I like to separate users who can deploy, who can use the artifacts instead
of using admin user everywhere. And I do recommend disabling anonymous user so
you're strict about who has access to your artifacts.

Now it's time to configure sbt to use our nexus server instead of public repos.
Add following to ```cat ~/.sbt/repositories``` file
{% highlight ini %}
[repositories]
  local
    ivy-proxy-releases: <your ivy repo>, [organization]/[module]/(scala_[scalaVersion]/)(sbt_[sbtVersion]/)[revision]/[type]s/[artifact](-[classifier]).[ext]
    maven-proxy-releases:<your maven reop> 
{% endhighlight %}

Note that in order for sbt to get plugins from your repo also you have to run
it with
```sbt.override.build.repos``` flag set to true. Consult
[sbt documentation](http://www.scala-sbt.org/0.12.2/docs/Detailed-Topics/Proxy-Repositories.html){:target="_blank"}
for more info.

Since we decided to secure our nexus with authentication we need to tell sbt
where what the credentials are, and the most elegant way to do it to store
in credentials file. Create a file named ```~/.sbt/.credentials``` to store the
credentials. For build server you would put deployment user credentials, for
developer computer developer credentials here.

{% highlight ini %}
realm=<realm here>
host=<host here>
user=<user name here>
password=<passord here>
{% endhighlight %}

You can find out what ```realm``` is by doing (most likey it's
*Sonatype Nexus Repository Manager* though):

{% highlight bash %}
curl -v -XHEAD <urt nexus url>/content/groups/public/
{% endhighlight %}

and look at  ```WWW-Authenticate``` header.

For ```host``` just put the host name without port number.

Now in your ```plugins.sbt``` add

{% highlight scala %}
credentials += Credentials(Path.userHome / ".sbt" / ".credentials")
{% endhighlight %}

This is it. Now when you run sbt it will get dependencies from our repos.
Publishing artifacts is also easy. I only let build server do it so the most
elegant way to handle it is adding following to ```global.sbt``` file in
build server.

{% highlight scala %}
publishTo := {
  val nexus = "your nexus server url"
  if (isSnapshot.value)
    Some("snapshots" at nexus + "content/repositories/snapshots")
  else
    Some("releases"  at nexus + "content/repositories/releases")
}
{% endhighlight %}

```sbt publish``` will now publish the artifacts to our repo (don't forget to
put deployment user in credentials files on build server).

Happy and elegent builds guys,
