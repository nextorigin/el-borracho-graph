Spine    = require "spine"
__       = require "spine-awaitajax"


class HistoryStat extends Spine.Model
  @configure "HistoryStat",
    "queue",
    "date",
    "type",
    "value",
    "count"

  @extend Spine.Model.Ajax
  @url: -> "#{@baseUrl}/history"

  value: (value) ->
    @count = Number value or 0


module.exports = HistoryStat
