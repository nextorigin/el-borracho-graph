Rickshaw      = require "rickshaw"
RealtimeGraph = require "./realtime-graph"
Hover         = require "./graph-hover"


debounce = (fn, timeout, timeoutID = -1) -> ->
  if timeoutID > -1 then window.clearTimeout timeoutID
  timeoutID = window.setTimeout fn, timeout


class HistoryGraph extends RealtimeGraph
  makeGraph: (completed, failed) ->
    [el]    = @el
    series  = [
      {name: @completedLabel, color: @completedColor, data: completed}
      {name: @failedLabel,    color: @failedColor, data: failed}
    ]

    @makeGraphFrom el, series

  makeXAxis: (graph) ->
    new Rickshaw.Graph.Axis.Time {graph}

  constructor: (opts, args...) ->
    opts.completedColor or= "#555"
    opts.failedColor    or= "#222"

    super opts, args...

    setInterval @checkSize, 2000

  checkSize: =>
    unless @lastWidth is width = @el.width()
      @resize()
      @lastWidth = width

  render: ({completed, failed}) =>
    completed or= []
    failed    or= []
    completed   = @createSeries completed if completed?.length
    failed      = @createSeries failed    if failed?.length

    @reset() if @graph
    @graph = @makeGraph completed, failed
    @yaxis = @makeYAxis @graph
    @xaxis = @makeXAxis @graph
    @hover = new Hover {@graph, @legend}

    @graph.render()

  createSeries: (stats) ->
    series = (x: (Date.parse stat.date) / 1000, y: stat.count for stat in stats)
    series.sort (a, b) -> a.x - b.x
    series


module.exports = HistoryGraph
