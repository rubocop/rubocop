# encoding: utf-8

module Rubocop
  module Cop
    # FIXME
    class Team
      attr_reader :errors

      def initialize(cop_classes, config, options = nil)
        @cop_classes = cop_classes
        @config = config
        @options = options || { auto_correct: false, debug: false }
        @errors = []
      end

      def autocorrect?
        @options[:auto_correct]
      end

      def debug?
        @options[:debug]
      end

      def inspect_file(file)
        begin
          processed_source = SourceParser.parse_file(file)
        rescue Encoding::UndefinedConversionError, ArgumentError => e
          range = Struct.new(:line, :column, :source_line).new(1, 0, '')
          return [Offence.new(:fatal, range, e.message.capitalize + '.',
                              'Parser')]
        end

        # If we got any syntax errors, return only the syntax offences.
        # Parser may return nil for AST even though there are no syntax errors.
        # e.g. sources which contain only comments
        unless processed_source.valid_syntax?
          diagnostics = processed_source.diagnostics
          return Lint::Syntax.offences_from_diagnostics(diagnostics)
        end

        commissioner = Commissioner.new(cops)
        offences = commissioner.investigate(processed_source)
        process_commissioner_errors(file, commissioner.errors)
        autocorrect(processed_source.buffer, cops)
        offences.sort
      end

      def cops
        @cops ||= begin
          @cop_classes.reduce([]) do |instances, cop_class|
            next instances unless @config.cop_enabled?(cop_class)
            instances << cop_class.new(@config, @options)
          end
        end
      end

      private

      def autocorrect(buffer, cops)
        return unless autocorrect?

        corrections = cops.reduce([]) do |array, cop|
          array.concat(cop.corrections)
          array
        end

        corrector = Corrector.new(buffer, corrections)
        new_source = corrector.rewrite

        unless new_source == buffer.source
          filename = buffer.name
          File.open(filename, 'w') { |f| f.write(new_source) }
        end
      end

      def process_commissioner_errors(file, file_errors)
        file_errors.each do |cop, errors|
          errors.each do |e|
            handle_error(e,
                         "An error occurred while #{cop.name}".color(:red) +
                         " cop was inspecting #{file}.".color(:red))
          end
        end
      end

      def handle_error(e, message)
        @errors << message
        warn message
        if debug?
          puts e.message, e.backtrace
        else
          warn 'To see the complete backtrace run rubocop -d.'
        end
      end
    end
  end
end
