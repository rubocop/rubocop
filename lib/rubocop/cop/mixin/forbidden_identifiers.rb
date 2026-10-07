# frozen_string_literal: true

module RuboCop
  module Cop
    # This module encapsulates the ability to forbid certain identifiers in a cop.
    module ForbiddenIdentifiers
      SIGILS = '@$' # if a variable starts with a sigil it will be removed

      def forbidden_identifier?(name)
        return false if forbidden_identifiers.empty?

        forbidden_identifiers.include?(name.to_s.delete(SIGILS))
      end

      def forbidden_identifiers
        cop_config.fetch('ForbiddenIdentifiers', [])
      end
    end
  end
end
