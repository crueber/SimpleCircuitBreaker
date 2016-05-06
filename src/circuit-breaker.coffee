# Copyright(c) 2015 Christopher Rueber <crueber@gmail.com>
# MIT Licensed

CircuitBreakerTimeout = require './circuit-breaker-timeout'


class SingleUseCircuitBreaker
  threshold: 4
  decay_timeout: 1000
  switch_timeout: 5000
  error_checker: null
  decay_rate: 2

  debug: (message) -> console.log "Circuit Breaker: #{message}"

  constructor: (options) ->
    if typeof options is 'object'
      @[key] = options[key] for key of options 
    @attempts = 0

  execute: =>
    @execute = ->
      return throw new Error("A circuit breaker cannot be reused with new functions.")
    after_switch_callback = if typeof arguments[arguments.length - 1] is 'function' then arguments[arguments.length - 1] else @default_after
    @after_switch_callback = =>
      @after_switch_callback = -> {}
      after_switch_callback.apply(@, arguments)

    @switch_function = arguments[0] if typeof arguments[0] is 'function'
    return throw new Error('Must specify the switch function at a minimum.') unless @switch_function
    @_execute()

  _execute: =>
    @switch_timer = setTimeout @_handle_timeout, @switch_timeout
    @switch_function(@_handle_switch)

  default_after: =>
    @debug 'Circuit Breaker: Successful', arguments

  cancel: =>
    clearTimeout @decay_timer if @decay_timer
    clearTimeout @switch_timer if @switch_timer

  _handle_timeout: =>
    @_handle_switch new CircuitBreakerTimeout()

  _handle_switch: (error) =>
    @cancel()

    error = @error_checker(error) if @error_checker

    if error
      @debug(error)
      return @after_switch_callback('open', @) if @attempts >= @threshold
      @attempts += 1
      @decay_timer = setTimeout @_execute, @_decay_time()
    else
      @after_switch_callback.apply(@, arguments)

  _decay_time: => @decay_timeout * Math.pow(@decay_rate, @attempts)


module.exports = SingleUseCircuitBreaker
