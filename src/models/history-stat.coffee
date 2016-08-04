Spine    = require "spine"


class HistoryStat extends Spine.Model
  @configure "HistoryStat",
    "queue",
    "date",
    "type",
    "value"

  # @extend Spine.Model.Ajax
  @url: "/history"

  date: (date) ->
    @id = date if date
    @id


module.exports = HistoryStats
