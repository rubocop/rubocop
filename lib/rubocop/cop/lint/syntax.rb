# encoding: utf-8

module Rubocop
  module Cop
    module Lint
      # This cop actually inspects nothing, just repacks Parser's diagnostics
      # into RuboCop's offences.
      # The purpose of this cop is to support disabling Syntax offences with
      # config or inline comments by conforming to the cop framework.
      class Syntax < Cop
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
            cop_name
          )
        end

        def investigate(processed_source)
          processed_source.diagnostics.each do |d|
            add_offence(d.level, nil, d.location, d.message)
          end
        end
      end
    end
  end
end
