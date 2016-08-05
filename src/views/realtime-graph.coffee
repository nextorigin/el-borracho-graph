Rickshaw = require "rickshaw"
Hover    = require "./graph-hover"


class RealtimeGraph
  makeGraphFrom: (el, series) ->
    new Rickshaw.Graph
      element:        el
      # width:          @el.width() - 40 # responsiveWidth()
      # height:         @el.height()
      renderer:      "line"
      interpolation: "linear"
      series:        series

  makeGraph: ->
    [el]    = @el
    labels  = [
      {name: @completedLabel, color: "#006f68"}
      {name: @failedLabel,    color: "#B1003E"}
    ]
    console.log "labels", labels
    options =
      timeInterval:  @timeInterval
      maxDataPoints: 100
      timeBase:      new Date().getTime() / 1000
    series  = new Rickshaw.Series.FixedDuration labels, undefined, options

    @makeGraphFrom el, series

  makeYAxis: (graph, y_axis) ->
    new Rickshaw.Graph.Axis.Y
      graph:          graph
      tickFormat:     Rickshaw.Fixtures.Number.formatKMBT
      ticksTreatment: "glow"
      element:        y_axis[0]

  constructor: ({@el, @legend, @y_axis, @completedLabel, @failedLabel, @timeInterval}) ->
    @completedLabel or= "completed"
    @failedLabel    or= "failed"

    @graph = @makeGraph()
    @yaxis = @makeYAxis @graph, @y_axis
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
