# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop checks for duplicated instance (or singleton) method
      # definitions.
      #
      # @example
      #
      #   # bad
      #
      #   def duplicated
      #     1
      #   end
      #
      #   def duplicated
      #     2
      #   end
      #
      # @example
      #
      #   # bad
      #
      #   def duplicated
      #     1
      #   end
      #
      #   alias duplicated other_duplicated
      #
      # @example
      #
      #   # good
      #
      #   def duplicated
      #     1
      #   end
      #
      #   def other_duplicated
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

          name, = *node
          found_instance_method(node, name)
        end

        def on_defs(node)
          return if node.ancestors.any?(&:if_type?)
          return if possible_dsl?(node)

          receiver, name, = *node
          if receiver.const_type?
            _, const_name = *receiver
            check_const_receiver(node, name, const_name)
          elsif receiver.self_type?
            check_self_receiver(node, name)
          end
        end

        def_node_matcher :method_alias?, <<-PATTERN
          (alias (sym $_name) sym)
        PATTERN

        def on_alias(node)
          return unless (name = method_alias?(node))
          return if node.ancestors.any?(&:if_type?)
          return if possible_dsl?(node)

          found_instance_method(node, name)
        end

        def_node_matcher :alias_method?, <<-PATTERN
          (send nil? :alias_method (sym $_name) _)
        PATTERN

        def_node_matcher :attr?, <<-PATTERN
          (send nil? ${:attr_reader :attr_writer :attr_accessor :attr} $...)
        PATTERN

        def_node_matcher :sym_name, '(sym $_name)'

        def on_send(node)
          if (name = alias_method?(node))
            return unless name
            return if node.ancestors.any?(&:if_type?)
            return if possible_dsl?(node)

            found_instance_method(node, name)
          elsif (attr = attr?(node))
            on_attr(node, *attr)
          end
        end

        private

        def check_const_receiver(node, name, const_name)
          qualified = lookup_constant(node, const_name)
          return unless qualified

          found_method(node, "#{qualified}.#{name}")
        end

        def check_self_receiver(node, name)
          enclosing = node.parent_module_name
          return unless enclosing

          found_method(node, "#{enclosing}.#{name}")
        end

        def message_for_dup(node, method_name)
          format(MSG, method_name, @definitions[method_name],
                 source_location(node))
        end

        def found_instance_method(node, name)
          return unless (scope = node.parent_module_name)
          if scope =~ /\A#<Class:(.*)>\Z/
            found_method(node, "#{Regexp.last_match(1)}.#{name}")
          else
            found_method(node, "#{scope}##{name}")
          end
        end

        def found_method(node, method_name)
          if @definitions.key?(method_name)
            loc = node.send_type? ? node.loc.selector : node.loc.keyword
            message = message_for_dup(node, method_name)

            add_offense(node, location: loc, message: message)
          else
            @definitions[method_name] = source_location(node)
          end
        end

        def on_attr(node, attr_name, args)
          case attr_name
          when :attr
            writable = args.size == 2 && args.last.true_type?
            found_attr(node, [args.first], readable: true, writable: writable)
          when :attr_reader
            found_attr(node, args, readable: true)
          when :attr_writer
            found_attr(node, args, writable: true)
          when :attr_accessor
            found_attr(node, args, readable: true, writable: true)
          end
        end

        def found_attr(node, args, readable: false, writable: false)
          args.each do |arg|
            name = sym_name(arg)
            next unless name
            found_instance_method(node, name) if readable
            found_instance_method(node, "#{name}=") if writable
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
          path = smart_path(range.source_buffer.name)
          "#{path}:#{range.line}"
        end
      end
    end
  end
end
