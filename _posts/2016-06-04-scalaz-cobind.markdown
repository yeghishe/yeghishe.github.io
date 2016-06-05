---
title:  "Scalaz Cobind"
tags: scala scalaz
---

*Cobind* is a *Functor* that also has *cobind* method.
Scalaz defines *Cobind[F[_]]* trait with *cobind* abstract method.
{% highlight scala %}
def cobind[A, B](fa: F[A])(f: F[A] => B): F[B]
{% endhighlight %}
Having F[A] and mapping F[A] to B it returns F[B]. Note that unlike *bind*
method in *Bind* functor, *cobind* takes F[A] => B instead of A => F[B] function.

Since we have *cobind* method we can define *cojoin* method bases on it.
Unlike to *join* in *Bind*, it turns F[A] to F[F[A]] instead of F[F[A]] to F[A].
{% highlight scala %}
def cojoin[A](fa: F[A]): F[F[A]] = cobind(fa)(fa => fa)
{% endhighlight %}

<!--more-->

Scalaz has *coflatten* alias for *cojoin* and *coflatMap* alias for *cobind*.

Since *Option* is *Cojoin* I'm gonna demonstrate those methods on *Option* with
short examples:
{% highlight scala %}
import scalaz.std.option._
import scalaz.syntax.std.option._
import scalaz.syntax.cobind._

def isEmpty[A](o: Option[A]) = o.isEmpty

display(1.some.cobind(isEmpty), """ 1.some.cobind(isEmpty) """)
display(1.some.coflatMap(isEmpty), """ 1.some.coflatMap(isEmpty) """)

display(1.some.cojoin, """ 1.some.cojoin """)
display(1.some.coflatten, """ 1.some.coflatten """)
{% endhighlight%}

## Output
    1.some.cobind(isEmpty)                                     Some(false)
    1.some.coflatMap(isEmpty)                                  Some(false)
    1.some.cojoin                                              Some(Some(1))
    1.some.coflatten                                           Some(Some(1))
