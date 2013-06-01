# encoding: utf-8

# rubocop:disable LineLength

module Rubocop
  module Formatter
    # Abstract base class for formatter, implements all public API methods.
    #
    # ## Creating Custom Formatter
    #
    # You can create a custom formatter by subclassing
    # `Rubocop::Formatter::BaseFormatter` and override some methods,
    # or implement all the methods by duck typing.
    #
    # ## Using Custom Formatter in Command Line
    #
    # You can tell RuboCop to use your custom formatter with a combination of
    # `--format` and `--require` option.
    # For example, when you have defined `MyCustomFormatter` in
    # `./path/to/my_custom_formatter.rb`, you would type this command:
    #
    #     rubocop --require ./path/to/my_custom_formatter --format MyCustomFormatter
    #
    # Note: The path passed to `--require` is directly passed to
    # `Kernel.require`.
    # If your custom formatter file is not in `$LOAD_PATH`,
    # you need to specify the path as relative path prefixed with `./`
    # explicitly, or absolute path.
    #
    # ## Method Invocation Order
    #
    # For example, when RuboCop processes 2 files,
    # the invocation order should be like this:
    #
    # * `#initialize`
    # * `#started`
    # * `#file_started`
    # * `#file_finished`
    # * `#file_started`
    # * `#file_finished`
    # * `#finished`
    #
    class BaseFormatter
      # rubocop:enable LineLength

      # @!attribute [r] output
      #
      # @return [IO]
      #   the IO object passed to `#initialize`
      #
      # @see #initialize
      attr_reader :output

      # @api public
      #
      # @param output [IO]
      #   `$stdout` or opened file
      def initialize(output)
        @output = output
      end

      # @api public
      #
      # Invoked once before any files are processed.
      #
      # @param all_files [Array(String)]
      #   all file paths to be processed
      #
      # @return [void]
      def started(all_files)
      end

      # @api public
      #
      # Invoked at the beginning of processing each files.
      #
      # @param file [String]
      #   the file path
      #
      # @param options [Hash]
      #   file specific information, currently this is always empty.
      #
      # @return [void]
      def file_started(file, options)
      end

      # @api public
      #
      # Invoked at the end of processing each files.
      #
      # @param file [String]
      #   the file path
      #
      # @param offences [Array(Rubocop::Cop::Offence)]
      #   all detected offences for the file
      #
      # @return [void]
      #
      # @see Rubocop::Cop::Offence
      def file_finished(file, offences)
      end

      # @api public
      #
      # Invoked after all files are processed, or interrupted by user.
      #
      # @param processed_files [Array(String)]
      #   the processed file paths
      #
      # @return [void]
      def finished(processed_files)
      end
    end
  end
end
