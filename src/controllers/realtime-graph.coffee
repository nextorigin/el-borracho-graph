Spine    = require "spine"


class RealtimeGraphController extends Spine.Controller
  logPrefix: "(ElBorracho:RealtimeGraph)"

  elements:
    ".interval-slider":              "slider"
    ".current-interval":             "sliderLabel"

  updateInterval: (e) ->
    localStorage.timeInterval = ($ e.target).val()
    @default true

  updateSliderLabel: (e) ->
    @setSliderLabel ($ e.target).val()

  keepLegend: ->
    clearTimeout @_legendTimeout if @_legendTimeout

  timeoutLegend: ->
    @_legendTimeout = setTimeout @clearLegend, 5000

  clearLegend: =>
    @legend.fadeOut 300, => @legend.empty().show 1

  events:
    "change div.interval-slider input":      "updateInterval"
    "mousemove div.interval-slider input":   "updateSliderLabel"
    "mouseover":                             "keepLegend"
    "mouseout":                              "timeoutLegend"

  constructor: ({baseUrl, completedLabel, failedLabel}) ->
    @log "constructing"

    @Store       = require "../models/realtime-stat"
    @View        = require "../views/realtime-graph"
    @legend      = $ "figcaption#realtime-legend"

    super

    timeInterval = localStorage.timeInterval or= 2000
    @view        = new @View {@el, @legend, completedLabel, failedLabel, timeInterval}

    @Store.baseUrl = baseUrl
    @Store.on "error",  @error
    @Store.on "create refresh", @render

    @default()

  default: (fromSlider = false) =>
    {timeInterval} = localStorage
    if @slider?.length and not fromSlider
      @slider.val timeInterval unless fromSlider
      @setSliderLabel timeInterval

    @reset()
    @render()

  render: (stats) =>
    @log "rendering"
    stats = [stats] unless Array.isArray stats
    for stat in stats when previous = stat?.previous()
      completed = stat.completed - previous.completed
      failed    = stat.failed - previous.failed
      delta     = {completed, failed}
      @view.render delta

  reset: ->
    @view.reset()

  start: =>
    @Store.listen()

  stop: =>
    @Store.stop()

  setSliderLabel: (val) ->
    text = "#{Math.round parseFloat(val) / 1000} sec"
    @sliderLabel.text text

  error: (args...) =>
    @trigger "error", args...


module.exports = RealtimeGraphController
