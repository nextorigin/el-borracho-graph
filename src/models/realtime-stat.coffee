Spine    = require "spine"


class RealtimeStat extends Spine.Model
  @configure "RealtimeStat",
    "processed",
    "failed"




module.exports = RealtimeStat
