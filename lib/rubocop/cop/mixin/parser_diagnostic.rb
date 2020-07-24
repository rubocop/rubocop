# frozen_string_literal: true

module RuboCop
  module Cop
    # Common functionality for cops which processes Parser's diagnostics.
    # This mixin requires its user class to define `#relevant_diagnostic?`.
    #
    #     def relevant_diagnostic?(diagnostic)
    #       diagnostic.reason == :my_interested_diagnostic_type
    #     end
    #
    # If you want to use an alternative offense message rather than the one in
    # Parser's diagnostic, define `#alternative_message`.
    #
    #     def alternative_message(diagnostic)
    #       'My custom message'
    #     end
    module ParserDiagnostic
      def on_new_investigation
        processed_source.diagnostics.each do |d|
          next unless relevant_diagnostic?(d)

          message = if respond_to?(:alternative_message, true)
                      alternative_message(d)
                    else
                      d.message.capitalize
                    end
          offense_node = find_offense_node_by(d)

          add_offense(d.location, message: message, severity: d.level) do |corrector|
            autocorrect(corrector, offense_node)
          end
        end
      end

      private

      # If a mixed-in subclass has auto-correction, implement it in the mixed-in subclass.
      def autocorrect(corrector, node); end
    end
  end
end
