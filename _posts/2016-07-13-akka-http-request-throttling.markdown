---
tags: scala opensource
---

Akka Http is a great framework for rest microservices and here at [Ad Hoc Labs](http://www.burnerapp.com/){:target="_blank"} we're slowly migrating from Spray to Akka Http. Since we use Spray extensively we ended up having utility classes to complement some functionality here and there or shared in a common jar with other utility classes. With Akka Http we want to keep things little more clean and reduce boilerplate with high level constructs. We decided to start a new project named [akka-http-contrib](https://github.com/adhoclabs/akka-http-contrib){:target="_blank"} that will host all akka http functionality that we're building that's not already in akka-http project. We recently open sourced it since other community members will find it helpful and hopefully will contribute also.

First functionality we needed for a new project we started with Akka Http was to introduce throttling for some endpoints. We didn't want to write boilerplate for each endpoint we want to introduce throttling for but instead we wanted to be able to introduce throttling for any endpoint by adding it to [typesafe config](https://github.com/typesafehub/config){:target="_blank"}. Basically we wanted a directive that will wrap the routes and when request comes in, depending on the config and thresholds, either let the route execute or complete the request with 429 - Too Many Requests and prevent the route from being executed. This at high level, which should handle most of the use cases but we also wanted to have it extensible enough that whenever there is a special usecase it still can be handled by writing little code.

<!--more-->

In order to achieve both goals we decided to design `throttle` directive the following way where it takes setting:

{% highlight scala %}
trait ThrottleDirective {
  def throttle(implicit settings: ThrottleSettings)
}
{% endhighlight %}

See [ThrottleDirective.scala](https://github.com/adhoclabs/akka-http-contrib/blob/master/src/main/scala/co/adhoclabs/akka/http/contrib/throttle/ThrottleDirective.scala){:target="_blank"}, where settings is:

{% highlight scala %}
trait ThrottleSettings {
  def shouldThrottle(request: HttpRequest): Future[Boolean]
  def onExecute(request: HttpRequest): Future[Unit]
}
{% endhighlight %}

see [package.scala](https://github.com/adhoclabs/akka-http-contrib/blob/master/src/main/scala/co/adhoclabs/akka/http/contrib/throttle/package.scala){:target="_blank"}

This would be the low level api. Throttle directive delegates the decision making to settings, weather a route should be executed or not. Which in turn takes the http request and returns Future\[Boolean\]. And when route is executed it calls `onExecute` callback to let the implementation know that it was executed \(to increment a counter for example\). This model should be very extensible since decision maker is plugable and it will get the entire http request and return a boolean.

On top of this model we created the high level api that allows us to add throttling by adding it to the config file. Let's start with the configuration:

{% highlight scala %}
akka.http.contrib {
  throttle {
    enabled = true
    endpoints = [
      {
        method = "POST"
        pattern = "[REGEX MATCHING THE REQUEST URL]"
        window = 2 m
        allowed-calls = 2
        throttle-period = 10 m
      }
    ]
  }
}
{% endhighlight %}

All the configuration is under `akka.http.contrib.throttle` namespace. `enabled` is a convenience flag that allows us to disable throttling without removing all the endpoint configurations. To introduce throttling of an endpoint we add a new config in `endpoints`. It has the http `method`, `pattern` which is a regex matching the url \(open to a PR to have play style routes support instead of regex\), `allowed-calls` in a given `window` of time and optional `throttle-period` that prevents the endpoint form being called for specified period of time if `allowed-calls` was reached in a given `window`. Essentially it's a way to increase throttling time if needed. Also there is configuration for storage where the counters will be stored. We use redis but other storages can easily be implemented and wired in config file with `default-store`.

Once we have the configuration all we need to do is to bring implicit throttle settings into the scope and wrap our routes in `throttle` directive:

{% highlight scala %}
implicit val throttleSettings = MetricThrottleSettings.fromConfig

Http().bindAndHandle(
  throttle.apply(routes),
  httpInterface,
  httpPort
)
{% endhighlight %}

As you can see we bring the implicit throttle settings into the scope by calling `MetricThrottleSettings.fromConfig`. I guess I need to explain what `MetricThrottleSettings` is. It's an abstract trait that extends `ThrottleSettings` explained above that brings the concept of metrics \(like maximum number of calls, given time window, number of calls an endpoint got, etc in a data store\). It implements `shouldThrottle` and `onExecute` from `ThrottleSettings` and introduces `store` and `endpoints` new abstract methods. `MetricThrottleSettings.fromConfig` returns and implementation of `MetricThrottleSettings` \(which in it's turn is a `ThrottleSettings`\) that implements `store` and `endpoints` abstract methods using the information specified in the config file.

See [throttle package](https://github.com/adhoclabs/akka-http-contrib/tree/master/src/test/scala/co/adhoclabs/akka/http/contrib/throttle){:target="_blank"} for more information on those abstractions.

As always, pull requests are welcome.

