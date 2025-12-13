# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks for usage of `Module` methods returning arrays that can be replaced
      # with equivalent predicates.
      #
      # Calling a method returning an array then checking if an element is inside
      # it is much slower than using an equivalent predicate method. For example,
      # `instance_methods.include?` will return an array of all public and protected
      # instance methods in the module, then check if a given method is inside that
      # array, while `method_defined?` will do direct method lookup, which is much
      # faster and consumes less memory.
      #
      # @example
      #   # bad
      #   Array.instance_methods.include?(:size)
      #   Array.instance_methods.member?(:size)
      #   Array.instance_methods(true).include?(:size)
      #
      #   Array.instance_methods(false).include?(:find)
      #
      #   # good
      #   Array.method_defined?(:size)
      #
      #   Array.method_defined?(:find, false)
      #
      class ModuleMemberExistenceCheck < Base
        extend AutoCorrector

        MSG = 'Use `%<replacement>s` instead.'

        RESTRICT_ON_SEND = %i[instance_methods].freeze

        # @!method instance_methods_inclusion?(node)
        def_node_matcher :instance_methods_inclusion?, <<~PATTERN
          (call
            (call _ :instance_methods _?)
            {:include? :member?}
            _)
        PATTERN

        def on_send(node) # rubocop:disable Metrics/AbcSize
          return unless (parent = node.parent)
          return unless instance_methods_inclusion?(parent)
          return unless simple_method_argument?(node) && simple_method_argument?(parent)

          offense_range = node.location.selector.join(parent.source_range.end)
          replacement =
            if node.first_argument.nil? || node.first_argument.true_type?
              "method_defined?(#{parent.first_argument.source})"
            else
              "method_defined?(#{parent.first_argument.source}, #{node.first_argument.source})"
            end

          add_offense(offense_range, message: format(MSG, replacement: replacement)) do |corrector|
            corrector.replace(offense_range, replacement)
          end
        end
        alias on_csend on_send

        private

        def simple_method_argument?(node)
          return false if node.splat_argument? || node.block_argument?
          return false if node.first_argument&.hash_type?

          true
        end
      end
    end
  end
end
