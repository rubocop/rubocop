# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # Repacks Parser's diagnostics/errors
      # into RuboCop's offenses.
      class Syntax < Base
        LEVELS = %i[error fatal].freeze

        def on_other_file
          add_offense_from_error(processed_source.parser_error) if processed_source.parser_error
          syntax_errors = processed_source.diagnostics.select { |d| LEVELS.include?(d.level) }
          syntax_errors.each do |diagnostic|
            add_offense_from_diagnostic(diagnostic, processed_source.ruby_version)
          end
          super
        end

        private

        def add_offense_from_diagnostic(diagnostic, ruby_version)
          message = if LSP.enabled?
                      diagnostic.message
                    else
                      "#{diagnostic.message}\n(Using Ruby #{ruby_version} parser; " \
                        'configure using `TargetRubyVersion` parameter, under `AllCops`)'
                    end
          location = diagnostic_location(diagnostic.location)
          add_offense(location, message: message, severity: diagnostic.level)
        end

        # Expand zero-length diagnostic ranges so that editors and formatters
        # can display them. This typically occurs when the parser reports
        # `unexpected token $end` at EOF.
        def diagnostic_location(location)
          return location if location.size.positive?

          source_buffer = location.source_buffer
          if location.end_pos < source_buffer.source.size
            location.resize(1)
          elsif location.begin_pos.positive?
            location.adjust(begin_pos: -1)
          else
            location
          end
        end

        # Override to skip multiline_ranges check which requires AST.
        # Syntax errors mean the AST is nil, so we go directly to
        # the EOL comment insertion path.
        def disable_offense(offense_range)
          disable_offense_with_eol_or_surround_comment(offense_range)
        end

        def add_offense_from_error(error)
          message = beautify_message(error.message)
          add_global_offense(message, severity: :fatal)
        end

        def beautify_message(message)
          message = message.capitalize
          message << '.' unless message.end_with?('.')
          message
        end

        def find_severity(_range, _severity)
          :fatal
        end
      end
    end
  end
end
