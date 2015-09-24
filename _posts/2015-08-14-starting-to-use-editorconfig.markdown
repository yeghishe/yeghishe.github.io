---
tags: tools
---

I have known about [EditorConfig](http://editorconfig.org/){:target="_blank"}
for a while now but only recently decided to use it. It tells your editor to use
tabs or spaces, indent size, tab width, what the end of the line should be,
charset, whether to trim trailing whitespaces, add or not new lines at the end
of the file. And all this can be configured per file extension(s) and per
project. It supports pretty much all editors and IDEs out there, either they
support it naively or there is a plugin for it. I'm mostly using Vim so I went
ahead and installed the plugin for Vim. Most of the configuration it supports I
honestly already have in my vim config (partially that's why I wasn't in rush to
start using it). The only thing I needed it to solve for me was to remove trailing
whitespaces and add a new line for scala a java files (second one btw didn't
work for me in Vim, not sure what the deal is there.) So obviously it does very
little for me, the real benefit of this project though is when other people are
also working on the same project. So you end up with consistent style and this
kind of things I always appreciate.

<!--more-->

However, sharing my generic editorconfig file in case others will find it useful.

{% gist yeghishe/a402fd29f3852fb28523 %}
