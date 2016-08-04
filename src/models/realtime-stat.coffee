Spine    = require "spine"


class RealtimeStat extends Spine.Model
  @configure "RealtimeStat",
    "queue",
    "processed",
    "failed"

  @url: "/sse/total"

  @listen: ->
    @source = new EventSource "#{@baseUrl}#{@url}"
    @source.addEventListener "message", @createFromEvent
    @source.addEventListener "error",   @error

  @createFromEvent: (e) =>
    stat   = e.data
    record = new @RealtimeStat stat
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

  previous: ->
    {records} = @constructor
    return null unless records.length > 1
    i = records.indexOf @constructor.irecords[@id]
    records[i - 1].clone()


module.exports = RealtimeStat
