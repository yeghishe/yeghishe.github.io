---
title:  "Testing styles in ScalaTest"
tags: scala akka
---

Over time different libraries brought different testing styles, jUnit, xUnit,
Rspec, ert. Nowadays since many people have different backgrounds and
different taste when it comes to writing unit tests, most test libraries
offer many testing styles and *ScalaTest* isn't an exception. To me there are
three groups of testing styles. One would the traditional jUnit, xUnit
style where you define a test class and unit tests are methods in that test
class, you also define *setUp* and *tearDown* methods that must be called
before and after each unit test. Of course there are also *setUp* and *tearDown*
versions that run once per test suit but I don't want to talk more about it here.
I must admit that this isn't my favorite style and here is why. I like to unit
test aggressively without skipping any business cases instead of just
relying on code coverage and saying my other test already is hitting those
lines. If I have a class with many methods I write many unit tests for each
method, an example would be when a method takes a parameter and based on
different values for those parameters it does different things, of course we
want to have multiple unit tests for that method to cover all business cases
for that method. So this alone groups unit tests in a test class by functions,
another thing is that most likely unit tests for function A will share some
setup logic. This testing style forces as to put setup code for all unit tests for function A in
setup method, and when we have like 10 such functions, setup method will have
the setup code for all those function which will make it long, hard to read,
also it will be extremely hard to tell which setup code is for which unit test.
Another option is to define setup code in each unit test with isn't really a
good idea since one we'll have duplicated code and unit tests now will be
longer than they need to be and hard to understand. I see some people like to
solve this problem by moving this common code into private methods. Although this
solves code duplication problem, also makes unit tests shorter but it introduced
another big problem. When I read a unit test I want to know what the method is
doing in 2 seconds, unit tests are documentations right. Now you come across
this private method call, you have to find it's implementation, read the ugly
code there and jump back to continue reading what that unit test is trying to
test. It's a nightmare to me, I call that unit test anything but readable and
I sure don't want to be one maintain that code.
Before I moved to next type of unit tests, I must mention what styles ScalaTest
is offering here. *FunSuite* and *FlatSpec*, you can read more about those in
ScalaTest documentation. Both are flat as mentioned, one is more like jUnit,
other is more like xUnit.

Next group is property based testing or table based testing. I find
this useful to test utility methods I write. Let's say we're writing absolute
method but before doing it we want to have following tests:

* absolute(0) = 0
* absolute(1) = 1
* absolute(-1) = 1

If we write this in flat of BDD style we have to write 3 unit test methods.
What I like about table based testing is that we can define a table with
all possible inputs and outputs and we write one unit test that just iterates
over those. Less code is always a good thing right?
Here is an example how this can be done in Scala test:

{% gist yeghishe/267ce3e7f5b64d04262c %}

And third group is BDD style. What I like about this isn't actually the BDD
aspect, I like that you structure your tests hierarchically instead of flat.
In my example about multiple unit tests per method, logical groups become
nodes in that hierarchy and the root is the name of class we're testing.
Another nice thing about this is that each group can have it's setup logic.
And that hierarchy doesn't have to be two levels deep, it can go as deep as
you want.
ScalaTest has following testing styles for BDD. *FunSpec*, *WordSpec*,
*FreeSpec*, *Spec* and *FeatureSpec*. You can read about those in ScalaTest
documentation, I will cover *WordSpec* here since it's my personal choice.
Let's say we're working on some code where we need to create user in
db based on user's facebook token. There is *FacebookClient* which has
*getUserInfo* method that returns future of option user, it will have user when
token is valid and it will return None if token isn't valid for the user and
we're not able to get user info from facebook. Also we have *Db* trait with
*saveUser* and *findUserById* methods. Both return future of option. If we're not
able to save user to db we return None, if we are, we return user with id
generated from db. For find user we return user if we find it and we return
None when user isn't found. Those are the cases we want to test:

* For *createUser*, it should call db to save user and return saved user when token is a valid facebook token
* For *createUser*, it should NOT call db if token isn't valid and return None
* For *createUser*, it should return None if unable to save to db
* for *getUser*, it should return user if user is found in db
* for *getUser*, it should return None user isn't found in db


Here are the tests in ScalaTest using *WordSpec* and the implementation:

{% gist yeghishe/87d85afa1e1d0bc172f0 %}

As you can see tests are organized hierarchically, setup code for all the tests is in test class,
setup code for each group is in it's group, and setup for each test is in it's test. This is nice and
clean and very readable. Unfortunately this patter doesn't always work, mainly when you need to do
clean up for each test. One example would be unit testing actors.
Let's say instead of having this *FacebookClient*, *Db*, *UserManager* and future model we have actors:
*FacebookActor*, *DbActor* and *UserActor*. To test *UserActor* we need to have test probes for FacebookActor and
DbActor. We can't put that code outside test functions because we need to create the actors and stop them in every test.
What we can use here though is fixtures in ScalaTest.

{% gist yeghishe/5ae2c8db99fd46abb534 %}

As you can see fixtures makes it as simple as it was. All the setup logic is still where it needs to be
and boilerplate to setup and stop the actor and test probes is centralized.
