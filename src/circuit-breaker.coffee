# Copyright(c) 2015 Christopher Rueber <crueber@gmail.com>
# MIT Licensed

CircuitBreakerTimeout = require './circuit-breaker-timeout'


class SingleUseCircuitBreaker
  threshold: 4
  decay_timeout: 1000
  switch_timeout: 5000
  status: 'closed' # or open
  decay_rate: 2
  error_checker: (e) -> e
  debug: (message) -> console.log "Circuit Breaker: #{message}"

  constructor: (options) ->
    if typeof options is 'object'
      @[key] = options[key] for key of options 
    @attempts = 0

  is_closed: => @status is 'closed'
  is_open: => @status is 'open'

  after_switch_callback: =>
    @debug 'Successful', arguments

  cancel: =>
    clearTimeout @decay_timer if @decay_timer
    clearTimeout @switch_timer if @switch_timer

  execute: =>
    @execute = ->
      throw new Error("A circuit breaker cannot be reused with new functions.")

    if typeof arguments[arguments.length - 1] is 'function'
      after_switch_callback = arguments[arguments.length - 1]
      @after_switch_callback = =>
        @after_switch_callback = -> {}
        after_switch_callback.apply(@, arguments)

    @switch_function = arguments[0] if typeof arguments[0] is 'function'
    throw new Error('Must specify the switch function at a minimum.') unless @switch_function
    @_execute()

  _execute: =>
    @switch_timer = setTimeout @_handle_switch, @switch_timeout, new CircuitBreakerTimeout()
    @switch_function @_handle_switch

  _handle_switch: (error) =>
    @cancel()

    @attempts += 1

    if @error_checker error
      @debug error
      if @attempts > @threshold
        @status = 'open'
        return @after_switch_callback(@status, @)
      @decay_timer = setTimeout @_execute, @_decay_time()
    else
      @after_switch_callback.apply(@, arguments)

  _decay_time: => @decay_timeout * Math.pow(@decay_rate, @attempts)

module.exports = SingleUseCircuitBreaker
