# encoding: utf-8

require 'open3'

module Rubocop
  module Cop
    class LineLength < Cop
      def inspect(file, source, tokens, sexp)
        _, _, stderr = Open3.popen3('ruby', '-w', '-c', file)

        if stderr
          stderr.each_line do |line|
            line_no, warning = line.match(/.+:(\d+): (.+)/).captures
            add_offence(:warning, line_no.to_i, warning) if line_no
          end
        end
      end
    end
  end
end
