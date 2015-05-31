---
tags: scala scalaz
title: Methods Scalaz Adds To Standard Classes - Integer, String and Boolean
---

In my previous article about Semigroup, Monoid, Equal, Order, Enum and Show
I covered what those are, what method they have and what derived and syntax
sugar methods scalaz bring for them. Also I showed that there are implicit
implementations of those for scala standard classes that once are brought in
scope you'll have access to those. In this article I'm gonna show those
methods in action for integer, string and boolean.

## Integer
    object OperationsIntSnippets extends App {
      import scalaz.std.anyVal.intInstance
      import scalaz.std.int._
      import scalaz.syntax.enum._
      import scalaz.syntax.monoid._
      import scalaz.syntax.show._
    
      display("anyVal.intInstance is Monoid, Enum (Enum is also Order and Order is Equal), Show")
    
      display(heaviside(1), """ heaviside(1) """)
      display(heaviside(-1), """ heaviside(-1) """)
    
      display("MonoidOps")
      display(1 ⊹ 1, """ 1 ⊹ 1 """)
      display(1 ⊹ ∅, """ 1 ⊹ ∅ """)
    
      display("EnumOps")
      display(1.succ, """ 1.succ """)
      display(1 -+- 2, """ 1 -+- 2 """)
      display(1.pred, """ 1.pred """)
      display(1 --- 2, """ 1 -+- 2 """)
      display(1 |-> 10, """ 1 |-> 10 """)
      display(1 |--> (2, 10), """ 1 |--> (2, 10) """)
      println(1 |--> (2, 11), """ 1 |--> (2, 11) """)
    
      display("ShowOps")
      display(1.shows, """ 1.show """)
      1.println
    
      display("EqualOps")
      display(1 ≟ 1, """ 1 ≟ 1 """)
      display(1 ≠ 2, """ 1 ≠ 2 """)
    
      display("OrderOps")
      display(1 lt 1, """ 1 lt 2 """)
      display(2 lte 2, """ 2 lte 2 """)
      display(2 gt 1, """ 2 gt 1 """)
      display(2 gte 2, """ 2 gte 2 """)
      display(1 ?|? 2, """ 1 ?|? 2 """)
      display(1 max 2, """ 1 max 2 """)
      display(1 min 2, """ 1 min 2 """)
    }

### The output
                                  anyVal.intInstance is Monoid, Enum (Enum is also Order and Order is Equal), Show
     heaviside(1)                                               1
     heaviside(-1)                                              0
                                  MonoidOps
     1 ⊹ 1                                                      2
     1 ⊹ ∅                                                      1
                                  EnumOps
     1.succ                                                     2
     1 -+- 2                                                    3
     1.pred                                                     0
     1 -+- 2                                                    -1
     1 |-> 10                                                   List(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
     1 |--> (2, 10)                                             List(1, 3, 5, 7, 9)
    (List(1, 3, 5, 7, 9, 11), 1 |--> (2, 11) )
                                  ShowOps
     1.show                                                     1
    1
                                  EqualOps
     1 ≟ 1                                                      true
     1 ≠ 2                                                      true
                                  OrderOps
     1 lt 2                                                     false
     2 lte 2                                                    true
     2 gt 1                                                     true
     2 gte 2                                                    true
     1 ?|? 2                                                    LT
     1 max 2                                                    2
     1 min 2                                                    1

## String
    object OperationsStringSnippets extends App {
      import scalaz.std.string._
      import scalaz.syntax.monoid._
      import scalaz.syntax.order._
      import scalaz.syntax.show._
      import scalaz.syntax.std.string._
    
      display("stringInstance is Monoid, Show, Order (order is also Equal)")
    
      display("StringOps")
      display("code".plural(0), """ "code".plural(0) """)
    
      display("MonoidOps")
      display("a" ⊹ "b", """ "a" ⊹ "b" """)
      display("hello" ⊹ ∅, """ "hello" ⊹ ∅ """)
    
      display("ShowOps")
      display("abc".shows, """ "abc".show """)
      "abc".println
    
      display("EqualOps")
      display("a" ≟ "a", """ "a" ≟ "b" """)
      display("a" ≠ "b", """ "a" ≠ "b" """)
    
      display("OrderOps")
      display("a" lt "b", """ "a" lt "b" """)
      display("b" lte "b", """ "b" lte "b" """)
      display("b" gt "a", """ "b" gt "a" """)
      display("b" gte "b", """ "b" gte "b" """)
      display("a" ?|? "b", """ "a" ?|? "b" """)
    }

### The output
                                  stringInstance is Monoid, Show, Order (order is also Equal)
                                  StringOps
     "code".plural(0)                                           codes
                                  MonoidOps
     "a" ⊹ "b"                                                  ab
     "hello" ⊹ ∅                                                hello
                                  ShowOps
     "abc".show                                                 "abc"
    "abc"
                                  EqualOps
     "a" ≟ "b"                                                  true
     "a" ≠ "b"                                                  true
                                  OrderOps
     "a" lt "b"                                                 true
     "b" lte "b"                                                true
     "b" gt "a"                                                 true
     "b" gte "b"                                                true
     "a" ?|? "b"                                                LT

## Boolean
    object OperationsBooleanSnippets extends App {
      import scalaz.syntax.std.boolean._
    
      display("StringOps")
      display(true ∧ true, """ true ∧ true """)
      display(true ∧ false, """ true ∧ false """)
      display(false ∧ true, """ false ∧ true """)
      display(false ∧ false, """ false ∧ false """)
    
      display(true ∨ true, """ true ∨ true """)
      display(true ∨ false, """ true ∨ false """)
      display(false ∨ true, """ false ∨ true """)
      display(false ∨ false, """ false ∨ false """)
    
      display(true !|| true, """ true !|| true """)
      display(true !|| false, """ true !|| false """)
      display(false !|| true, """ false !|| true """)
      display(false !|| false, """ false !|| false """)
    
      display(true !&& true, """ true !&& true """)
      display(true !&& false, """ true !&& false """)
      display(false !&& true, """ false !&& true """)
      display(false !&& false, """ false !&& false """)
    
      display(true --> true, """ true --> true """)
      display(true --> false, """ true --> false """)
      display(false --> true, """ false --> true """)
      display(false --> false, """ false --> false """)
    
      display(true <-- true, """ true <-- true """)
      display(true <-- false, """ true <-- false """)
      display(false <-- true, """ false <-- true """)
      display(false <-- false, """ false <-- false """)
    
      display(true <-- true, """ true <-- true """)
      display(true <-- false, """ true <-- false """)
      display(false <-- true, """ false <-- true """)
      display(false <-- false, """ false <-- false """)
    
      display(true ⇐ true, """ true ⇐ true """)
      display(true ⇐ false, """ true ⇐ false """)
      display(false ⇐ true, """ false ⇐ true """)
      display(false ⇐ false, """ false ⇐ false """)
    
      display(true ⇐ true, """ true ⇐ true """)
      display(true ⇐ false, """ true ⇐ false """)
      display(false ⇐ true, """ false ⇐ true """)
      display(false ⇐ false, """ false ⇐ false """)
    
      display(true ⇏ true, """ true ⇏ true """)
      display(true ⇏ false, """ true ⇏ false """)
      display(false ⇏ true, """ false ⇏ true """)
      display(false ⇏ false, """ false ⇏ false """)
    
      display(true ⇍ true, """ true ⇍ true """)
      display(true ⇍ false, """ true ⇍ false """)
      display(false ⇍ true, """ false ⇍ true """)
      display(false ⇍ false, """ false ⇍ false """)
    
      true.when(println("when"))
      false.unless(println("unless"))
    
      display(true.fold("a", "b"), """ true.fold("a", "b") """)
      display(false.fold("a", "b"), """ false.fold("a", "b" """)
    
      display(false ? "a" | "b", """ false ? "a" | "b" """)
      display(true ? "a" | "b", """ true ? "a" | "b" """)
    
      display(false.option(1), """ false.option(1) """)
      display(true.option(1), """ true.option(1) """)
    
      display(false.lazyOption(1), """ false.lazyOption(1) """)
      display(true.lazyOption(1), """ true.lazyOption(1) """)
    
      display(false either "a" or "b", """ false either "a" or "b" """)
      display(true either "a" or "b", """ true either "a" or "b" """)
    
      {
        import scalaz.std.anyVal.intInstance
        display(true ?? 1, """ true ?? 1 """)
        display(false ?? 1, """ false ?? 1 """)
    
        display(true !? 1, """ true !? 1 """)
        display(false !? 1, """ false !? 1 """)
      }
    
      {
        display("anyVal.booleanInstance extends Enum[Boolean] with Show[Boolean]")
        import scalaz.std.anyVal.booleanInstance
        import scalaz.syntax.enum._
        display("EnumOps")
        display(true.succ, """ true.succ """)
        display(true -+- 2, """ true -+- 2 """)
        display(true.pred, """ true.pred """)
        display(true --- 2, """ true -+- 2 """)
    
        import scalaz.syntax.show._
        display("ShowOps")
        display(true.shows, """ true.show """)
        true.println
      }
    
      display("Boolean isn't Monoid but BooleanDisjunction and BooleanConjunction are")
    
      {
        import scalaz.Tags.Conjunction
        import scalaz.std.anyVal.booleanConjunctionNewTypeInstance
        import scalaz.syntax.monoid._
    
        display(Conjunction(true) ⊹ Conjunction(true), """ Conjunction(true) ⊹ Conjunction(true) """)
        display(Conjunction(true) ⊹ Conjunction(false), """ Conjunction(true) ⊹ Conjunction(false) """)
        display(Conjunction(false) ⊹ Conjunction(true), """ Conjunction(false) ⊹ Conjunction(true) """)
        display(Conjunction(false) ⊹ Conjunction(false), """ Conjunction(true) ⊹ Conjunction(false) """)
        display(Conjunction(true) ⊹ ∅, """ ∅[Conjunction] """)
      }
    
      {
        import scalaz.Tags.Disjunction
        import scalaz.std.anyVal.booleanDisjunctionNewTypeInstance
        import scalaz.syntax.monoid._
    
        display(Disjunction(true) ⊹ Disjunction(true), """ Disjunction(true) ⊹ Disjunction(true) """)
        display(Disjunction(true) ⊹ Disjunction(false), """ Disjunction(true) ⊹ Disjunction(false) """)
        display(Disjunction(false) ⊹ Disjunction(true), """ Disjunction(false) ⊹ Disjunction(true) """)
        display(Disjunction(false) ⊹ Disjunction(false), """ Disjunction(true) ⊹ Disjunction(false) """)
        display(Disjunction(true) ⊹ ∅, """ ∅[Disjunction] """)
      }
    }

### The output
                                  StringOps
     true ∧ true                                                true
     true ∧ false                                               false
     false ∧ true                                               false
     false ∧ false                                              false
     true ∨ true                                                true
     true ∨ false                                               true
     false ∨ true                                               true
     false ∨ false                                              false
     true !|| true                                              false
     true !|| false                                             false
     false !|| true                                             false
     false !|| false                                            true
     true !&& true                                              false
     true !&& false                                             true
     false !&& true                                             true
     false !&& false                                            true
     true --> true                                              true
     true --> false                                             false
     false --> true                                             true
     false --> false                                            true
     true <-- true                                              true
     true <-- false                                             true
     false <-- true                                             false
     false <-- false                                            true
     true <-- true                                              true
     true <-- false                                             true
     false <-- true                                             false
     false <-- false                                            true
     true ⇐ true                                                true
     true ⇐ false                                               true
     false ⇐ true                                               false
     false ⇐ false                                              true
     true ⇐ true                                                true
     true ⇐ false                                               true
     false ⇐ true                                               false
     false ⇐ false                                              true
     true ⇏ true                                                false
     true ⇏ false                                               true
     false ⇏ true                                               false
     false ⇏ false                                              false
     true ⇍ true                                                false
     true ⇍ false                                               false
     false ⇍ true                                               true
     false ⇍ false                                              false
    when
    unless
     true.fold("a", "b")                                        a
     false.fold("a", "b"                                        b
     false ? "a" | "b"                                          b
     true ? "a" | "b"                                           a
     false.option(1)                                            None
     true.option(1)                                             Some(1)
     false.lazyOption(1)                                        LazyNone
     true.lazyOption(1)                                         LazySome(<function0>)
     false either "a" or "b"                                    -\/(b)
     true either "a" or "b"                                     \/-(a)
     true ?? 1                                                  1
     false ?? 1                                                 0
     true !? 1                                                  0
     false !? 1                                                 1
                                  anyVal.booleanInstance extends Enum[Boolean] with Show[Boolean]
                                  EnumOps
     true.succ                                                  false
     true -+- 2                                                 true
     true.pred                                                  false
     true -+- 2                                                 true
                                  ShowOps
     true.show                                                  true
    true
                                  Boolean isn't Monoid but BooleanDisjunction and BooleanConjunction are
     Conjunction(true) ⊹ Conjunction(true)                      true
     Conjunction(true) ⊹ Conjunction(false)                     false
     Conjunction(false) ⊹ Conjunction(true)                     false
     Conjunction(true) ⊹ Conjunction(false)                     false
     ∅[Conjunction]                                             true
     Disjunction(true) ⊹ Disjunction(true)                      true
     Disjunction(true) ⊹ Disjunction(false)                     true
     Disjunction(false) ⊹ Disjunction(true)                     true
     Disjunction(true) ⊹ Disjunction(false)                     false
     ∅[Disjunction]                                             true
