---
tags: misc
---

As most technology guys I'm also working on different technologies, playing
with new stuff, facing some challanges that I end up solving.
Always wanted to blog about what I'm working on since if it interests me then
others can also find it helpful or interesting.

So I finally dicided to create one. There are many blog platfoms out there.
I'm not really into CMS, I would much rather open Vim, write some markdown,
publish it somewhere and call it a blog post. Seemed like what I want is github
pages with some basic blogging features. And I found exactly what I was looking
for [Jekyll](http://jekyllrb.com/){:target="_blank"}.
Yep Markdown + github pages = AWESOME. It also has plugins, I'll give it a try.

It's ruby based so I had to install ruby in my vagrant vm. Basicly what it
does it parses liquid and markdown files and generates static site for you.
You can view your posts in brower before publishing. Another nice thing I like
about it is that it watches files when you change something you don't need to
restart the server (although I noticed that it doesn't pick up changes to
*_config* file) just refresh the browser (maybe I'll also explore adding
live reload to it.)

So I created my blog app using ```jekyll new``` and decided to customize it
little bit. Added bootstrap and did little UI work to make it look the way I
wanted, made it responsive and all that. Then decided to see how I can extend
it so it fits my needs.

I figured I'll be uploading some images with my posts so it's a good idea
to think about how I'm gonna organize those ahead of time. I think I would
prefer to keep all images for a post into a separate directory for that post,
maybe give it the post name so things are easy to find. I came cross
[Asset Path Tag](https://github.com/samrayner/jekyll-asset-path-plugin){:target="_blank"}
plugin created by *Sam Rayner*. It's very basic but also a very nice
implementation. Create folder structure ```assets/posts/<post name>``` to store
images and reference an image in markdown by writing
```![<alt text>]({{"{% asset_path <image_name> "}}%})```. Elegant!

Ok next plugin, sitemap. Jekyll is already nice enough to generate RSS why not
try to get *sitemap.xml* generate also. For that I used
[Sitemap.xml Generator](https://github.com/kinnetica/jekyll-plugins){:target="_blank"}
created by *Michael Levin*.

And here free lunch ended for me. Turns out not everything is supper simple with
Jekyll. I wanted to have tagging feature in my blog also since most likely I'll
be writing about different technologies and it would make sense to provide ease
filters for people to use and I already designed navigation based on tags.
Jekyll has really easy way to assosiate posts to categories and tags and to
get tags and categories you used in your posts also very easy. But what's not
easy to do is to have tags page where you go and you see all the posts with
that tag. I was like ok, there must be a plugin to do it already, I tried
couple and got some erros, maybe it's because I'm running the latest version of
Jekyll or maybe I'm using ruby 2.2.0 that's why and those scripts aren't up to
date. Decided to go more advanced and write my first Jekyll plugin. Why not,
they have great documentation and it's been a while since I wrote ruby, why not
get my hands dirty and I write a plugin in ruby. Basicly I took the example that
was for categories and changed it to work for tags. Decided to share it here in
case other find it helpful also.

{% gist yeghishe/c4bf1e9c45092d8c8846 %}

Happy blogging folks,
