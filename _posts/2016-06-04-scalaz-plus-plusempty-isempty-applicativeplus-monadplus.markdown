---
tags: scala scalaz
title: Scalaz Plus, PlusEmpty, IsEmpty, ApplicativePlus and MonadPlus
---

<!--more-->

## [Plus](#plus)
*Plus* is similar to *Semigroup*, it actually is semigroup.
Scalaz defines *Plus[F[_]]* trait with *plus* abstract method similar to
*append* in *Semigroup[F]*. Where *Semigroup* deals with types *Plus* deals with
higher Kinds.
{% highlight scala %}
def plus[A](a: F[A], b: => F[A]): F[A]
{% endhighlight %}

It also has *semigroup* method to convert *Plus* to *Semigroup*.

Scalaz offers *<+>* alias for *plus* function.

## [PlusEmpty](#plustempty)
*PlusEmpty* is *Plus* with *empty* method. Scalaz defines it as
*PlusEmpty[F[_]]* trait which extend *Plus[F]*.
{% highlight scala %}
def empty[A]: F[A]
{% endhighlight %}

It also has *monoid* method to convert *PlusEmpty* to *Monoid*.

Scalaz offers *mempty* alias for *empty* function.

## [IsEmpty](#isempty)
Scalaz defines *IsEmpty[F[_]]* trait which extends *PlusEmpty[F]* and adds
*isEmpty* method.
{% highlight scala %}
def isEmpty[A](fa: F[A]): Boolean
{% endhighlight %}

## [ApplicativePlus](#applicativeplus)
*ApplicativePlus* is both *Applicative* and *PlusEmpty*.

Chris Stucchio wrote an
[article](https://www.chrisstucchio.com/blog/2014/handle_failure_with_plus.html){:target="\_blank"}
about handling failures with ApplicativePlus that's helpful to read.

## [MonadPlus](#monadplus)
*MonadPlus* is both *Monad* and *PlusEmpty*. Since this is a monad and it has
*plus* and *empty* methods, we can derive some functions for *MonadPlus* also.
{% highlight scala %}
def filter[A](fa: F[A])(f: A => Boolean) = bind(fa)(a => if (f(a)) point(a) else empty[A])
{% endhighlight %}

*filter* will lift A if predicate returns true and will return empty otherwise.
There is also *withFilter* alias for *filter* method.

{% highlight scala %}
def unite[T[_], A](value: F[T[A]])(implicit T: Foldable[T]): F[A] =
  bind(value)((ta) => T.foldMap(ta)(a => point(a))(monoid[A]))
{% endhighlight %}

Which takes foldable monad and it folds it into monad. Since *MonadPlus* is a
monoid and T[A] is foldable, foldMap can be used here.
