---
tags: gulp nodejs CoffeeScript build docker
title: My Gulp Files&#58; Rest Api Projects
---

For this type of projects I use CoffeScript, Chai and Mocka for unit testing,
Istanbul for code coverage, Sinon and Proxyquire for mocking, Jenkins for
continuous integration. This type of projects are easy to build because those
don't have front-end components, compilation/optimization, browser testing,
live reload etc. And for server side code we don't need to compile CoffeeScript to
JavaScript since it's running on server and we can use *coffee* executable to
run the code instead of *node* executable. I also use CoffeScript for my
gulpfile since it makes it much more clean and compact. Some people who do
that like to also create *gulpfile.js* file with

<!--more-->

{% highlight js %}
require('coffee-script/register');
require('./gulpfile.coffee');
{% endhighlight %}

as a way to load gulpfile. I prefer not to do that to not have that extra build
file and confusion why there are two gulp files one with js extension other
with coffee extensions, is JavaScript file complied version of coffee script,
etc. Gulp can figure out that it needs to *gulpfile.coffee* if you have
*coffee-script* module in *node_modules*. So I just add it to my dev dependencies
(It does mean though that I have to live with npm warning that coffee script
should be installed globally).

{% gist yeghishe/336594a088086f4db0bf %}

Going from top to bottom, first task is **version**, it just gets the package
version from *package.json* file and outputs it to the console. I use this in Jenkins.

Next comes **clean**. It just removes build generated files, for next build to start
from a clean slate.

Next comes **lint**. I like to lint my code and know about issues with my code sooner
than later. Based on Jenkins environment variable I decide which report format to use.
During development I like to use *stylish* and for Jenkins, *checkstyle* to generate
checkstyle xml and report it nicely in Jenkins using checkstyle plugin.

Next comes **test**. It does both unit testing and code coverage. This will generate
test and code coverage reports, both on console using text and xml files to be used by
jUnit and Cobertura plugins to generate nice graphs and reports in Jenkins.

Next comes **server:start**. Which simply start my node server in development.

Final three are **watch**, **build**, **default**. *build* is combo task that runs
*clean*, *lint* and *test* in that order. *watch* watches my files for changes and it
triggers build and restarts the dev server automatically every time I make a change to
my code. *default* task (which is triggered when you run *gulp* without passing any task)
builds the projects, starts the server and watches for file changes.
This way I just type gulp and I'm ready to work on my project.
Notice that *server:start* and *watch* tasks are executed in parallel because both are
blocking.

This is the build cycle for this type of projects. I do like to use *docker* to run my
node apps so at the end of build I like to generate a docker image and put it on docker
registry (this is where version comes handy.) My other post explains how to run
node apps in docker:

* [How To Run Node Apps In Docker]({% post_url 2015-08-13-how-to-run-node-apps-in-docker %})

Make sure to also check my other gulp files out:

* [My Gulp Files]({% post_url 2015-08-13-my-gulp-files %})
* [My Gulp Files: Library Projects]({% post_url 2015-08-13-my-gulp-files-library %})
* [My Gulp Files: Ionic App Projects]({% post_url 2015-08-13-my-gulp-files-ionic-app %})
