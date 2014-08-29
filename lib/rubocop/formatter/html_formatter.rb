# encoding: utf-8

require 'erb'
require 'ostruct'

module RuboCop
  module Formatter
    # This formatter saves the output as a html file.
    class HTMLFormatter < BaseFormatter
      include PathUtil

      TEMPLATE_PATH =
        File.expand_path('../../../../assets/output.html.erb', __FILE__)

      attr_reader :files, :summary

      def initialize(output)
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
        template = File.read(TEMPLATE_PATH)
        erb = ERB.new(template)
        html = erb.result(binding)

        output.write html
      end

      def metadata
        OpenStruct.new(
          rubocop_version: RuboCop::Version::STRING,
          ruby_engine:     RUBY_ENGINE,
          ruby_version:    RUBY_VERSION,
          ruby_patchlevel: RUBY_PATCHLEVEL.to_s,
          ruby_platform:   RUBY_PLATFORM
        )
      end
    end
  end
end
