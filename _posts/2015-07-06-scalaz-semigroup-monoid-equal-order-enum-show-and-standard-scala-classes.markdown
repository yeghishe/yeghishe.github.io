---
tags: scala scalaz
title: Scalaz Semigroup, Monoid, Equal, Order, Enum, Show and Standard Scala Classes
---

Scalaz has so many abstractions and higher kinds that model lot of
algebraic structures, monads, hight level types to generalize common structures
and offers lot of tools that work with those abstractions.
In this article I wanted to cover the very basics. Ones we see every day
in standard scala library. What the anomalies of basic types are in standard
scala library, what are the comment things between them that can be made
generic, how to use scalaz with standard classes defined in scala library.

## [Semigroup](#semigroup)
*Semigroup* brings *append* operation and it
should be associative. We see in standard library append operation is
everywhere, numeric types, strings, lists, etc. All have a way to add one
instance to the other, for number types it would be the *+* function and
for lists *++*. Scalaz has syntactic sugar, having *|+|, mappend, ⊹* to all
be same as *append*. I particularly like *⊹*. We say if a and b are from same
semigroup then we can append a to by by doing *a ⊹ b*. Cleans things up little
bit for sure, we don't say if a and b are strings it's *+*, if a and b are
lists it's *++*.

## [Monoid](#monoid)
Next comes *Monoid*. *Monoid* is a *Semigroup* and it also has zero element.
There is left and right identity with zero element, meaning:
{% highlight scala %}
∅ ⊹ a = a ⊹ ∅
{% endhighlight %}

Again scalaz defines few synonyms for *zero*, *mzero* and *∅*. In scala library
we already see monoids. For integer a, *a + 0 = 0 + a*, for string a
*a + "" = "" + a*, for list a, *a ++ Nil = Nil ++ a*, etc.

So how do we make standards classes to be scalaz semigroups or monoids since
those already have associative append and zero element. Having that
ability we can say just write ∅ instead or 0, "", Nil, etc.
And ⊹ instead of +, ++, etc. Scalaz defines *Semigroup[F]* and *Monoid[F]* as
traits, if we say *F* type is a monoid we need to extend *Monoid[F]* and
provide implementation for *append* and *zero* methods, associative and identity lows
should also be satisfied. Luckily for us scalaz defines instances that provide
implementation for unit, boolean, byte, char, int, long, float, double, string,
option, list, future and many more under *scalaz.std* package and those are
implicit objects so bringing those in scope will make a particular type to act
as monoid. Just be careful what instance to bring in scope, for example
integer is a monoid over 0 and + operation and also over 1 and * operation,
boolean is a monoid for conjunction and disjunction.

## [Equal](#equal)
*Equal* is another one that we say most often in scala library but equal on
it's own has lot for variations, starting from java's *==* and
equal gotchas, scala's *==* not being type safe and so many
libraries in scala word defining *===*. And it's fair, to be completely
honest and it all depends how we define what a equals to b means.
Before we delve deep to see what scalaz has to say about equal, let's see how
scala's *==* operator isn't type safe:
{% highlight scala %}
val a = 1
val b = "1"
a == b
{% endhighlight %}

This actually compiles but will return false, looks like common bug one can make
to me. So there is basically equal function defined which is more than happy
to take two arguments of different types. So solution seems to be to have
some version of equal method that will force that both parameters are of the
same type and it will make it type safe.

scalaz defines *Equal[F]* trait, which has *def equal(f1: F, f2: F): Boolean*,
equal method. Both parameters are of type F. Also equal has to be

* *commutative* (if f1 equals to f2 then f2 should be equal to f1)
* *reflexive* (f is equal to itself)
* *transitive* (if f1 equals f2 and f2 equals to f3 then f1 equals to f3) 

Defining equal method well automatically get not equal (it's same as !equal),
scalaz defines *===, ≟* as synonyms for equal, and *=/=* and *≠* for
not equal.

## [Order](#order)
*Order[F]* extends *Equal[F]* and brings in order function:
{% highlight scala %}
def order(x: F, y: F): Ordering 
{% endhighlight %}

Where *Ordering* is a sealed abstract class with 
*Ordering.LT, Ordering.GT and Ordering.EQ* implementations. Providing a
definition for order we get following for free from Order trait and OrderOps
class:

* **<**, **lt** and **lessThan**
* **<=**, **lte** and **lessThanOrEqual**
* **\>**, **gt** and **greaterThan**
* **\>=**, gte and **greaterThanOrEqual**
* **min**
* **max**
* **cmp**, **?\|?** and **order**

## [Enum](#enum)
Another one that's useful is *Enum[F]* which extends *Order[F]* and
defines *succ, pred* to get successor and predecessor of value *f* of type *F*.
*succn, predn* to get nth successor and predecessor of value *f* of type *F*.
*min* and *max* functions for minimum and maximum values. We also get following
synonyms and derived functions:

* **succ**
* **-+-** and **succn**
* **succx**
* **pred**
* **---** and **predn**
* **predx**
* **from**
* **fromStep**
* **\|=>** and **fromTo**
* **\|->** and **fromToL**
* **\|==>** and **fromStepTo**
* **\|-->** and **fromStepToL**

## [Show](#show)
Next abstraction I want to cover from scalaz is *Show[F]*. *Show[F]* defines
*shows* method, which having *f* instance of *F* will return it's string
representation. Scalaz defines *print* and *println* derived functions to
*ShowOps* class which are implemented as:
{% highlight scala %}
final def show: Cord = F.show(self)
final def shows: String = F.shows(self)
final def print: Unit = Console.print(shows)
final def println: Unit = Console.println(shows)
{% endhighlight %}

## Implicit instances for integer and string
Let's have a look to see how implicit objects for integer and string I mentioned
before are implemented in scalaz. As we can see integer is a monoid,
show and enum, where string is monoid, show, equal and order.
String isn't an enum because successor and predecessor functions don't make
much sense for strings. Also those implementations give good idea about
how to implement those traits for our own classes.

{% highlight scala %}
implicit val intInstance: Monoid[Int] with Enum[Int] with Show[Int] = new Monoid[Int] with Enum[Int] with Show[Int] {
  override def shows(f: Int) = f.toString
  
  def append(f1: Int, f2: => Int) = f1 + f2
  
  def zero: Int = 0
  
  def order(x: Int, y: Int) = if (x < y) Ordering.LT else if (x == y) Ordering.EQ else Ordering.GT
  
  def succ(b: Int) = b + 1
  def pred(b: Int) = b - 1
  override def succn(a: Int, b: Int) = b + a
  override def predn(a: Int, b: Int) = b - a
  override def min = Some(Int.MinValue)
  override def max = Some(Int.MaxValue)
  
  override def equalIsNatural: Boolean = true
}
{% endhighlight %}

{% highlight scala %}
implicit object stringInstance extends Monoid[String] with Show[String] with Equal[String] with Order[String] with IsEmpty[({ type λ[α] = String })#λ] {
  type SA[α] = String
  def append(f1: String, f2: => String) = f1 + f2
  def zero: String = ""
  override def show(f: String) = '"' + f + '"'
  def order(x: String, y: String) = Ordering.fromInt(x.compareTo(y))
  override def equal(x: String, y: String) = x == y
  override def equalIsNatural: Boolean = true
  def empty[A] = zero
  def plus[A](f1: SA[A], f2: => SA[A]) = f1 + f2
  def isEmpty[A](s: SA[A]) = s == ""
}
{% endhighlight %}
