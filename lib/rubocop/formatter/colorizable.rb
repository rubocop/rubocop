# encoding: utf-8

module Rubocop
  module Formatter
    # This mix-in module provides string coloring methods for terminals.
    # It automatically disables coloring if coloring is disabled in the process
    # globally or the formatter's output is not a terminal.
    module Colorizable
      def rainbow
        @rainbow ||= begin
          rainbow = Rainbow.new
          rainbow.enabled = false unless output.tty?
          rainbow
        end
      end

      def colorize(string, *args)
        rainbow.wrap(string).color(*args)
      end

      [
        :black,
        :red,
        :green,
        :yellow,
        :blue,
        :magenta,
        :cyan,
        :white
      ].each do |color|
        define_method(color) do |string|
          colorize(string, color)
        end
      end
    end
  end
end
