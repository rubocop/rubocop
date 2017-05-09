# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks whether the block parameters of a single-line
      # method accepting a block match the names specified via configuration.
      #
      # For instance one can configure `reduce`(`inject`) to use |a, e| as
      # parameters.
      class SingleLineBlockParams < Cop
        MSG = 'Name `%s` block params `|%s|`.'.freeze

        def on_block(node)
          return unless node.single_line?

          send_node = node.send_node

          return unless send_node.receiver
          return unless method_names.include?(send_node.method_name)

          return unless node.arguments?

          arguments = node.arguments.to_a

          # discard cases with argument destructuring
          return true unless arguments.all?(&:arg_type?)
          return if args_match?(send_node.method_name, arguments)

          add_offense(node.arguments, :expression)
        end

        private

        def message(node)
          method_name = node.parent.send_node.method_name
          arguments   = target_args(method_name).join(', ')

          format(MSG, method_name, arguments)
        end

        def methods
          cop_config['Methods']
        end

        def method_names
          methods.map { |method| method_name(method).to_sym }
        end

        def method_name(method)
          method.keys.first
        end

        def target_args(method_name)
          method_name = method_name.to_s
          method_hash = methods.find { |m| method_name(m) == method_name }
          method_hash[method_name]
        end

        def args_match?(method_name, args)
          actual_args = args.flat_map(&:to_a)

          # Prepending an underscore to mark an unused parameter is allowed, so
          # we remove any leading underscores before comparing.
          actual_args_no_underscores = actual_args.map do |arg|
            arg.to_s.sub(/^_+/, '')
          end

          actual_args_no_underscores == target_args(method_name)
        end
      end
    end
  end
end
