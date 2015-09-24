---
tags: gulp nodejs coffeescript build
title: My Gulp Files&#58; Library Projects
---

For this type of projects I use CoffeScript, Chai and Mocka for unit testing,
Istanbul for code coverage, Sinon and Proxyquire for mocking, Jenkins for
continuous integration. This type of projects are easy to build because those
don't have front-end components, compilation/optimization, browser testing,
live reload etc. Here we do need to compile CoffeScript to JavaScript since
we're gonna publish the package with JavaScript code and not CoffeScript. What I
do is keep my coffee code in *src* directory instead of *lib*. At compile time I
generate JavaScript code into *lib* directory, add *src* directory to *.npmignore* and
*lib* directory to *.gitignore*. That way my CoffeeScript ends up in git repo but
not generated JavaScript and my JavaScript ends up in published package and not
JavaScript, pretty smart right :). I also use CoffeScript for my
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

{% gist yeghishe/c6f3171a6ec9db89134c %}

Going from top to bottom, first task is **version**, it just gets the package
version from *package.json* file and outputs it to the console. I use this in Jenkins.

Next comes **clean**. It just removes build generated files, for next build to start
from a clean slate.

Next comes **lint**. I like to lint my code and know about issues with my code sooner
than later. Based on Jenkins environment variable I decide which report format to use.
During development I like to use *stylish* and for Jenkins, *checkstyle* to generate
checkstyle xml and report it nicely in Jenkins using checkstyle plugin. Notice
that I'm linting both CoffeeScript and JavaScript code. Why? because
CoffeeScript code is what I write and JavaScript code is what I publish.

Next comes **test**. It does both unit testing and code coverage. This will generate
test and code coverage reports, both on console using text and xml files to be used by
jUnit and Cobertura plugins to generate nice graphs and reports in Jenkins.

Next comes **compile**. This compiles CoffeeScript code to JavaScript. As I
mentioned I'm publishing JavaScript code and not CoffeeScript, so I need to
compile it first.

Final three are **watch**, **build**, **default**. *build* is combo task that
runs *clean*, *lint*, *test* and *compile* in that order. *watch* watches my
files for changes and it triggers a new build automatically every time I make
a change to my code. *default* task (which is triggered when you run *gulp*
without passing any task) builds the projects and watches for file changes.
This way I just type gulp and I'm ready to work on my project knowing that
everything is good and every time I make a change it automatically will lint,
test and compile my code.

This is the build cycle for this type of projects. All you need to do is have
your repo url in *publishConfig* section of *package.json* file, auth info
in *.npmrc* file and do *npm publish*. I use *Nexus* to host my private npms
but you can use *npmjs* or something else.

Make sure to also check my other gulp files out:

* [My Gulp Files]({% post_url 2015-08-13-my-gulp-files %})
* [My Gulp Files: Rest Api Projects]({% post_url 2015-08-13-my-gulp-files-rest-api %})
* [My Gulp Files: Ionic App Projects]({% post_url 2015-08-13-my-gulp-files-ionic-app %})
