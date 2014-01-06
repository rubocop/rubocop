# encoding: utf-8

module Rubocop
  module Cop
    module Lint
      # This is actually not a cop and inspects nothing. It just provides
      # methods to repack Parser's diagnostics into RuboCop's offences.
      module Syntax
        COP_NAME = 'Syntax'.freeze

        def self.offences_from_diagnostics(diagnostics)
          diagnostics.map do |diagnostic|
            offence_from_diagnostic(diagnostic)
          end
        end

        def self.offence_from_diagnostic(diagnostic)
          Offence.new(
            diagnostic.level,
            diagnostic.location,
            diagnostic.message,
            COP_NAME
          )
        end
      end
    end
  end
end
