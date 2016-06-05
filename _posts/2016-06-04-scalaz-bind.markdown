---
title:  "Scalaz Bind"
tags: scala scalaz
---

*Bind* is an *Apply* that also has bind method.
Scalaz defines *Bind[F[_]]* trait with *bind* abstract method.
{% highlight scala %}
def bind[A, B](fa: F[A])(f: A => F[B]): F[B]
{% endhighlight %}
Having F[A] and mapping A to F[A] it returns F[B].

Since *Bind* is *Apply* it inherits all the methods that *Apply* offers plus
it needs to provide implementation for *map* and *ap* methods.
Note that *Bind* implements *ap* using *bind* and *map* methods:
{% highlight scala %}
override def ap[A, B](fa: => F[A])(f: => F[A => B]): F[B] = {
    lazy val fa0 = fa
    bind(f)(map(fa0))
}
{% endhighlight%}

<!--more-->

Having *bind* method we can derive *join* method which will take F[F[A]] and
turn it into F[A]:
{% highlight scala %}
def join[A](ffa: F[F[A]]): F[A] = bind(ffa)(a => a)
{% endhighlight %}

We can also define monadic if, having F[Boolean], F[B] and F[B] we return
first F[B] or last.
{% highlight scala %}
def ifM[B](value: F[Boolean], ifTrue: => F[B], ifFalse: => F[B]): F[B] = {
  lazy val t = ifTrue
  lazy val f = ifFalse
  bind(value)(if(_) t else f)
}
{% endhighlight %}

Scalaz offers following syntax/derived functions:

* **∗**, **\>\>=** and **flatMap**. All aliases for bind method.
* **μ** and **join**. When there is implicit Liskov A to F[B] it will
  join F[A] to F[B].
* **\>\>**. Converts to F[B] regardeless of the value of a.
* **ifM**. If there is implicit to convert A to boolean it returns
  true F[B] or false F[B] based on boolean value.

Since *Option* is *Bind* I'm gonna demonstrate those methods on *Option* with
short examples:
{% highlight scala %}
import scalaz.std.option._
import scalaz.syntax.std.option._
import scalaz.syntax.bind._

display(1.some.flatMap(a => (a + 1).some), """ 1.some.flatMap(a => (a + 1).some) """)
display(1.some >>= (a => (a + 1).some), """ 1.some >>= (a => (a + 1).some) """)
display(1.some ∗ (a => (a + 1).some), """ 1.some ∗ (a => (a + 1).some) """)
display(none[Int] ∗ (a => (a + 1).some), """ none[Int] ∗ (a => (a + 1).some) """)

display(1.some >> 5.some, """ 1.some >> 5.some """)
display(none[Int] >> 5.some, """ none[Int] >> 5.some """)

display(true.some.ifM(1.some, 2.some), """ true.some.ifM(1.some, 2.some) """)
display(false.some.ifM(1.some, 2.some), """ false.some.ifM(1.some, 2.some) """)
{% endhighlight%}

## Output
    1.some.flatMap(a => (a + 1).some)                          Some(2)
    1.some >>= (a => (a + 1).some)                             Some(2)
    1.some ∗ (a => (a + 1).some)                               Some(2)
    none[Int] ∗ (a => (a + 1).some)                            None
    1.some >> 5.some                                           Some(5)
    none[Int] >> 5.some                                        None
    true.some.ifM(1.some, 2.some)                              Some(1)
    false.some.ifM(1.some, 2.some)                             Some(2)
