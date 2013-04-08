# encoding: utf-8

require 'open3'

module Rubocop
  module Cop
    class Syntax < Cop
      def inspect(file, source, tokens, sexp)
        return unless File.exist?(file)
        _, _, stderr = Open3.popen3('ruby', '-w', '-c', file)

        stderr.each_line do |line|
          line_no, warning = line.match(/.+:(\d+): warning: (.+)/).captures
          add_offence(:warning, line_no.to_i, warning.capitalize) if line_no
        end
      end
    end
  end
end
