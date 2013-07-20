# encoding: utf-8

module Rubocop
  module Formatter
    # This is a collection of formatters. A FormatterSet can hold multiple
    # formatter instances and provides transparent formatter API methods
    # which invoke same method of each formatters.
    class FormatterSet < Array
      BUILTIN_FORMATTERS_FOR_KEYS = {
        'progress' => ProgressFormatter,
        'simple'   => SimpleTextFormatter,
        'clang'    => ClangStyleFormatter,
        'emacs'    => EmacsStyleFormatter,
        'json'     => JSONFormatter,
        'files'    => FileListFormatter,
        'disabled' => DisabledConfigFormatter
      }
      HIDDEN_FORMATTERS = %w(disabled)

      FORMATTER_APIS = [:started, :file_started, :file_finished, :finished]

      def initialize(report_summary = true)
        @reports_summary = report_summary
      end

      FORMATTER_APIS.each do |method_name|
        define_method(method_name) do |*args|
          each { |f| f.send(method_name, *args) }
        end
      end

      def add_formatter(formatter_key, output_path = nil)
        formatter_class = if formatter_key =~ /\A[A-Z]/
                            custom_formatter_class(formatter_key)
                          else
                            builtin_formatter_class(formatter_key)
                          end

        output = output_path ? File.open(output_path, 'w') : $stdout

        formatter = formatter_class.new(output)
        if formatter.respond_to?(:reports_summary=)
          # TODO: Consider dropping -s/--silent option
          formatter.reports_summary = @reports_summary
        end
        self << formatter
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
