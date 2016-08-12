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
    timestamp = $ "<div>", {class: "timestamp"}
                .text formattedXValue
    @legend.empty().append timestamp

    detail.sort (a, b) -> a.order - b.order
    for d in detail
      yvalue = numberWithDelimiter Math.floor d.formattedYValue
      dot_y  = @graph.y(d.value.y0 + d.value.y)
      line   = $ "<div>", {class: "line"}
        .append $ "<div>", class: "swatch", css: backgroundColor: d.series.color
        .append ($ "<div>", class: "tag").text "#{d.name}: #{yvalue}"

      dot    = $ "<div>", class: "dot active", css: top: "#{dot_y}px", borderColor: d.series.color

      @legend.append line
      @element.appendChild dot[0]
      @show()


module.exports = GraphHover
