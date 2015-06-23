Simple Circuit Breaker
======================
[![Node.js Version][node-version-image]][node-version-url]

[![NPM](https://nodei.co/npm/data-serializer.png?downloads=true)](https://nodei.co/npm/simple-circuit-breaker/)

Written in spite of all of the other circuit breaker libraries because the other patterns I've found. They appear not to be interested in the design pattern, but rather the architectural one. Which is great and dandy, but doesn't handle the need of basic circuit-oriented retry logic.

## Circuit Breaking

What is this pattern? It works like this:

* Execute this function with a resolution callback. Circuit is closed. Did the function call the callback and not timeout before it did?
  * Yes -> Move on to the second function, with null for the first argument and any other args provided in the callback.
  * No -> Has the number of attempts threshold been met?
    * Yes -> Circuit is open. Call second function with threshold error and circuit braker as args.
    * No -> Increment the number of attempts. Wait (timeout*(decay_rate^attempts))ms
      * Try again by going back up to the top of this chain.

A simple example:

```javascript
var options = { threshold: 6 } 
var switch  = function (callback() { callback(); }
var after   = function (error, args...) {}
new CircuitBreaker(options).execute(switch, after);
```

For further details, I would recommend glancing at the tests!


# License

The MIT License

Copyright (c) 2015 Christopher Rueber <crueber@gmail.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the 'Software'), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

[npm-image]: https://img.shields.io/npm/v/data-serializer.svg?style=flat
[node-version-image]: https://img.shields.io/badge/node.js-%3E%3D_10.0-brightgreen.svg?style=flat
[node-version-url]: http://nodejs.org/download/
