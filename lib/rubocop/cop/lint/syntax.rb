# encoding: utf-8

module Rubocop
  module Cop
    module Lint
      # This is actually not a cop and inspects nothing. It just provides
      # methods to repack Parser's diagnostics into RuboCop's offenses.
      module Syntax
        COP_NAME = 'Syntax'.freeze

        def self.offenses_from_diagnostics(diagnostics)
          diagnostics.map do |diagnostic|
            offense_from_diagnostic(diagnostic)
          end
        end

        def self.offense_from_diagnostic(diagnostic)
          Offense.new(
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
