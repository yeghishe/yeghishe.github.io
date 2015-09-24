---
tags: scala sbt jenkins build
---

So what is continuous integration, at the very high level it's about hey is
the code in a good state, no matter by how many people code is being updated,
how often code is being changed or of how many building blocks project consists of.
When you start working on a feature you're gonna branch of mainline and start
introducing changes. At some point when you find things are broken now you have
to spend time to see if it's because of your changes or project was already in
a bad state. And when you find out that it was already in a bad state you
would want to start tracing. A who introduced the breaking changes and B when.
So to avoid the head each and frustration what you really want to know is
if project is in a good state before you even start working on it.
One option would be to compile the code before you start changing it.
But if code compiles is it enough? Oh you you also wanna know if unit tests are
passing. But is this enough? Check for compiler warnings? Style violations?
Code coverage? What if you run code coverage and it shows that it's 85%,
does it mean everything is good, what if code coverage was 95% last week and
code without proper code coverage got committed and code coverage dropped
(do you remember what code coverage was last week, can you even find
out without going back in commits and running coverage reports on those commits.) are you sure
you want to introduce your changes on top of those changes?
Let's make it even more complex, what if the project consists of many other
projects and the project you're working on brings all those dependencies
tougher. Maybe you should checkout all those dependency projects
and see if those are in a good state also.
Let's make it even more complex, what if the project isn't just set of
projects that get bundled into one big project.
What if the whole code base consists of many micro services that talk to each other
via some form of PRC. OK maybe you can manage to do all this to know if code is
in a good state before you introduce your changes what about the point B I
brought earlier about when code broke, because longer it was in that states
longer it's gonna take to trace the breaking change and longer to fix.
Can you go and check every single project every time someone makes a commit
to make sure that commit is good? Well actually you can, you just need a
build server. So all those points I was bringing was about whatever your
integration is it should be continuous and it's continuous if it runs after
somebody changes something (or maybe before is a better option?☺ I'll get
to this later.)

<!--more-->

This should cover what the continuous part is but what about integration,
what is it actually? I would define it as pipeline of checks that run one
after another and if one fails the whole thing fails if all pass then
code is good. Now let's cover what checks you want to do. You're the best
person to know what checks you need and what you wanna track. I will
cover the most common ones, at least the ones that are relevant for
Scala code base. Also I would cover how to do it in Jenkins since
Jenkins is my preferred build server but it should me mostly similar
other the other ones.

# Compilation

First one that everybody will agree is compilation, does the code compile?
Compilation is one you get for free since Scala has a compiler, it's is
type safe at the end of the day right. Let's make ```sbt compile```,
```sbt test:compile``` and ```sbt it:compile``` (if you have last two of course)
our first item in this pipeline. If code doesn't compile no point to do any other
checks, if it does let's continue.

Since we compiled the code and we got the output we can look for compiler
warnings, so can Jenkins.

![warnings picture]({% asset_path warnings.png %})

# Code quality

We know what compiler warnings are but we can do more checks to see if there
are other issues with code also. *Scapegoat* does exactly that, it's a scalac
plugin that does static code analysis and runs when you compile your code.
There is an sbt plugin for it and I already talked about it in my previous post
about sbt plugins so make sure to check that post out if you haven't already.

Since we're on static code analysis subject let's talk about style violations
also. Do you care to see everybody following the same style, using right
conventions for method names, class names, variables, etc?
There is Scalastyle which is like Checkstyle for java that does that and much
more than that. And guess what it actually outputs Checkstyle xml report and
Jerkins has a plugin for Checkstyle already. We'll run this via
```sbt scalastyle``` task and get the report file generated. Once we have it we
can tell Jenkins to pick it up.

![checkstyle picture]({% asset_path checkstyle.png %})

## Open tasks

Another thing that would be helpful is to know if there are open tasks in
project and if there are what are those. Jenkins has a way to detect
tags like TODO, FIXME and others. Jenkins has a feature where it can scan the
code to find those, just configure it.

![open tasks picture]({% asset_path open_tasks.png %})

## Unit tests

Once our code compiles, we're happy with styles, etc we want to make sure that
unit tests are passing. ```sbt test``` can output junit xml report and once we
have it Jenkins already has an integration for junit so we would be done there
just tell Jenkins there those xml files are. Same goes for other flavors
of test, like it:test.

![unit tests picture]({% asset_path unit_tests.png %})

## Code coverage

When unit testes are passing it's still not enough we want to measure what
the code coverage is and of course find code paths that are never being hit
from a unit tests. There are couple options in Scala world for code coverage,
I'm using *scoverage*. Nice thing about it is that it generates cobertura
coverage report and as you can guess Jenkins already has integration with
cobertura.

![cobertura picture]({% asset_path cobertura.png %})

At this point we got enough checks in already. Build on it's own is boolean,
it either passes or it fails. For things like compilation and unit testing it's
simple if one of those are failing fail the build. For there other ones, when we
measure it, we have numbers like number of compiler warnings, number of check
style violations, percentage of code coverage. In Jenkins we can configure those
so if a particular number goes above value X we fail the build. X can also be
zero depending how aggressive you wanna be there. Violations plugin can be used
there.

## Documentation

Another thing we want to get is auto generated documentation, java docs to
be more specific (well in this instance scala docs).
```sbt doc``` (or some other task that depends on doc task, publish for
example) will generate scala docs and Jenkins can pick it up and display
the link on the dashboard or we can host it as a static website somewhere.

![javadoc picture]({% asset_path javadoc.png %})

## Final Sbt configuration

Using the sbt plugin we can configure this. And this series of sbt task would be
enough: ```clean coverage test it:test scalastyle publish```.
This will compile main, test and integration test code-bases,
run Scapegoat as part of compilation (assuming you have it configured for
you project), run tests and integration tests, publish the artifacts
(will cover publishing later in the post). And doc task run as part of publish
since it's a dependency of it but it never hurts to put it there explicitly.

![sbt picture]({% asset_path sbt.png %})

# Notifications

So build pipeline is there, now every time there is a commit in source control
build will trigger and it will either fail or pass. Either way we get instant
feedback which was one of the main problems we wanted to solve. You can get notifications
when job stars, fails or succeeds. I generally don't care to be notified when a
job succeeds unless it's deploy job or something (which I won't be covering in
this post.) but I absolutely care to know when a build job is failing.
You can do pretty much all types of notifications: Email, Slack, Hipchat, IRC,
IM whatever you're using, Jenkins has plugins for all of those. I personally
like to send an email out when a job fails and put a message in a Slack room
when a job starts or finishes.

![email picture]({% asset_path email.png %})

![slack picture]({% asset_path slack1.png %})

And include Slack notifications at post build step at the bottom of job
configuration.

![slack picture]({% asset_path slack2.png %})

## Output of the build

We define build to be a pipeline of checks that the code goes through
every time there is a commit. We torture every single commit to go through this
pipeline and we say if build passes commit is good. So what is the output of the
build? Also we only deploy good changes, right? The output of a good build would
be the artifacts. We worked really hard to make sure that code is good by running
series of checks on it and we better keep those artifacts for deployment. In scala
artifacts would be jars or wars, depending on the project. There are few options
on where to store the artifacts depending how you're planing on using them. If
it's a project that's gonna be referenced by other projects, artifact would be a
jar archive and storing it in an artifact server like Nexus would be a good
choice. If it's a service or a web site you're planing to deploy you can put it
on s3, upload to elastic beanstalk if it's what you're using or create a docker
container, put that jar or war in it and push it to a docker registry. There
are nice Sbt or Jenkins plugins for all those. For Nexus I use an sbt plugin
and when you do ```sbt publish``` it uploads the artifact to my private nexus
server.

![artifacts in nexus picture]({% asset_path nexus.png %})

## Versioning

And since every good commit produces an artifact (or set or artifacts) we should
talk about versions. We already specify the version in sbt file and when
```sbt package``` is run it creates the artifacts with specified version.
One thing that would be good if we could link a specific version of an artifact
to source code.  One good way to do this is to create a tag on commit when
we build the artifact. Which isn't hard to do, we can get the version by
running ```sbt version```, storing it in an environment variable
(VERSION for example) and use Git publisher functionality of Jenkins to create
a git tag with that version.

![git tag picture]({% asset_path git_tag.png %})

## Pull requests

Remeber I said it would be better to know if a commit is good before it even
gets to mainline. With the setup mentioned so far when a commit gets to master
build will trigger and if it's bad job will fail. To not allow bad code
to even get to master at first place we need to run integration on it before merging it.
We never merge a branch when you do code review and identify that it needs
more work, right? But what you can't tell from just code reviewing is if it
compiles, unit tests are passing, what is code coverage after the change, etc.
And do we even want to code review a change if build will fail for it?
What we need to do is to have a magical way that when we go to review a pull
request somehow it has a flag on it saying build is passing for it or no.
There is a Jenkins plugin for building pull requests also, it will run the
build, and comment github pull request.

![pull request comment picture]({% asset_path pr_build.png %})

To get this working all you need to do is to create another job that instaed of
building master will build pull requests. For this job there are few things
we don't actually need. We don't care do generate scala docs for this type
of builds, version or publish the artifacts, so make sure to exclude those steps
from pull request builder jobs.

## Wrapping up

Let's see what we got so far. Every time there is a commit build will start
immediately and we'll get instant feedback whether build passes or fails. If
build passes we know that all checks we defined are good for the commit.
We create tags for each version in git, we publish artifacts for deployment or
referencing from other projects.
Other than those we get lot of nice features on Jenkins dashboard.

* We can see the status of the build.
* See the change log with commit messages, committers and links to github.
* We can browser the workspace.
* Start a build.
* Navigate to github page of the project.
* See detailed reports for checkstyle or other static analysis warnings.
* Navigate to scala docs.
* See code full coverage reports with percentages, which lines are covered which ones aren't, classes, packages.

![jenkins dashboard picture]({% asset_path jenkins_dash1.png %})

We can see the build history and dig dipper in a particular build.

![jenkins dashboard picture]({% asset_path jenkins_dash2.png %})

<br/>
<br/>
Get height level view or the project with number of violations and graphs that
shows whether over time number of violations, open tasks, number of unit tests
increases or decrease's. Of course we want it to see number of violations and
open tasks decreasing and number of unit tests increasing. Just a good way to
measure how quality changes with every commit.

![jenkins dashboard picture]({% asset_path jenkins_dash3.png %})

![jenkins dashboard picture]({% asset_path jenkins_dash4.png %})

![jenkins dashboard picture]({% asset_path jenkins_dash5.png %})
