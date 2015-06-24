Single-use Circuit Breaker
==========================
[![Node.js Version][node-version-image]][node-version-url]

[![NPM](https://nodei.co/npm/singleuse-circuit-breaker.png?downloads=true)](https://nodei.co/npm/singleuse-circuit-breaker/)

This module falls somewhere between timeout/retry logic with backoff, and a circuit breaker. I've found the circuit breaker analogy to be more apt, though it doesn't fall strictly in line with the circuit breaker architectural pattern. 

Circuit-oriented retry logic that backs off.

## On Timeouts, Failures, and Circuit Breaking

The basic pattern works like this:

* Execute a function with a resolution callback, starting with a closed circuit. Did the function call the callback and not timeout before it did?
  * Yes -> Move on to the second provided function, passing the parameters provided in the resolution callback.
  * No -> Has the number of attempts threshold been met?
    * Yes -> Circuit is open. Call second function with threshold error and circuit braker as args.
    * No -> Increment the number of attempts. Wait (timeout*(decay_rate^attempts))ms
      * Try again by going back up to the top of this chain.

A simple example:

```javascript
var options = { threshold: 6 } 
var switch_fn = function (callback) { 
  callback(null, true)
} 
var after_fn_no_error = function (error, arg) {
  carryOn()
}
new CircuitBreaker(options).execute(switch_fn, after_fn_no_error)
```

For further details, I would recommend glancing at the tests!


# License

The MIT License

Copyright (c) 2015 Christopher Rueber <crueber@gmail.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the 'Software'), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

[npm-image]: https://img.shields.io/npm/v/singleuse-circuit-breaker.svg?style=flat
[node-version-image]: https://img.shields.io/badge/node.js-%3E%3D_10.0-brightgreen.svg?style=flat
[node-version-url]: http://nodejs.org/download/
