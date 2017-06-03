# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This is actually not a cop and inspects nothing. It just provides
      # methods to repack Parser's diagnostics/errors into RuboCop's offenses.
      class Syntax < Cop
        PseudoSourceRange = Struct.new(:line, :column, :source_line, :begin_pos,
                                       :end_pos)

        ERROR_SOURCE_RANGE = PseudoSourceRange.new(1, 0, '', 0, 1).freeze

        def self.offenses_from_processed_source(processed_source,
                                                config, options)
          cop = new(config, options)

          if processed_source.parser_error
            cop.add_offense_from_error(processed_source.parser_error)
          end

          processed_source.diagnostics.each do |diagnostic|
            cop.add_offense_from_diagnostic(diagnostic,
                                            processed_source.ruby_version)
          end

          cop.offenses
        end

        def add_offense_from_diagnostic(diagnostic, ruby_version)
          message =
            "#{diagnostic.message}\n(Using Ruby #{ruby_version} parser; " \
            'configure using `TargetRubyVersion` parameter, under `AllCops`)'
          add_offense(nil, diagnostic.location, message, diagnostic.level)
        end

        def add_offense_from_error(error)
          message = beautify_message(error.message)
          add_offense(nil, ERROR_SOURCE_RANGE, message, :fatal)
        end

        private

        def beautify_message(message)
          message = message.capitalize
          message << '.' unless message.end_with?('.')
          message
        end
      end
    end
  end
end
