require "charty"

module Charty

  class RenderContext
    def to_json
      @plotter_adapter.to_json(self)
    end
  end

  class PlotlyjsPlotter
  end

  class Plotlyjs < PlotterAdapter
    Name = "plotlyjs"

    def initialize
      # do nothing
      @plot = PlotlyjsPlotter
    end

    def label(x, y)
    end

    def series=(series)
      @series = series
    end

    def render_layout(layout)
      raise NotImplementedError
    end

    def render(context, filename)
      # plot(@plot, context).write(filename)
      plot(@plot, context)
    end

    def to_json(context)
      data = context.series.first
      trace1 = {
        x: data.xs.to_a,
        y: data.ys.to_a,
        type: 'bar'
      }
      # context.series.each do |data|
      #   x: data.xs.to_a,
      #   y: data.ys.to_a
      #   type: 'bar'
      # end

      require 'json'
      [trace1].to_json
    end

    def plot(plot, context)
# line
# bar
# radar
# doughnut and pie
# polar area
# bubble
# scatter
      case context.method
      when :bar
        # x = context.x
        # y = context.y
data = context.series.first
html = <<EOS
<script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
<div id="myDiv"></div>
<script>
  var trace1 = {
    x: #{data.xs.to_a},
    y: #{data.ys.to_a},
    type: 'bar'
  };

  var trace2 = {
    x: #{data.xs.to_a},
    y: #{data.ys.to_a},
    type: 'scatter'
  };

  var data = [trace1, trace2];

  Plotly.newPlot('myDiv', data);
</script>
EOS

      when :boxplot
        plot.boxplot(context.data.to_a)
      when :bubble
        context.series.each do |data|
          plot.scatter(data.xs.to_a, data.ys.to_a, s: data.zs.to_a, alpha: 0.5)
        end
      when :curve
      when :scatter
        context.series.each do |data|
          plot.scatter(data.xs.to_a, data.ys.to_a, label: data.label)
        end
        plot.legend()
      when :errorbar
        context.series.each do |data|
          plot.errorbar(
            data.xs.to_a,
            data.ys.to_a,
            data.xerr,
            data.yerr,
            label: data.label,
          )
        end
        plot.legend()
      when :hist
        plot.hist(context.data.to_a)
      end
    end
  end
end
