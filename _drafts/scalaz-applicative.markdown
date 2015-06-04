---
title:  "Scalaz Applicative"
tags: scala scalaz
---

*Applicative* is *Apply* that also has *point* or *pure* method.
Scalaz defines *Applicative[F[_]]* trait with *point* abstract method.
{% highlight scala %}
def point[A](a: => A): F[A]
{% endhighlight %}
*point* method lifts A to F[A].
Since *Applicative* is *Apply* it inherits all the methods that *Apply*
offers plus it needs to provide implementation for *map* and *ap* methods.
Note that *Applicative* implements map using *point* and *ap* methods:
{% highlight scala %}
override def map[A, B](fa: F[A])(f: A => B): F[B] = ap(fa)(point(f))
{% endhighlight%}

Scalaz offers following syntax/derived functions:

* **η**, **point** and **pure**. Lift value into F.
* **replicateM**. Performs action n times and returns list of results.
* **replicateM_**. Performs action n times and returns unit.
{% comment %}
* **unlessM**. If condition is true returns passed F, otherwise lifts unit into F.
* **whenM** If condition is false returns passed F, otherwise lifts unit into F.
{% endcomment %}

Since *Option* is *Applicative* I'm gonna demonstrate those methods on *Optioni*
with short examples:
{% highlight scala %}
import scalaz.std.option.optionInstance
import scalaz.syntax.std.option._
import scalaz.syntax.applicative._

display(1.η, """ 1.η """)
display(1.point, """ 1.point """)
display(1.pure, """ 1.pure """)

display(1.some.replicateM(3), """ 1.some.replicateM(3) """)
display(1.some.replicateM_(3), """ 1.some.replicateM_(3) """)
{% endhighlight%}

## Output
    1.η                                                        Some(1)
    1.point                                                    Some(1)
    1.pure                                                     Some(1)
    1.some.replicateM(3)                                       Some(List(1, 1, 1))
    1.some.replicateM_(3)                                      Some(())
