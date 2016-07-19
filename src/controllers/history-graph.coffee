Spine    = require "spine"
Maquette = require "maquette"


debounce = (fn, timeout, timeoutID = -1) -> ->
  if timeoutID > -1 then window.clearTimeout timeoutID
  timeoutID = window.setTimeout fn, timeout


class HistoryGraphController extends Spine.Controller
  logPrefix: "(ElBorracho:HistoryGraph)"

  elements:
    graph:         "#history"

  debouncedDefault: debounce @default, 125

  updateSliderLabel: (e) ->
    @setSliderLabel ($ e.target).val()

  events:
    "onresize window":                       "debouncedDefault"

  constructor: ({baseUrl}) ->
    @debug "constructing"

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
    @debug "rendering"
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


module.exports = HistoryGraphController



historyGraph = ->

updateStatsSummary = (data) ->
  $("ul.summary li.processed span.count").html data.processed.numberWithDelimiter()
  $("ul.summary li.failed span.count").html data.failed.numberWithDelimiter()
  $("ul.summary li.busy span.count").html data.busy.numberWithDelimiter()
  $("ul.summary li.scheduled span.count").html data.scheduled.numberWithDelimiter()
  $("ul.summary li.retries span.count").html data.retries.numberWithDelimiter()
  $("ul.summary li.enqueued span.count").html data.enqueued.numberWithDelimiter()
  $("ul.summary li.dead span.count").html data.dead.numberWithDelimiter()

updateRedisStats = (data) ->
  $(".stat h3.redis_version").html data.redis_version
  $(".stat h3.uptime_in_days").html data.uptime_in_days
  $(".stat h3.connected_clients").html data.connected_clients
  $(".stat h3.used_memory_human").html data.used_memory_human
  $(".stat h3.used_memory_peak_human").html data.used_memory_peak_human

pulseBeacon = ->
  $(".beacon").addClass("pulse").delay(1000).queue ->
    $(this).removeClass("pulse").dequeue()


