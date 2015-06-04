---
title:  "Scalaz Foldable"
tags: scala scalaz
---

Scalaz provides foldable to define all fold operation.
It has *Foldable[F[_]]* trait with two *foldMap* and *foldRight* abstract
methods:
{% highlight scala %}
def foldMap[A,B](fa: F[A])(f: A ⇒ B)(implicit F: Monoid[B]): B
def foldRight[A, B](fa: F[A], z: ⇒ B)(f: (A, => B) => B): B
{% endhighlight %}

*foldMap* says having a foldable A, a mapping function from A to B and B
is monoid it will fold F[A] into B.

*foldRight* says having a foldable A, initial value z of type B, and a mapping
function from (A, B) combination to B, it will fold fa int B.
By providing implementations for those two methods we'll get following
operations on foldable for free.

* **foldMap**. As already mentioned having B be a monoid and a mapping from
  A to B it will fold into B. Here are some examples:
  * ```List(1, 2, 3).foldMap() = 6``` (which is same as
    ```List(1, 2, 3).foldMap((a: Int) ⇒ a```) since identity is the default
    value for mapping function). Not that here Monoid for integer is used on
    zero and plus options so we get back the sum by doing foldMap.
    Another example with int to string mapping:
  * ```List(1, 2, 3).foldMap((a: Int) ⇒ a.toString) = "123"```,
  and here monoid for string is used and we get back a concatenated string.
  * ```nil[Int].foldMap() = 0``` since B is monoid (int in this instance)
    when foldable is empty it will fold it into zero.
* **foldMap1Opt**. Where *foldMap* requires B to be monoid, *foldMap1Opt*
  releives it a bit by requiring B to be a semigroup instead of monid (meaning
  it doesn't have zero) and returnign Option[B]. Examples:
  * ```List(1, 2, 3).foldMap1Opt() = Some(6)``` here we get the sum back since
    the plus is the append operator of int semigroup we imported.
  * ```nil[Int].foldMap1Opt() = None```. Here we get None since your List is
    empty.
* **foldRight**. As already mentioned is one of the abstract methods that need
  to be implemented. Let's look at it for list of integeres.
  ```List(1, 2, 3, 4).foldRight(1)(_ * _) = 24``` here we're getting product
  back as I defined my inital value 1 and my mapping function is product(
  of course there is an easier way to do this in scalaz, which I'll conver when
  I get to *Traverse* but this will do good for the demo.)
* **foldMapRight1Opt**. Similar to *foldRight* but instead of providing
  starting value we provide a function that returns starting value. But here if
  it's empty, starting value won't be there, so it returns optional. Examples:
  * ```List(1, 2, 3).foldMapRight1Opt(a ⇒ a + 1)(_ + _) = Some(7)```
  * ```nil[Int].foldMapRight1Opt(a ⇒ a + 1)(_ + _) = None```
* **foldRight1Opt** is similar to *foldMapRight1Opt* but intead of taking a
  function for starting value it defaults to identity function.
  * ```List(1, 2, 3).foldRight1Opt(_ + _) = Some(6)```
  * ```nil[Int].foldRight1Opt(_ + _) = None```
* **foldLeft**. Nothing fancy here just a regular fold left. Instard of folding
  from right it folds from left.
  ```List(1, 2, 3).foldLeft(0)(_ - _) = -6``` where fold right will give 2.
* **foldMapLeft1Opt** and **foldLeft1Opt**. Similar to their right version
  except it's fold left.
* **foldRightM** simpilar to *foldRight* but mapping function maps (a, b)
  compbination to G[B] provided G monad and returns G[B]. Example:
  Option is a monad
  ```List(1, 2, 3).foldRightM(0)((a, b) ⇒ Option(a + b)) = Some(6)```
* **foldLeftM** similar to *foldRightM* but does fold left.
* **foldMapM** similar to *foldRightM* where B is a monoid and it can do fold
    map on monoid.
  ```List(1, 2, 3).foldMapM(a ⇒ Option(a.toString)) = Some(123)```
* **fold** or **concatenate** do what foldMap does except here A and B are
  the same and mapping function is the identity, so it will fold to a value of
  same type using the monoid.
* **foldr** and **foldr1Opt** are curied versions of
  *foldRight* and *foldRight1Opt*
* **foldl** and **foldl1Opt** are curied versions of
  *foldLeft* and *foldLeft1Opt*
* **foldrM** and **foldlM** are curied versions of
  *foldRightM* and *foldLeftM*
* **length** or **count** calculates lenght using *foldLeft*.
  ```List(1, 2, 3).length = 3```
* **index** find item at given index using *foldLeft* and returns optional.
  * ```List(1, 2, 3).index(0) = Some(1)```
  * ```List(1, 2, 3).index(3) = None```
* **indexOr** similar to *index* but instead of returning optional it takes
    default value.
  * ```List(1, 2, 3).indexOr(-1, 0) = 1```
  * ```List(1, 2, 3).indexOr(-1, 3) = -1```
* **sumr** and **suml** are calculateing sum, one using *foldRight* other
  using  *foldLeft*
  * ```List(1, 2, 3).sumr = 6```
  * ```List(1, 2, 3).suml = 6```
* **toList** uses *foldLeft* and list's Nil and :: cons operators to build list.
* **toIndexedSeq** uses *foldLeft* and :+ cons operators to build indexed
  sequence.
* **toSet** uses *foldLeft* and + cons operators to build set.
* **toStream** uses *foldRight* and Stream's cons operators to build Stream.
* **toIList** uses *foldLeft* and :: cons operators to scalaz IList.
* **toEphemeralStream** uses *foldRight* and EphemeralStream's cons operators to
  build scalaz EphemeralStream.
* **∀** or **all** use *foldRight* to determine if predicate is true for all
  elements
  ```List(1, 1, 1) ∀ (a ⇒ (a % 2) ≠ 0) = true```
* **∃** or **any** use *foldRight* to determine if predicate is true for at least
  one element
  ```List(1, 2, 3) ∃ (a ⇒ (a % 2) ≟ 0) = true```
* **allM** and **anyM** are monadic verions of *all* and *any*.
* **maximum** gets the maxinum of the values
  ```List(1, 2, 3).maximum = Some(3)```
* **maximumOf** gets the maxinum value maping function generates.
  ```List(0D, math.Pi).maximumOf(math.cos) = Some(1.0)```
* **maximumBy** gets the element on which maping function generates the greates
  value.
  ```List(0D, math.Pi).maximumBy(math.cos) = Some(0.0)```
* **minimum** gets the minimum of the values
  ```List(1, 2, 3).minimum = Some(1)```
* **minimumOf** gets the minimum value maping function generates.
  ```List(0D, math.Pi).minimumOf(math.cos) = Some(-1.0)```
* **minimumBy** gets the element on which maping function generates the lowest
  value.
  ```List(0D, math.Pi).minimumBy(math.cos) = Some(3.141592653589793)```
* **emtpy** tells if foldable is empty. Examples:
  * ```List(1, 2, 3).empty = false```
  * ```nil[Int].empty = true```
* **element** tells if element is in foldable. Examples:
  * ```List(1, 2, 3).element(1) = true```
  * ```List(1, 2, 3).element(3) = false```
* **splitWith** splits the elements into groups that alternatively satisfy
  and don't satisfy the predicate.
  ```List(2, 4, 1, 3, 5).splitWith(a ⇒ (a % 2) ≟ 0) = List(NonEmptyList(2, 4), NonEmptyList(1, 3, 5))```
* **selectSplit** selects only the elements that satisfy the predicate:
  ```List(1, 2, 3).selectSplit(a ⇒ (a % 2) ≟ 0) = List(NonEmptyList(2))```
* **intercalate** inserts specified element between every elements and folds
  using the monoid. ```List(1, 2, 3).intercalate(10) = 26```

## Source
{% highlight scala %}
import scalaz.std.anyVal.doubleInstance
import scalaz.std.anyVal.intInstance
import scalaz.std.string._
import scalaz.std.option._
import scalaz.std.list._
import scalaz.syntax.equal._
import scalaz.syntax.foldable._

display(List(1, 2, 3).foldMap(), """ List(1, 2, 3).foldMap() """)
display(List(1, 2, 3).foldMap((a: Int) ⇒ a.toString), """ List(1, 2, 3).foldMap((a: Int) => a.toString) """)
display(nil[Int].foldMap(), """ nil[Int].foldMap() """)

display(List(1, 2, 3).foldMap1Opt(), """ List(1, 2, 3).foldMap1Opt() """)
display(nil[Int].foldMap1Opt(), """ nil[Int].foldMap1Opt() """)

display(List(1, 2, 3, 4).foldRight(1)(_ * _), """ List(1, 2, 3, 4).foldRight(1)(_ * _) """)

display(List(1, 2, 3).foldMapRight1Opt(a ⇒ a + 1)(_ + _), """ List(1, 2, 3).foldMapRight1Opt(a => a + 1)(_ + _) """)
display(nil[Int].foldMapRight1Opt(a ⇒ a + 1)(_ + _), """ nil[Int].foldMapRight1Opt(a => a + 1)(_ + _) """)

display(List(1, 2, 3).foldRight1Opt(_ + _), """ List(1, 2, 3).foldRight1Opt(_ + _) """)
display(nil[Int].foldRight1Opt(_ + _), """ nil[Int].foldRight1Opt(_ + _) """)

display(List(1, 2, 3).foldRight(0)(_ - _), """ List(1, 2, 3, 4).foldRight(1)(_ * _) """)
display(List(1, 2, 3).foldLeft(0)(_ - _), """ List(1, 2, 3, 4).foldRight(1)(_ * _) """)

display(List(1, 2, 3).foldRightM(0)((a, b) ⇒ Option(a + b)), """ List(1, 2, 3).foldRightM(0)((a, b) ⇒ Option(a + b)) """)
display(List(1, 2, 3).foldMapM(a ⇒ Option(a.toString)), """ List(1, 2, 3).foldRightM(0)((a, b) ⇒ Option(a + b)) """)
display(List(1, 2, 3).concatenate, """ List(1, 2, 3).concatenate """)

display(List(1, 2, 3).length, """ List(1, 2, 3).length """)
display(List(1, 2, 3).index(0), """ List(1, 2, 3).index(0) """)
display(List(1, 2, 3).index(3), """ List(1, 2, 3).index(3) """)
display(List(1, 2, 3).indexOr(-1, 0), """ List(1, 2, 3).indexOr(-1, 0) """)
display(List(1, 2, 3).indexOr(-1, 3), """ List(1, 2, 3).indexOr(-1, 3) """)
display(List(1, 2, 3).sumr, """ List(1, 2, 3).sumr """)
display(List(1, 2, 3).suml, """ List(1, 2, 3).suml """)

display(List(1, 1, 1) ∀ (a ⇒ (a % 2) ≠ 0), """ List(1, 1, 1) ∀ (a ⇒ (a % 2) ≠ 0) """)
display(List(1, 2, 3) ∃ (a ⇒ (a % 2) ≟ 0), """ List(1, 2, 3) ∃ (a ⇒ (a % 2) ≟ 0) """)

display(List(1, 2, 3).maximum, """ List(1, 2, 3).maximum """)
display(List(0D, math.Pi).maximumOf(math.cos), """ List(0D, math.Pi).maximumOf(math.cos) """)
display(List(0D, math.Pi).maximumBy(math.cos), """ List(0D, math.Pi).maximumBy(math.cos) """)

display(List(1, 2, 3).minimum, """ List(1, 2, 3).minimum """)
display(List(0D, math.Pi).minimumOf(math.cos), """ List(0D, math.Pi).minimumOf(math.cos) """)
display(List(0D, math.Pi).minimumBy(math.cos), """ List(0D, math.Pi).minimumBy(math.cos) """)

display(List(1, 2, 3).empty, """ List(1, 2, 3).empty """)
display(nil[Int].empty, """ nil[Int].empty """)

display(List(1, 2, 3).element(1), """ List(1, 2, 3).element(1) """)
display(List(1, 2, 3).element(4), """ List(1, 2, 3).element(4) """)

display(List(2, 4, 1, 3, 5).splitWith(a ⇒ (a % 2) ≟ 0), """ List(1, 2, 3).element(4) """)
display(List(1, 2, 3).selectSplit(a ⇒ (a % 2) ≟ 0), """ List(1, 2, 3).selectSplit(a ⇒ (a % 2) ≟ 0) """)
display(List(1, 2, 3).intercalate(10), """ List(1, 2, 3).intercalate(10) """)
{% endhighlight  %}

## Output
    List(1, 2, 3).foldMap()                                    6
    List(1, 2, 3).foldMap((a: Int) => a.toString)              123
    nil[Int].foldMap()                                         0
    List(1, 2, 3).foldMap1Opt()                                Some(6)
    nil[Int].foldMap1Opt()                                     None
    List(1, 2, 3, 4).foldRight(1)(_ * _)                       24
    List(1, 2, 3).foldMapRight1Opt(a => a + 1)(_ + _)          Some(7)
    nil[Int].foldMapRight1Opt(a => a + 1)(_ + _)               None
    List(1, 2, 3).foldRight1Opt(_ + _)                         Some(6)
    nil[Int].foldRight1Opt(_ + _)                              None
    List(1, 2, 3, 4).foldRight(1)(_ * _)                       2
    List(1, 2, 3, 4).foldRight(1)(_ * _)                       -6
    List(1, 2, 3).foldRightM(0)((a, b) ⇒ Option(a + b))        Some(6)
    List(1, 2, 3).foldRightM(0)((a, b) ⇒ Option(a + b))        Some(123)
    List(1, 2, 3).concatenate                                  6
    List(1, 2, 3).length                                       3
    List(1, 2, 3).index(0)                                     Some(1)
    List(1, 2, 3).index(3)                                     None
    List(1, 2, 3).indexOr(-1, 0)                               1
    List(1, 2, 3).indexOr(-1, 3)                               -1
    List(1, 2, 3).sumr                                         6
    List(1, 2, 3).suml                                         6
    List(1, 1, 1) ∀ (a ⇒ (a % 2) ≠ 0)                          true
    List(1, 2, 3) ∃ (a ⇒ (a % 2) ≟ 0)                          true
    List(1, 2, 3).maximum                                      Some(3)
    List(0D, math.Pi).maximumOf(math.cos)                      Some(1.0)
    List(0D, math.Pi).maximumBy(math.cos)                      Some(0.0)
    List(1, 2, 3).minimum                                      Some(1)
    List(0D, math.Pi).minimumOf(math.cos)                      Some(-1.0)
    List(0D, math.Pi).minimumBy(math.cos)                      Some(3.141592653589793)
    List(1, 2, 3).empty                                        false
    nil[Int].empty                                             true
    List(1, 2, 3).element(1)                                   true
    List(1, 2, 3).element(4)                                   false
    List(1, 2, 3).element(4)                                   List(NonEmptyList(2, 4), NonEmptyList(1, 3, 5))
    List(1, 2, 3).selectSplit(a ⇒ (a % 2) ≟ 0)                 List(NonEmptyList(2))
    List(1, 2, 3).intercalate(10)                              26
