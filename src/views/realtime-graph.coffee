Rickshaw = require "rickshaw"
Hover    = require "./hover"


class RealtimeGraph
  makeGraphFrom: (el, series) ->
    new Rickshaw.Graph
      element:        el
      width:          responsiveWidth()
      height:         200
      renderer:      "line"
      interpolation: "linear"
      series:        series

  makeGraph: ->
    [el]    = @el
    labels  = [
      {name: @failedLabel,    color: "#B1003E"}
      {name: @processedLabel, color: "#006f68"}
    ]
    options =
      timeInterval:  timeInterval
      maxDataPoints: 100
    series  = new Rickshaw.Series.FixedDuration labels, undefined, options

    @makeGraphFrom el, series

  makeYAxis: (graph) ->
    new Rickshaw.Graph.Axis.Y
      graph:          graph
      tickFormat:     Rickshaw.Fixtures.Number.formatKMBT
      ticksTreatment: "glow"

  constructor: ({@el, @legend, @failedLabel, @processedLabel}) ->
    @graph = @makeGraph()
    @yaxis = @makeYAxis @graph
    @hover = new Hover {@graph, @legend}

    @failedLabel    or= "failed"
    @processedLabel or= "processed"

  render: (stat) ->
    @graph.series.addData @statToPoint stat if stat
    @graph.render()

  reset: ->
    @graph.empty()

  statToPoint: (stat) ->
    point = {}
    point[@failedLabel] = stat.failed
    point[@processedLabel] = stat.processed
    point




module.exports = RealtimeGraph
