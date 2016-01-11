# encoding: utf-8
# frozen_string_literal: true

require 'cgi'
require 'erb'
require 'ostruct'
require 'base64'
require 'rubocop/formatter/text_util'

module RuboCop
  module Formatter
    # This formatter saves the output as a html file.
    class HTMLFormatter < BaseFormatter
      TEMPLATE_PATH =
        File.expand_path('../../../../assets/output.html.erb', __FILE__)

      Color = Struct.new(:red, :green, :blue, :alpha) do
        def to_s
          "rgba(#{values.join(', ')})"
        end

        def fade_out(amount)
          dup.tap do |color|
            color.alpha -= amount
          end
        end
      end

      attr_reader :files, :summary

      def initialize(output, options = {})
        super
        @files = []
        @summary = OpenStruct.new(offense_count: 0)
      end

      def started(target_files)
        summary.target_files = target_files
      end

      def file_finished(file, offenses)
        files << OpenStruct.new(path: file, offenses: offenses)
        summary.offense_count += offenses.count
      end

      def finished(inspected_files)
        summary.inspected_files = inspected_files

        render_html
      end

      def render_html
        context = ERBContext.new(files, summary)

        template = File.read(TEMPLATE_PATH, encoding: Encoding::UTF_8)
        erb = ERB.new(template, nil, '-')
        html = erb.result(context.binding)

        output.write html
      end

      # This class provides helper methods used in the ERB template.
      class ERBContext
        include PathUtil, TextUtil

        SEVERITY_COLORS = {
          refactor:   Color.new(0xED, 0x9C, 0x28, 1.0),
          convention: Color.new(0xED, 0x9C, 0x28, 1.0),
          warning:    Color.new(0x96, 0x28, 0xEF, 1.0),
          error:      Color.new(0xD2, 0x32, 0x2D, 1.0),
          fatal:      Color.new(0xD2, 0x32, 0x2D, 1.0)
        }.freeze

        LOGO_IMAGE_PATH =
          File.expand_path('../../../../assets/logo.png', __FILE__)

        attr_reader :files, :summary

        def initialize(files, summary)
          @files = files.sort_by(&:path)
          @summary = summary
        end

        # Make Kernel#binding public.
        def binding
          super
        end

        def decorated_message(offense)
          offense.message.gsub(/`(.+?)`/) do
            "<code>#{Regexp.last_match(1)}</code>"
          end
        end

        def highlighted_source_line(offense)
          location = offense.location

          column_range = if location.begin.line == location.end.line
                           location.column_range
                         else
                           location.column...location.source_line.length
                         end

          source_line = location.source_line

          escape(source_line[0...column_range.begin]) +
            "<span class=\"highlight #{offense.severity}\">" +
            escape(source_line[column_range]) +
            '</span>' +
            escape(source_line[column_range.end..-1])
        end

        def escape(s)
          # Single quotes not escaped in Ruby 1.9, so add extra substitution.
          CGI.escapeHTML(s).gsub(/'/, '&#39;')
        end

        def base64_encoded_logo_image
          image = File.read(LOGO_IMAGE_PATH, binmode: true)
          Base64.encode64(image)
        end
      end
    end
  end
end
