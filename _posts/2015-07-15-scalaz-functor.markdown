---
title:  "Scalaz Functor"
tags: scala scalaz
---

*Functor* is a mapping from type F[A] hight kind to F[B]. Scalaz defines
*Functor[F[_]]* trait with *map* abstract method.
{% highlight scala %}
def map[A, B](fa: F[A])(f: A ⇒ B): F[B]
{% endhighlight %}
Having a higher kind A and A to B mapping we can get higher
kind B.

Having map function we can define *lift* fucntion that takes A ⇒ B mapping and
it lifts it to F[A] ⇒ F[B] mapping.
{% highlight scala %}
  def lift[A, B](f: A ⇒ B): F[A] ⇒ F[B] = map(_)(f)
{% endhighlight %}
Since *map* is curried and first parameter list is F[A] and we pass f as
second parameter list, we get back F[A] ⇒ F[B] function.
Other operations scalaz derives from *map* function are:

* **∘**, **apply**, **map**. Those are all aliases for *map* function.
  ```List(1, 2, 3) ∘ (_ + 1) = List(2, 3, 4)```
* **strengthL**. Injects value to the left.
  ```List(1,2,3).strengthL("a") = List((a,1), (a,2), (a,3))```
* **strengthR**. Injects value to the right.
  ```List(1,2,3).strengthR("a") = List((1,a), (2,a), (3,a))```
* **fpair**. Pairs all values into tupples of two.
  ```List(1, 2, 3).fpair = List((1,1), (2,2), (3,3))```
* **fproduct**. Pairs all values into tupples of two where first element is a
  and second element is f(a).
  ```List(1, 2, 3).fproduct(_ + 1) = List((1,2), (2,3), (3,4))```
* **void**. Maps elements to void values.
  ```List(1, 2, 3).void = List((), (), ())```
* **fpoint**. Points values into an applicative.
  ```List(1, 2, 3).fpoint(scalaz.std.option.optionInstance) = List(Some(1), Some(2), Some(3))```
* **\>\|** and **as**. Changes all values to provided value.
  ```List(1, 2, 3) >| "a" = List(a, a, a)```

## Source
{% highlight scala %}
import scalaz.std.list._
import scalaz.syntax.functor._

display(List(1, 2, 3) ∘ (_ + 1), """ List(1,2,3) ∘ (_ + 1) """)

display(List(1, 2, 3).strengthL("a"), """ List(1,2,3).strengthL("a") """)
display(List(1, 2, 3).strengthR("a"), """ List(1,2,3).strengthR("a") """)
display(List(1, 2, 3).fpair, """ List(1, 2, 3).fpair """)
display(List(1, 2, 3).fproduct(_ + 1), """ List(1, 2, 3).fproduct(_ + 1) """)
display(List(1, 2, 3).void, """ List(1, 2, 3).void """)
display(
  List(1, 2, 3).fpoint(scalaz.std.option.optionInstance),
  """ List(1, 2, 3).fpoint(scalaz.std.option.optionInstance) """)
display(List(1, 2, 3) >| "a", """ List(1, 2, 3) >| "a" """)
{% endhighlight %}

## Output
    List(1,2,3) ∘ (_ + 1)                                      List(2, 3, 4)
    List(1,2,3).strengthL("a")                                 List((a,1), (a,2), (a,3))
    List(1,2,3).strengthR("a")                                 List((1,a), (2,a), (3,a))
    List(1, 2, 3).fpair                                        List((1,1), (2,2), (3,3))
    List(1, 2, 3).fproduct(_ + 1)                              List((1,2), (2,3), (3,4))
    List(1, 2, 3).void                                         List((), (), ())
    List(1, 2, 3).fpoint(scalaz.std.option.optionInstance)     List(Some(1), Some(2), Some(3))
    List(1, 2, 3) >| "a"                                       List(a, a, a)
