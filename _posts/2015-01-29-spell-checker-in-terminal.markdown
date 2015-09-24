---
tags: tools
---

Some people prefer text editors with graphical interface, some can't live
without an IDE, some like web based editors. One nice thing about those is that
those applications or the web browser is doing spell checking for you and you
see what you misspell as you go. I prefer Vim for most part and it being a
command line application you think you'll be out of options there but no.
Vim has a nice built in spell checker.

<!--more-->

Set local in your *vimrc*, this is what I have set

    setlocal spell spelllang=en_us

Just to list few useful commands.

* use **]s** to move to next misspelled word,
* use **[s** to move to previous misspelled word,
* use **z=** to list suggestions for the word under to cursor

Check the documentation for more.

Another cool tool is *aspell* command line application. It's handy when you
have a file and you want to check the spelling on it.

    aspell -c <path to file>

It will open the file and you can go over misspelled words and choose the right
suggestions from the list.

Happy command lining folks,
