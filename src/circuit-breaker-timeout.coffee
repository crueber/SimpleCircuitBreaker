# Copyright(c) 2015 Christopher Rueber <crueber@gmail.com>
# MIT Licensed

class CircuitBreakerTimeout extends Error
  name: 'MyError'
  message: 'Circuit Breaker Timed Out'
  constructor: (@message) ->


module.exports = CircuitBreakerTimeout
