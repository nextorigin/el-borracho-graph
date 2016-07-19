Rickshaw      = require "rickshaw"
RealtimeGraph = require "./realtime-graph"


class HistoryGraph extends RealtimeGraph
  makeGraph: ->
    [el]    = @el
    series  = [
      {color: "#B1003E", data: @failed,    name: el.dataset.failedLabel}
      {color: "#006f68", data: @processed, name: el.dataset.processedLabel}
    ]

    @makeGraphFrom el, series

  makeXAxis: (graph) ->
    new Rickshaw.Graph.Axis.Time {graph}

  constructor: ({@failed, @processed}) ->
    super
    @xaxis = @makeXAxis @graph

  render: ({completed, failed}) ->
    @graph.series.addData @createSeries completed if completed
    @graph.series.addData @createSeries failed    if failed
    @graph.render()

  createSeries: (stats) ->
    (x: (Date.parse stat.id) / 1000, y: stat.value for stat in stats)




module.exports = HistoryGraph
