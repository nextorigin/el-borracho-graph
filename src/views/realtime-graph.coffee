Rickshaw = require "rickshaw"
Hover    = require "./graph-hover"


class RealtimeGraph
  makeGraphFrom: (el, series) ->
    new Rickshaw.Graph
      element:        el
      width:          @el.width() - 40 # responsiveWidth()
      height:         200
      renderer:      "line"
      interpolation: "linear"
      series:        series

  makeGraph: ->
    [el]    = @el
    labels  = [
      {name: @completedLabel, color: "#006f68"}
      {name: @failedLabel,    color: "#B1003E"}
    ]
    options =
      timeInterval:  @timeInterval
      maxDataPoints: 100
    series  = new Rickshaw.Series.FixedDuration labels, undefined, options

    @makeGraphFrom el, series

  makeYAxis: (graph) ->
    new Rickshaw.Graph.Axis.Y
      graph:          graph
      tickFormat:     Rickshaw.Fixtures.Number.formatKMBT
      ticksTreatment: "glow"

  constructor: ({@el, @legend, @completedLabel, @failedLabel, @timeInterval}) ->
    @completedLabel or= "completed"
    @failedLabel    or= "failed"

    @graph = @makeGraph()
    @yaxis = @makeYAxis @graph
    @hover = new Hover {@graph, @legend}

  render: (stat) ->
    @graph.series.addData @statToPoint stat if stat
    @graph.render()

  reset: ->
    @el.empty()

  statToPoint: (stat) ->
    point = {}
    point[@completedLabel] = stat.completed
    point[@failedLabel]    = stat.failed
    point




module.exports = RealtimeGraph
