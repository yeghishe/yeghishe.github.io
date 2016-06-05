---
title:  "Scalaz Monad"
tags: scala scalaz
---

*Monad* is *Applicative* and *Bind*. With that we deal with:
{% highlight scala %}
def ap[A,B](fa: ⇒ F[A])(f: ⇒ F[A ⇒ B]): F[B]
def map[A, B](fa: F[A])(f: A ⇒ B): F[B]
{% endhighlight%}
from *Apply*
{% highlight scala %}
def point[A](a: => A): F[A]
override def map[A, B](fa: F[A])(f: A => B): F[B] = ap(fa)(point(f))
{% endhighlight%}
from *Applicative*
{% highlight scala %}
def bind[A, B](fa: F[A])(f: A => F[B]): F[B]
override def ap[A, B](fa: => F[A])(f: => F[A => B]): F[B] = bind(f)(map(fa))
{% endhighlight%}
from *Bind*.

Note that in *Applicative*, *map* method is implemented using
*ap* method and in *Bind*, *ap* is implemented using *bind* method. With that,
two methods that are left to be implemented for a *Monad* are
*point* and *bind*.

<!--more-->

Having those we can derive other methods for monad.

* **liftM**. List a monad into a different monad.
* **whileM**. Executes action while predicate is true and collects the results into MonadPlus.
* **whileM\_**. Executes action while predicate is true.
* **unitlM**. Until version of WhileM.
* **unitlM\_**. Until version of WhileM\_.
* **iterateWhile**. Similar to whileM\_ except predicate is A => Boolean instead of F[Boolean].
* **iterateUntil**. Similar to unitlM\_ except predicate is A => Boolean instead of F[Boolean].
