# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Avoid passing default value to `Hash.new` as keyword arguments.
      #
      # @example
      #   # bad
      #   Hash.new(foo: 1)
      #
      #   # good
      #   Hash.new({ foo: 1 })
      class HashNewKeywordArguments < Base
        extend AutoCorrector

        MSG = 'Avoid passing default value to `Hash.new` as keyword arguments.'

        RESTRICT_ON_SEND = %i[new].freeze

        # @!method find_keyword_arguments_from_hash_new(node)
        #   @param [RuboCop::AST::Node] node
        #   @return [RuboCop::AST::HashNode, nil]
        def_node_matcher :find_keyword_arguments_from_hash_new, <<~PATTERN
          (send
            (const {nil? cbase} :Hash)
            :new
            $#keyword_arguments?
          )
        PATTERN

        def on_send(node)
          keyword_arguments = find_keyword_arguments_from_hash_new(node)
          return unless keyword_arguments

          add_offense(keyword_arguments) do |corrector|
            corrector.wrap(keyword_arguments, '{ ', ' }')
          end
        end
        alias on_csend on_send

        private

        def keyword_arguments?(argument)
          argument.hash_type? && !argument.source.lstrip.start_with?('{')
        end
      end
    end
  end
end
