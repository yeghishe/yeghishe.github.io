---
title:  "Practical scalaz"
tags: scala scalaz
---

Scala is an object oriented language with functional aspects. Some people
like the object oriented aspect some people are attracted by the functional part.
Add to that the fact that it's sitting on top of JVM and of course it's
influenced by Java a lot, we still have nulls, we still have exceptions,
IO and state mutation. And since Scala isn't purely functional it still
allows us to write imperative code, call a Java library that will throw an
exception, etc. I personally think that functional code is easier to read and 
understand, unit test and maintain(not event talking about state and multiple
threads). So when it comes to writing purely functional code (or as close to it
as possible) Scala sure misses certain things and scalaz has a lot built to
help. When people talk about scalaz they usually start to talk about
Monads, Monoids, Applicatives, Factors, etc. I decided to write a series of
posts covering scalaz not from category theory or haskel prospective
but more problem solution approach where there is a pattern you need in
real world application to do certain things functional way.

I would be posting series of short posts with code snippets to demonstrate
certain features in scalaz. I'll put the links to all posts here so it'll
be easy to find.
