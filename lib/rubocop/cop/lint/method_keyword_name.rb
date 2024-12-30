# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # Makes sure that methods does not reserver ruby keyword name.
      #
      # @example
      #
      #   # bad
      #   def def
      #     :ok
      #   end
      #
      #   # bad
      #   def false; end
      #
      class MethodKeywordName < Base
        include AllowedIdentifiers

        KEYWORDS = %i[
          BEGIN END alias and begin break case class def defined?
          do else elsif end ensure false for if in module next nil
          not or redo rescue retry return self super then true undef
          unless until when while yield
        ].freeze

        MSG = 'Do not use ruby keyword for method names.'

        def on_def(node)
          return unless KEYWORDS.include?(node.method_name)
          return if allowed_identifier?(node.method_name)

          add_offense(node.loc.name)
        end
      end
    end
  end
end
