# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks whether symbol names are snake_case.
      # There's also an option to accept CamelCase symbol names as well.
      # There's also an option to accept symbol names with dots as well.
      class SymbolName < Cop
        MSG = 'Use snake_case for symbols.'
        SNAKE_CASE = /^[\da-z_]+[!?=]?$/
        SNAKE_CASE_WITH_DOTS = /^[\da-z_\.]+[!?=]?$/
        CAMEL_CASE = /^[A-Z][A-Za-z\d]*$/

        def allow_camel_case?
          cop_config['AllowCamelCase']
        end

        def allow_dots?
          cop_config['AllowDots']
        end

        def on_send(node)
          receiver, method_name, *args = *node
          # Arguments to Module#private_constant are symbols referring to
          # existing constants, so they will start with an upper case letter.
          # We ignore these symbols.
          if receiver.nil? && method_name == :private_constant
            args.each { |a| ignore_node(a) }
          end
        end

        def on_sym(node)
          return if ignored_node?(node)
          sym_name = node.to_a[0]
          return unless sym_name =~ /^[a-zA-Z]/
          return if sym_name =~ SNAKE_CASE
          return if allow_camel_case? && sym_name =~ CAMEL_CASE
          return if allow_dots? && sym_name =~ SNAKE_CASE_WITH_DOTS
          convention(node, :expression)
        end
      end
    end
  end
end
