# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop checks for duplicated instance (or singleton) method
      # definitions.
      #
      # @example
      #   @bad
      #   def duplicated
      #     1
      #   end
      #
      #   def duplicated
      #     2
      #   end
      class DuplicateMethods < Cop
        MSG = 'Method `%s` is defined at both %s and %s.'.freeze

        def initialize(config = nil, options = nil)
          super
          @definitions = {}
        end

        def on_def(node)
          # if a method definition is inside an if, it is very likely
          # that a different definition is used depending on platform, etc.
          return if node.ancestors.any?(&:if_type?)
          return if possible_dsl?(node)

          return unless (scope = node.parent_module_name)
          found_instance_method(node, scope)
        end

        def on_defs(node)
          return if node.ancestors.any?(&:if_type?)
          return if possible_dsl?(node)

          receiver, name, = *node
          if receiver.const_type?
            _, const_name = *receiver
            if (qualified = lookup_constant(node, const_name))
              found_method(node, "#{qualified}.#{name}")
            end
          elsif receiver.self_type?
            if (enclosing = node.parent_module_name)
              found_method(node, "#{enclosing}.#{name}")
            end
          end
        end

        private

        def message_for_dup(node, method_name)
          format(MSG, method_name, @definitions[method_name],
                 source_location(node))
        end

        def found_instance_method(node, scope)
          name, = *node
          if scope =~ /\A#<Class:(.*)>\Z/
            found_method(node, "#{Regexp.last_match(1)}.#{name}")
          else
            found_method(node, "#{scope}##{name}")
          end
        end

        def found_method(node, method_name)
          if @definitions.key?(method_name)
            add_offense(node, :keyword, message_for_dup(node, method_name))
          else
            @definitions[method_name] = source_location(node)
          end
        end

        def lookup_constant(node, const_name)
          # this method is quite imperfect and can be fooled
          # to do much better, we would need to do global analysis of the whole
          # codebase
          node.each_ancestor(:class, :module, :casgn) do |ancestor|
            namespace, mod_name = *ancestor.defined_module
            loop do
              if mod_name == const_name
                return qualified_name(ancestor.parent_module_name,
                                      namespace,
                                      mod_name)
              end

              break if namespace.nil?
              namespace, mod_name = *namespace
            end
          end
        end

        def qualified_name(enclosing, namespace, mod_name)
          if enclosing != 'Object'
            if namespace
              "#{enclosing}::#{namespace.const_name}::#{mod_name}"
            else
              "#{enclosing}::#{mod_name}"
            end
          elsif namespace
            "#{namespace.const_name}::#{mod_name}"
          else
            mod_name
          end
        end

        def possible_dsl?(node)
          # DSL methods may evaluate a block in the context of a newly created
          # class or module
          # Assume that if a method definition is inside any block call which
          # we can't identify, it could be a DSL
          node.each_ancestor(:block).any? do |ancestor|
            ancestor.method_name != :class_eval && !ancestor.class_constructor?
          end
        end

        def source_location(node)
          range = node.location.expression
          "#{range.source_buffer.name}:#{range.line}"
        end
      end
    end
  end
end
