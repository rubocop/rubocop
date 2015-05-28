# encoding: utf-8

require 'fileutils'

module RuboCop
  module Formatter
    # This is a collection of formatters. A FormatterSet can hold multiple
    # formatter instances and provides transparent formatter API methods
    # which invoke same method of each formatters.
    class FormatterSet < Array
      BUILTIN_FORMATTERS_FOR_KEYS = {
        'progress' => ProgressFormatter,
        'simple'   => SimpleTextFormatter,
        'clang'    => ClangStyleFormatter,
        'fuubar'   => FuubarStyleFormatter,
        'emacs'    => EmacsStyleFormatter,
        'json'     => JSONFormatter,
        'html'     => HTMLFormatter,
        'files'    => FileListFormatter,
        'offenses' => OffenseCountFormatter,
        'disabled' => DisabledLinesFormatter
      }

      FORMATTER_APIS = [:started, :finished]

      FORMATTER_APIS.each do |method_name|
        define_method(method_name) do |*args|
          each { |f| f.send(method_name, *args) }
        end
      end

      def file_started(file, options)
        @cop_disabled_line_ranges ||= {}
        @cop_disabled_line_ranges[file] = options[:cop_disabled_line_ranges]
        @comments ||= {}
        @comments[file] = options[:comments]
        @excepted_cops = options[:excepted_cops] || []
        @only_cops = options[:only_cops] || []
        each { |f| f.file_started(file, options) }
      end

      def file_finished(file, offenses)
        if @cop_disabled_line_ranges[file].any? &&
           # Don't check unneeded disable if --only or --except option is
           # given, because these options override configuration.
           @excepted_cops.empty? && @only_cops.empty?
          cop = Cop::Lint::UnneededDisable.new
          cop.check(file, offenses, @cop_disabled_line_ranges, @comments)
          offenses += cop.offenses
        end
        offenses = offenses.sort.reject(&:disabled?)
        each { |f| f.file_finished(file, offenses) }
      end

      def add_formatter(formatter_type, output_path = nil)
        formatter_class = case formatter_type
                          when Class
                            formatter_type
                          when /\A[A-Z]/
                            custom_formatter_class(formatter_type)
                          else
                            builtin_formatter_class(formatter_type)
                          end

        if output_path
          dir_path = File.dirname(output_path)
          FileUtils.mkdir_p(dir_path) unless File.exist?(dir_path)
          output = File.open(output_path, 'w')
        else
          output = $stdout
        end

        self << formatter_class.new(output)
      end

      def close_output_files
        each do |formatter|
          formatter.output.close if formatter.output.is_a?(File)
        end
      end

      private

      def builtin_formatter_class(specified_key)
        matching_keys = BUILTIN_FORMATTERS_FOR_KEYS.keys.select do |key|
          key.start_with?(specified_key)
        end

        if matching_keys.empty?
          fail %(No formatter for "#{specified_key}")
        elsif matching_keys.size > 1
          fail %(Cannot determine formatter for "#{specified_key}")
        end

        BUILTIN_FORMATTERS_FOR_KEYS[matching_keys.first]
      end

      def custom_formatter_class(specified_class_name)
        constant_names = specified_class_name.split('::')
        constant_names.shift if constant_names.first.empty?
        constant_names.reduce(Object) do |namespace, constant_name|
          namespace.const_get(constant_name, false)
        end
      end
    end
  end
end
