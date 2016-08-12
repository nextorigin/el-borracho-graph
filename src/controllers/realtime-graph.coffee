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

    super
    timeInterval = localStorage.timeInterval or= 2000

    @legend = $ "figcaption#realtime-legend"

    @Store      = require "../models/realtime-stat"
    @View       = require "../views/realtime-graph"
    @view       = new @View {@el, @legend, completedLabel, failedLabel, timeInterval}

    @Store.baseUrl = baseUrl
    @Store.on "error",  @error
    @Store.on "create", @render

    @default()

  default: (fromSlider = false) =>
    {timeInterval} = localStorage
    # @slider.val timeInterval unless fromSlider
    # @setSliderLabel timeInterval

    @reset()
    @render()

  render: (stat) =>
    @log "rendering"

    if previous = stat?.previous()
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


###

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

###