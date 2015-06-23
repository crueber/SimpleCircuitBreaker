# Copyright(c) 2015 Christopher Rueber <crueber@gmail.com>
# MIT Licensed

CircuitBreakerTimeout = require './circuit-breaker-timeout'

###
# How this class is used:
#
# var options = { threshold: 6 } 
# var switch  = function (callback) { callback(); }
# var after   = function (error, args...) {}
# new CircuitBreaker(options).execute(switch, after)
###

class CircuitBreaker
  threshold: 4
  decay_timeout: 1000
  switch_timeout: 5000
  status: 'closed' # or open
  decay_rate: 2

  debug: (message) -> console.log "Circuit Breaker: #{message}"

  constructor: (options) ->
    options = options || {}
    if typeof options is 'object'
      @[key] = options[key] for key of options 
    @attempts = 0

  execute: =>
    unless @exec_args
      @exec_args = Array.prototype.slice.call(arguments) 
      @after_switch_callback = if typeof arguments[arguments.length - 1] is 'function' then @exec_args.pop() else @debug
      @switch_function = @exec_args.shift() if typeof arguments[0] is 'function'
      return throw new Error('Must specify the switch function at a minimum.') unless @switch_function

    @switch_timer = setTimeout @_handle_timeout, @switch_timeout
    @switch_function(@_handle_switch)

  is_closed: => @status is 'closed'
  is_open: => @status is 'open'
  cancel: =>
    @execute = ->
    @_handle_switch = ->
    clearTimeout @decay_timer if @decay_timer
    clearTimeout @switch_timer if @switch_timer
  _handle_timeout: =>
    @_handle_switch new CircuitBreakerTimeout()
  _handle_switch: (error) =>
    clearTimeout @switch_timer if @switch_timer

    if error
      @debug(error)
      @status = 'open' if @attempts >= @threshold
      @attempts += 1
      @_decay()
    else
      @after_switch_callback.apply(@, arguments)
  _decay_time: => @decay_timeout * Math.pow(@decay_rate, @attempts)
  _decay: () =>
    return @after_switch_callback('open', @) if @is_open()
    @decay_timer = setTimeout @execute, @_decay_time()



module.exports = CircuitBreaker
