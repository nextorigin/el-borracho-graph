Spine    = require "spine"
Maquette = require "maquette"


debounce = (fn, timeout, timeoutID = -1) -> ->
  if timeoutID > -1 then window.clearTimeout timeoutID
  timeoutID = window.setTimeout fn, timeout


class HistoryGraphController extends Spine.Controller
  logPrefix: "(ElBorracho:HistoryGraph)"

  debouncedDefault: debounce @default, 125

  updateSliderLabel: (e) ->
    @setSliderLabel ($ e.target).val()

  events:
    "onresize window":                       "debouncedDefault"

  constructor: ({baseUrl}) ->
    @log "constructing"

    super

    @Store      = require "../models/history-stats"
    @view       = require "../views/history-graph"
    @filterView = require "../views/filter"

    # @projector or= Maquette.createProjector()
    # @filterMap   = new Mapper [], @filterView

    @Store.on "error", ->
    @Store.on "change", @render
    # @projector.append @el[0], @render

    # localStorage.timeInterval or= "2000"
    @default()
    # @pollOnInterval()

  render: =>
    @log "rendering"
    filters = @Store.all()

    processed = @Store.findAllByAttribute "type", "processed"
    failed    = @Store.findAllByAttribute "type", "failed"

    @view.render {processed, failed}

  default: ->
    @reset()
    @render()

  reset: ->
    @view.reset()

  pollOnInterval: ->

  error: (args...) =>
    @trigger "error", args...


module.exports = HistoryGraphController


updateRedisStats = (data) ->
  $(".stat h3.redis_version").html data.redis_version
  $(".stat h3.uptime_in_days").html data.uptime_in_days
  $(".stat h3.connected_clients").html data.connected_clients
  $(".stat h3.used_memory_human").html data.used_memory_human
  $(".stat h3.used_memory_peak_human").html data.used_memory_peak_human

pulseBeacon = ->
  $(".beacon").addClass("pulse").delay(1000).queue ->
    $(this).removeClass("pulse").dequeue()


