Rickshaw = require "rickshaw"


numberWithDelimiter = (number, delimiter = ",") ->
  number   = "#{number}"
  split    = number.split "."
  split[0] = split[0].replace /(\d)(?=(\d\d\d)+(?!\d))/g, "$1#{delimiter}"
  split.join "."


class GraphHover extends Rickshaw.Graph.HoverDetail
  constructor: ({@graph, @legend}) ->
    super

  render: ({formattedXValue, detail}) ->
    timestamp = $ "div.timestamp", {}, [formattedXValue]
    @legend.empty().append timestamp
    detail.sort (a, b) -> a.order - b.order
    for d in detail
      yvalue = (Math.floor d.formattedYValue).numberWithDelimiter()
      dot_y  = @graph.y(d.value.y0 + d.value.y)
      line   = $ "div.line", {}, [
        ($ "div.swatch", style: backgroundColor: d.series.color)
        ($ "div.tag", ["#{d.name}:#{yvalue}"])
      ]
      dot    = $ "div.dot.active", style: top: "#{dot_y}px", borderColor: d.series.color

      @legend.append line
      @element.appendChild dot
      @show()


module.exports = GraphHover
