Spine    = require "spine"


class RealtimeStat extends Spine.Model
  @configure "RealtimeStat",
    "queue",
    "completed",
    "failed"

  @url: "/stats/sse"

  @listen: ->
    @source = new EventSource "#{@baseUrl}#{@url}"
    # @source.addEventListener "message", @createFromEvent
    @source.onmessage = @createFromEvent
    @source.addEventListener "error",   @error

  @createFromEvent: (e) =>
    try
      stat = JSON.parse e.data
    catch e
      return @error e
    record = new this stat
    record.save()
    @lru()

  @stop: =>
    return unless @source
    @source.removeEventListener "message", @createFromEvent
    @source.removeEventListener "error",   @error

  @lru: ->
    record.destroy() for record in @records[0..100] if @count() > 10000
    return

  @error: (args...) => @trigger "error", args...

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
