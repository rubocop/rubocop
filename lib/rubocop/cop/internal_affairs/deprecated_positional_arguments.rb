# frozen_string_literal: true

module RuboCop
  module Cop
    module InternalAffairs
      # Enforces use of keyword arguments for `#add_offense`.
      #
      # @example
      #
      #   # bad
      #   add_offense(node, :selector, 'message')
      #   add_offense(node, :selector, message: 'message')
      #
      #   # good
      #   add_offense(node, location: :selector, message: 'message')
      #
      class DeprecatedPositionalArguments < Cop
        MSG = 'Use of positional arguments on `#add_offense` is ' \
          'deprecated.'.freeze

        ARGUMENTS = %i[location message severity].freeze

        def on_send(node)
          return unless node.method_name == :add_offense

          positional_arguments(node) do |arguments|
            location = range_between(
              arguments.first.loc.expression.begin_pos,
              arguments.last.loc.expression.end_pos
            )

            add_offense(node, location: location)
          end
        end

        def autocorrect(node)
          positional_arguments(node) do |arguments|
            # Can't autocorrect splat.
            next if arguments.any?(&:splat_type?)

            lambda do |corrector|
              arguments.zip(ARGUMENTS).each do |(arg, keyword)|
                corrector.replace(arg.source_range, "#{keyword}: #{arg.source}")
              end
            end
          end
        end

        private

        def positional_arguments(node)
          arguments = extract_arguments(node)

          positional_args =
            case arguments
            when :empty?.to_proc then []
            # Keyword arguments only
            when ->(args) { args.one? && args.first.hash_type? } then []
            # Mixed style
            when ->(args) { args.last.hash_type? } then arguments.drop_last(1)
            # Positional arguments only
            else arguments
            end

          yield positional_args if positional_args.any?
        end

        def extract_arguments(node)
          node.arguments.butfirst.take_while do |arg|
            # Filter out block argument
            next false if arg.block_pass_type?
            # Filter out kwsplat
            next false if arg.hash_type? && arg.each_child_node(:kwsplat).any?
            # Keep all others
            true
          end
        end
      end
    end
  end
end
