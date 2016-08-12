Rickshaw = require "rickshaw"
Hover    = require "./graph-hover"


debounce = (fn, timeout, timeoutID = -1) -> ->
  if timeoutID > -1 then window.clearTimeout timeoutID
  timeoutID = window.setTimeout fn, timeout


class RealtimeGraph
  makeGraphFrom: (el, series) ->
    new Rickshaw.Graph
      element:        el
      renderer:      "line"
      interpolation: "linear"
      series:        series

  makeGraph: ->
    [el]    = @el
    labels  = [
      {name: @completedLabel, color: @completedColor}
      {name: @failedLabel,    color: @failedColor}
    ]
    options =
      timeInterval:  @timeInterval
      maxDataPoints: 100
      timeBase:      new Date().getTime() / 1000
    series  = new Rickshaw.Series.FixedDuration labels, undefined, options

    @makeGraphFrom el, series

  makeYAxis: (graph) ->
    new Rickshaw.Graph.Axis.Y
      graph:          graph
      tickFormat:     Rickshaw.Fixtures.Number.formatKMBT
      ticksTreatment: "glow"

  constructor: ({@el, @legend, @completedLabel, @failedLabel, @completedColor, @failedColor, @timeInterval}) ->
    @completedLabel or= "completed"
    @failedLabel    or= "failed"
    @completedColor or= "#CCC"
    @failedColor    or= "#ed145b"

    @debouncedResize = debounce @resize, 125
    ($ window).resize @debouncedResize

  render: (stat) =>
    unless @graph
      @graph = @makeGraph()
      @yaxis = @makeYAxis @graph
      @hover = new Hover {@graph, @legend}

    unless @lastWidth is width = @el.width()
      @resize()
      @lastWidth = width

    @graph.series.addData @statToPoint stat if stat
    @graph.render()

  reset: ->
    @el.empty()
    delete @graph

  resize: =>
    @graph.configure width: @el.width()
    @graph.render()

  statToPoint: (stat) ->
    point = {}
    point[@completedLabel] = stat.completed
    point[@failedLabel]    = stat.failed
    point




module.exports = RealtimeGraph
