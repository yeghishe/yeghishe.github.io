---
title:  "Scalaz Comonad"
tags: scala scalaz
---

*Comonad* is a *Cobind* that also has *copoint* method.
Scalaz defines *Comonad[F[_]]* with *copoint* abstract method.
{% highlight scala %}
def copoint[A](p: F[A]): A
{% endhighlight %}
Note that when *point* method of *Monad* turns A to F[A],
*copoint* method of *Comonad* turns F[A] to A.

<!--more-->

Since *NonEmptyList* is *Comonad* I'm gonna demonstrate it on *NonEmptyList*:
{% highlight scala %}
import scalaz.NonEmptyList._
import scalaz.syntax.comonad._

display(NonEmptyList(1, 2, 3).copoint, """ NonEmptyList(1, 2, 3).copoint """)
{% endhighlight%}

## Output
    NonEmptyList(1, 2, 3).copoint    1
