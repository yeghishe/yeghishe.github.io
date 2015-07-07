---
title:  "Scalaz Apply"
tags: scala scalaz
---

*Apply* is *Functor* that also has apply method.
Scalaz defines *Apply[F[_]]* trait with *ap* abstract method.
{% highlight scala %}
def ap[A,B](fa: ⇒ F[A])(f: ⇒ F[A ⇒ B]): F[B]
{% endhighlight %}
Having a higher kind A and hight kind of A to B mapping we can get higher
kind B.  And since *Apply* is also a functor we also have
{% highlight scala %}
def map[A, B](fa: F[A])(f: A ⇒ B): F[B]
{% endhighlight %}

We can do interesting things with those two. We can define *ap2* for example,
which will take, F[A], F[B], F[(A, B) ⇒ C] and return F[C]
{% highlight scala %}
def ap2[A,B,C](fa: ⇒ F[A], fb: ⇒ F[B])(f: F[(A,B) ⇒ C]): F[C] =
  ap(fb)(
    ap(fa)(
      map(f)(_.curried) // This will give us F[A ⇒ B ⇒ C]
    ) // Here we'll have F[B ⇒ C]
  ) // And now we'll get F[C]
{% endhighlight %}

And we can extends this to apN to go as many levels deep as we want.
We can also define *apply2* which will take F[A], F[B] and (A, B) ⇒ C mapping
and retrun F[C]. Note that unlike *ap2*, it takes (A, B) ⇒ C instead of
F[(A, B) ⇒ C].
{% highlight scala %}
def apply2[A, B, C](fa: ⇒ F[A], fb: ⇒ F[B])(f: (A, B) ⇒ C): F[C] =
  ap(fb)(
    map(fa)(f.curried) // This will give as F[B ⇒ C]
  ) // And now we'll get F[C]
{% endhighlight %}

This one also we can extends to applyN. Since *apply2* takes (A, B) ⇒ C
mapping we can just not map it to another type and return (A, B) tuple.
{% highlight scala %}
def tuple2[A,B](fa: ⇒ F[A], fb: ⇒ F[B]): F[(A,B)] = apply2(fa, fb)((_,_))
{% endhighlight %}

And of course we can define tupleN using applyN.
Having *apply2* we can define *lift2* which will take (A, B) ⇒ C mapping and
lift it to (F[A], F[B]) ⇒ F[C] mapping.
{% highlight scala %}
def lift2[A, B, C](f: (A, B) ⇒ C): (F[A], F[B]) ⇒ F[C] = apply2(_, _)(f)
{% endhighlight %}
We can also define liftN based on applyN.

Of course we don't have to derive all those factions ourself since scalaz is
so awesome it provides those for us. It also defines following syntax functions:

* **<\*>** for ap.
* **tuple** for tuple2.
* **\*>** which uses apply2 with (_, b) ⇒ b mapping to discard the left.
* **<\*** which uses apply2 with (a, _) ⇒ a mapping to discard the right.
* **⊛** and **\|@\|** applicative builders as alternatives to applyN.
* **^**, **^^**, **^^^**, **^^^^**, **^^^^^** and **^^^^^^** for
  apply2, apply3, apply4, apply5, apply6, apply7

Since both *Option* and *Lists* are *Apply* I'm gonna demonstrate those methods
on them with short examples:
{% highlight scala %}
import scalaz.std.option._
import scalaz.std.list._
import scalaz.syntax.std.option._
import scalaz.syntax.apply._

display(1.some <*> ((_: Int) + 1).some, """ 1.some <*> ((_:Int) + 1).some """)
display(none <*> ((_: Int) + 1).some, """ none <*> ((_:Int) + 1).some """)
display(1.some <*> none, """ 1.some <*> none """)

display(1.some.tuple(2.some), """ 1.some.tuple(2.some) """)
display(none.tuple(2.some), """ none.tuple(2.some) """)
display(1.some.tuple(none), """ 1.some.tuple(none) """)

display(List(1, 2).tuple(List("a", "b")), """ List(1,2).tuple(List("a", "b")) """)

display(1.some *> 2.some, """ 1.some *> 2.some """)
display(none *> 2.some, """ none *> 2.some """)
display(1.some *> none, """ 1.some *> none """)

display(1.some <* 2.some, """ 1.some <* 2.some """)
display(none <* 2.some, """ none <* 2.some """)
display(1.some <* none, """ 1.some <* none """)

display(("a".some ⊛ "b".some)(_ + _), """ ("a".some ⊛ "b".some)(_ + _) """)
display(^("a".some, "b".some)(_ + _), """ ^("a".some, "b".some)(_ + _) """)
display(^^("a".some, "b".some, "c".some)(_ + _ + _), """ ^^("a".some, "b".some, "c".some)(_ + _ + _) """)
{% endhighlight%}

## Output
    1.some <*> ((_:Int) + 1).some                              Some(2)
    none <*> ((_:Int) + 1).some                                None
    1.some <*> none                                            None
    1.some.tuple(2.some)                                       Some((1,2))
    none.tuple(2.some)                                         None
    1.some.tuple(none)                                         None
    List(1,2).tuple(List("a", "b"))                            List((1,a), (1,b), (2,a), (2,b))
    1.some *> 2.some                                           Some(2)
    none *> 2.some                                             None
    1.some *> none                                             None
    1.some <* 2.some                                           Some(1)
    none <* 2.some                                             None
    1.some <* none                                             None
    ("a".some ⊛ "b".some)(_ + _)                               Some(ab)
    ^("a".some, "b".some)(_ + _)                               Some(ab)
    ^^("a".some, "b".some, "c".some)(_ + _ + _)                Some(abc)
