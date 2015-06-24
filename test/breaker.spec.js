var sinon = require("sinon")
var should = require("should")
require("should-sinon")
var CircuitBreaker = require('../lib/index')

describe('CircuitBreaker', function(){

  it('should survive the basic use case', function (done) {
    var switch_fn = function (callback) { 
      callback(null, true)
    } 
    var after_fn_no_error = function (error, arg) {
      should(error).be.exactly(null)
      arg.should.equal(true)
      done()
    }
    new CircuitBreaker({}).execute(switch_fn, after_fn_no_error)
  })

  it('should survive two errors thrown', function (done) {
    var logger = sinon.spy()
    var attempts = 0
    var switch_fn = function (callback) { 
      attempts += 1
      callback(attempts == 3 ? null : true, true)
    } 
    var after_fn_no_error = function (error, arg) {
      should(error).be.exactly(null)
      arg.should.equal(true)
      logger.should.have.callCount(2)
      done()
    }
    new CircuitBreaker({decay_timeout: 3, debug: logger}).execute(switch_fn, after_fn_no_error)
  })

  it('should timeout after passing the switch time', function (done) {
    var logger = sinon.spy()
    var attempts = 0
    var switch_fn = function (callback) { 
      attempts += 1
      if (attempts == 2)
        callback(null, true)
    } 
    var after_fn_no_error = function (error, arg) {
      should(error).be.exactly(null)
      arg.should.equal(true)
      logger.should.have.callCount(1)
      done()
    }
    new CircuitBreaker({decay_timeout: 3, switch_timeout: 10, debug: logger}).execute(switch_fn, after_fn_no_error)
  })

  it('should timeout and send an error after all possible attempts have been used', function (done) {
    var logger = sinon.spy()
    var attempts = 0
    var switch_fn = function (callback) { 
      attempts += 1
    } 
    var after_fn_no_error = function (error, arg) {
      should(attempts).be.equal(5)
      should(error).be.a.error
      logger.should.have.callCount(5)
      done()
    }
    new CircuitBreaker({decay_timeout: 3, decay_rate: 1.2, switch_timeout: 3, debug: logger}).execute(switch_fn, after_fn_no_error)
  })

  it('should throw an error if you try to reuse the class', function (done) {
    var switch_fn = function (callback) { 
      callback(null, true)
    } 
    var after_fn_no_error = function (error, arg) {
      should(error).be.exactly(null)
      arg.should.equal(true)
      try {
        cb.execute(switch_fn, function () {})
      } catch (e) {
        e.message.should.startWith('A circuit breaker cannot')
        done()
      }
    }
    var cb = new CircuitBreaker({})
    cb.execute(switch_fn, after_fn_no_error)    
  })
})
