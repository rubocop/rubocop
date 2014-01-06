# encoding: utf-8

module Rubocop
  module Cop
    # Common functionality for cops which processes Parser's diagnostics.
    # This mixin requires its user class to define `#relevant_diagnostic?`.
    #
    #     def relevant_diagnostic?(diagnostic)
    #       diagnostic.reason == :my_interested_diagnostic_type
    #     end
    module ParserDiagnostic
      def investigate(processed_source)
        processed_source.diagnostics.each do |d|
          next unless relevant_diagnostic?(d)
          add_offence(nil, d.location, d.message.capitalize, d.level)
        end
      end
    end
  end
end
