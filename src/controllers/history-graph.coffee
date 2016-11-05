Spine    = require "spine"
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

    @Store      = require "../models/history-stat"
    @View       = require "../views/history-graph"
    @legend     = $ "figcaption#history-legend"

    super

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
