# encoding: utf-8

require 'open3'

module Rubocop
  module Cop
    class Syntax < Cop
      def inspect(file, source, tokens, sexp)
        stderr = nil

        # it's extremely important to run the syntax check in a
        # clean environment - otherwise it will be extremely slow
        if defined? Bundler
          Bundler.with_clean_env do
            _, stderr, _ =
              Open3.capture3('ruby -wc', stdin_data: source.join("\n"))
          end
        else
          _, stderr, _ =
            Open3.capture3('ruby -wc', stdin_data: source.join("\n"))
        end

        stderr.each_line do |line|
          # discard lines that are not containing relevant info
          if line =~ /.+:(\d+): (.+)/
            line_no, severity, message = process_line(line)
            add_offence(severity, line_no, message)
          end
        end
      end

      def process_line(line)
        line_no, message = line.match(/.+:(\d+): (.+)/).captures
        if message.start_with?('warning: ')
          [line_no.to_i, :warning, message.sub(/warning: /, '').capitalize]
        else
          [line_no.to_i, :error, message.capitalize]
        end
      end
    end
  end
end
