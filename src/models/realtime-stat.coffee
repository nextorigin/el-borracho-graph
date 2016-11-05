Spine    = require "spine"


class RealtimeStat extends Spine.Model
  @configure "RealtimeStat",
    "queue",
    "completed",
    "failed"

  @url: "/stats/sse"

  @listen: ->
    return if @source
    @source = new EventSource "#{@baseUrl}#{@url}"
    @source.addEventListener "total", @_createFromEvent = @proxy @createFromEvent
    @source.addEventListener "error", @_error = @proxy @error

  @createFromEvent: (e) ->
    try
      stat = @refresh e.data
      @lru()
    catch e
      return @error e

  @stop: ->
    return unless @source
    @source.removeEventListener "total", @_createFromEvent
    @source.removeEventListener "error", @_error
    @source.close()
    delete @source

  @lru: ->
    record.destroy() for record in @records[0..100] if @count() > 10000
    return

  @error: (args...) -> @trigger "error", args...

  save: ->
    @queue     ?= "all"
    @completed ?= 0
    @failed    ?= 0
    @completed  = parseInt @completed if @completed
    @failed     = parseInt @failed if @failed
    super

  previous: ->
    {records} = @constructor
    return null unless records.length > 1
    i = records.indexOf @constructor.irecords[@id]
    records[i - 1].clone()


module.exports = RealtimeStat
