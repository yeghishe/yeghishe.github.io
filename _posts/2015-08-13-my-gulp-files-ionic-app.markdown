---
tags: gulp nodejs coffeescript build ionic
title: My Gulp Files&#58; Ionic App Projects
---

For Ionic projects also I use CoffeeScript, Sass, Jade although ionic generates
the project in JavaScript and Html. Here we have front-end components,
compilation, browser testing, live reload, and all that goodness. Here we do
need to compile CoffeScript to JavaScript, Sass to Css and Jade to Html.
Another thing that needs to be solved since browser will run JavaScript, Css
and html instead of CoffeScript, Jade, Sass so debugging will be really
challenging. To solved that problem I generate source map files. I also use
CoffeScript for my gulpfile since it makes it much more clean and compact.
Some people who do that like to also create *gulpfile.js* file with

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

{% gist yeghishe/1bb6ed2edb4a1c3b4ded %}

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

Next comes **copy**. It copies static files like images, JavaScript code that I
didn't write and don't want to convert to CoffeeScript, *index.html* which I
chose not to convert to Jade because of many reasons, etc.

Next come **compile:coffee**, **compile:sass**, **compile:jade**. Those compile
CoffeeScript code to JavaScript, Sass to Css and Jade to html. I use
*ngClassify*, *uglify* and *sourcemaps* for JavaScript. *minifyCss* and
*sourcemaps* for Css. For Templates I use *angularTemplatecache*. Notice that
I have piping html files down to *templates* directory commented out, in case I
need to debug something with my templates I'll uncomment it.

Final three are **watch**, **build**, **default**. *build* is combo task that
runs *clean*, *lint*, *copy* and *compile*. Notice that after *clean* everything
ran in parallel because all those can be executed in parallel, so why not use
those cors.  *watch* watches my files for changes and it triggers a new build
automatically every time I make a change to my code. *default* task (which is
triggered when you run *gulp* without passing any task) builds the projects and
watches for file changes. This way I just type gulp and I'm ready to work on my
project knowing that everything is good and every time I make a change it
automatically will build my code.

This is the build cycle for this type of projects. Artifact here can just be a
zip file, you may just zip it up, and name with proper version and store
somewhere. Deploy job will talk that zip with the right version, extract and
upload to Ionic View, TestFlight, HockeyApp or whatever. Or just make it
continuous and every time there is a commit upload the build.

Make sure to also check my other gulp files out:

* [My Gulp Files]({% post_url 2015-08-13-my-gulp-files %})
* [My Gulp Files: Library Projects]({% post_url 2015-08-13-my-gulp-files-library %})
* [My Gulp Files: Rest Api Projects]({% post_url 2015-08-13-my-gulp-files-rest-api %})
