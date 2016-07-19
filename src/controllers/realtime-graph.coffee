Spine    = require "spine"
Maquette = require "maquette"


debounce = (fn, timeout, timeoutID = -1) -> ->
  if timeoutID > -1 then window.clearTimeout timeoutID
  timeoutID = window.setTimeout fn, timeout


class RealtimeGraphController extends Spine.Controller
  logPrefix: "(ElBorracho:RealtimeGraph)"

  elements:
    slider:        ".interval-slider input"
    sliderLabel:   ".current-interval"
    graph:         "#realtime"

  debouncedDefault: debounce @default, 125

  updateInterval: (e) ->
    localStorage.timeInterval = ($ e.target).val()
    @default true

  updateSliderLabel: (e) ->
    @setSliderLabel ($ e.target).val()

  events:
    "onresize window":                       "debouncedDefault"
    "change div.interval-slider input":      "updateInterval"
    "mousemove div.interval-slider input":   "updateSliderLabel"

  constructor: ({baseUrl}) ->
    @debug "constructing"

    super

    @Store      = require "../models/realtime-stat"
    @View       = require "../views/realtime-graph"

    @projector or= Maquette.createProjector()
    @View        = new @View @el

    @Store.on "error", ->
    @Store.on "create", @render

    localStorage.timeInterval or= "2000"
    @default()
    @pollOnInterval()

  default: (fromSlider = false) ->
    {timeInterval} = localStorage
    @slider.val timeInterval unless fromSlider
    @setSliderLabel timeInterval

    clearInterval @_poller if @_poller
    @reset()
    @render()

  render: (stat) =>
    @debug "rendering"
    @view.render point

  reset: ->
    @view.reset()

  setSliderLabel: (val) ->
    text = "#{Math.round parseFloat(val) / 1000} sec"
    @sliderLabel.text text

  pollOnInterval: ->
    @_poller = setInterval @Store.fetch, parseInt localStorage.timeInterval

  fetch: ->
    [el] = @el
    if i == 0
      processed = results.processed
      failed = results.failed
    else
      processed = results.processed - (Sidekiq.processed)
      failed = results.failed - (Sidekiq.failed)
    dataPoint = {}
    dataPoint[el.dataset.failedLabel] = failed
    dataPoint[el.dataset.processedLabel] = processed
    graph.series.addData dataPoint
    graph.render()
    Sidekiq.processed = results.processed
    Sidekiq.failed = results.failed
    updateStatsSummary results
    updateRedisStats data.redis
    pulseBeacon()


module.exports = RealtimeGraphController



historyGraph = ->
  processed = createSeries($("#history").data("processed"))
  failed = createSeries($("#history").data("failed"))
  graphElement = document.getElementById("history")
  graph = new (Rickshaw.Graph)(
    element: graphElement
    width: responsiveWidth()
    height: 200
    renderer: "line"
    interpolation: "linear"
    series: [
      {
        color: "#B1003E"
        data: failed
        name: graphElement.dataset.failedLabel
      }
      {
        color: "#006f68"
        data: processed
        name: graphElement.dataset.processedLabel
      }
    ])
  x_axis = new (Rickshaw.Graph.Axis.Time)(graph: graph)
  y_axis = new (Rickshaw.Graph.Axis.Y)(
    graph: graph
    tickFormat: Rickshaw.Fixtures.Number.formatKMBT
    ticksTreatment: "glow")
  graph.render()
  legend = document.querySelector("#history-legend")
  Hover = Rickshaw.Class.create(Rickshaw.Graph.HoverDetail, render: (args) ->
    legend.innerHTML = ""
    timestamp = document.createElement("div")
    timestamp.className = "timestamp"
    timestamp.innerHTML = args.formattedXValue
    legend.appendChild timestamp
    args.detail.sort((a, b) ->
      a.order - (b.order)
    ).forEach ((d) ->
      line = document.createElement("div")
      line.className = "line"
      swatch = document.createElement("div")
      swatch.className = "swatch"
      swatch.style.backgroundColor = d.series.color
      label = document.createElement("div")
      label.className = "tag"
      label.innerHTML = d.name + ": " + Math.floor(d.formattedYValue).numberWithDelimiter()
      line.appendChild swatch
      line.appendChild label
      legend.appendChild line
      dot = document.createElement("div")
      dot.className = "dot"
      dot.style.top = graph.y(d.value.y0 + d.value.y) + "px"
      dot.style.borderColor = d.series.color
      @element.appendChild dot
      dot.className = "dot active"
      @show()
      return
    ), this
    return
  )
  hover = new Hover(graph: graph)
  return

createSeries = (obj) ->
  series = []
  for date of obj
    value = obj[date]
    point =
      x: Date.parse(date) / 1000
      y: value
    series.unshift point
  series

updateStatsSummary = (data) ->
  $("ul.summary li.processed span.count").html data.processed.numberWithDelimiter()
  $("ul.summary li.failed span.count").html data.failed.numberWithDelimiter()
  $("ul.summary li.busy span.count").html data.busy.numberWithDelimiter()
  $("ul.summary li.scheduled span.count").html data.scheduled.numberWithDelimiter()
  $("ul.summary li.retries span.count").html data.retries.numberWithDelimiter()
  $("ul.summary li.enqueued span.count").html data.enqueued.numberWithDelimiter()
  $("ul.summary li.dead span.count").html data.dead.numberWithDelimiter()
  return

updateRedisStats = (data) ->
  $(".stat h3.redis_version").html data.redis_version
  $(".stat h3.uptime_in_days").html data.uptime_in_days
  $(".stat h3.connected_clients").html data.connected_clients
  $(".stat h3.used_memory_human").html data.used_memory_human
  $(".stat h3.used_memory_peak_human").html data.used_memory_peak_human
  return

pulseBeacon = ->
  $(".beacon").addClass("pulse").delay(1000).queue ->
    $(this).removeClass("pulse").dequeue()
    return
  return

Number::numberWithDelimiter = (delimiter) ->
  `var delimiter`
  number = this + ""
  delimiter = delimiter or ","
  split = number.split(".")
  split[0] = split[0].replace(/(\d)(?=(\d\d\d)+(?!\d))/g, "$1" + delimiter)
  split.join "."

# Render graphs


$ ->

    return
  return
# Reset graphs

  return

# Resize graphs after resizing window

