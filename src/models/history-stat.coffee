Spine    = require "spine"


class HistoryStat extends Spine.Model
  @configure "HistoryStat",
    "date",
    "type",
    "value"

  # @extend Spine.Model.Ajax
  @url: "/jobs"

  date: (date) ->
    @id = date if date
    @id


module.exports = HistoryStats
