---
tags: sbt scala
---

Sbt is really awesome and there are plugins that make it even better. I thought
I would write a post about the plugins I'm using and why I like to use those.

## Formatting your code.

For formatting scala code I use *sbt-scalariform*. It does a great job
formatting scala code with proper spacing. What I really like about it is that
it formats the code when you compile, so there are no changes you'll commit
code with bad code formatting since when you run ```sbt test``` it compiles
both main code base and test code base (well at the very least you should make
sure all the test are passing before you commit, right). This is a must have
plugins especially if you have more than one person contributing to code base,
that way everybody is following the same style.

## Generating code coverage

*sbt-scapegoat* is a good sbt plugin for scapegoat to do static code analysis.
It will find issues if there are any and report on the console. This one also
runs when you compile your code. The one thing I wish it had is a way to
integrate it with Jenkins. I didn't find a Jenkins plugin for this to show and
graph the violations nor I found a way to make it generate a common report file
like findbug report that Jenkins can pick up.

## Find buys and violations

Another plugin I use for static code analysis is *scalastyle-sbt-plugin* which
checks to make sure you're following standard conventions. You can customize
it's config file to fit the needs of your organization. This one I run by
executing ```sbt scalastyle```. Cool thing about this is that it generates
checkstyle compatible report files so it's really easy to report violations in
Jenkins.

Ok another very important metric to track on code quality is of course code
coverage. I use *sbt-scapegoat* to run scoverage. Run ```sbt coverage test```,
it will generate a nice website for your code coverage report so you can look at
it locally. It also generates cobertura xml reports so getting your code
coverage in Jenkins works out of the box with Jenkins cobertura plugin.

## Figure out what's going on with dependencies

Sometimes(or maybe I should say often) you run into conflicting transitive
dependencies or you get a jar and you have no idea where it's coming from.
This is when *sbt-dependency-graph* comes handy.
Run ```dependencyTree``` or ```dependencyGraph``` sbt task to see the dependency
graph in ASCII tree format on the console, this is really helpful combined
with grep. Or ```dependencyGraphMl``` to generate graph file that can be viewed
by a GUI tool like yEd.

Usually when you start a project you go get dependencies you need at
latest versions and you start building your project. Time goes by and there
are new versions coming out that you may or may not care to upgrade to.
There are services out there that you can use to
report how fresh your dependencies are on your projects page but it's helpful
to find that out from command line while you're already in sbt. There is a great
sbt plugin named *sbt-updates*. Run ```dependencyUpdates``` and you'll
find out what new versions are available. There are other tasks to generate
a report file but I find this one the most useful.

When you're working on a library and on a project that depends on it at the
same time you usually make a change to the library and do publishLocal so you
can start using those changes from the other project. Sometimes it's helpful to
clean or show the artifacts you published or got from a maven repo into cache
directory. *sbt-dirty-money* plugin is there to help.
```show cleanLocalFiles```, ```show cleanCacheFiles```, ```cleanLocal```,
```cleanCache``` tasks will show or clean artifacts from local or cache
directories respectively.

## Productivity plugins

Sometimes you're working on a feature and there is a little thing that you know
you need to do but you decide to not implement it at the moment and
you put a comment with TODO tag in it. Another common one is FIXME, you can
create other tags in your code base, IDEs make it really easy to find
those and Jenkins has a nice plugin for it also. There is this *taglist-plugin*
sbt plugin that lets you find those by running ```tagList``` task. It will list
all those with file name and line numbers.

I'm not a huge fan of running git from sbt but sometimes it's helpfully
especially if you're working on multiple projects and have multiple terminal
tabs open with sbt. If you need to run a quick git command you don't need to
stop sbt or open another tab. *sbt-git* plugin brings git command to sbt and 
with *sbt-groll* plugin you can go back and forward on git commits, really
useful if you're doing code presentation for example.

Another plugins that I find sometimes helpful is *sbt-stats*. By running
```stats``` in sbt it will list number of lines and such metrics about the
code base.
