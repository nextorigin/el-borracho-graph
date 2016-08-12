Spine    = require "spine"
Maquette = require "maquette"
Graph    = require "./realtime-graph"


class HistoryGraphController extends Spine.Controller
  logPrefix: "(ElBorracho:HistoryGraph)"

  keepLegend: ->
    clearTimeout @_legendTimeout if @_legendTimeout

  timeoutLegend: ->
    @_legendTimeout = setTimeout @clearLegend, 3000

  clearLegend: =>
    @legend.fadeOut 300, => @legend.empty().show 1

  events:
    "mouseover":                             "keepLegend"
    "mouseout":                              "timeoutLegend"

  constructor: ({baseUrl, completedLabel, failedLabel}) ->
    @log "constructing"

    super

    @legend = $ "figcaption#history-legend"

    @Store      = require "../models/history-stat"
    @View       = require "../views/history-graph"
    @view       = new @View {@el, @legend, completedLabel, failedLabel}

    @Store.baseUrl = baseUrl
    @Store.on "error",  @error
    @Store.on "refresh", @render

    @default()

  render: =>
    @log "rendering"
    completed = @Store.findAllByAttribute "type", "completed"
    failed    = @Store.findAllByAttribute "type", "failed"

    @view.render {completed, failed}

  default: ->
    @reset()
    @render()

  reset: ->
    @view.reset()

  error: (args...) =>
    @trigger "error", args...


module.exports = HistoryGraphController


# updateRedisStats = (data) ->
#   $(".stat h3.redis_version").html data.redis_version
#   $(".stat h3.uptime_in_days").html data.uptime_in_days
#   $(".stat h3.connected_clients").html data.connected_clients
#   $(".stat h3.used_memory_human").html data.used_memory_human
#   $(".stat h3.used_memory_peak_human").html data.used_memory_peak_human
