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
      #   def foo
      #     1
      #   end
      #
      #   def foo
      #     2
      #   end
      #
      # @example
      #
      #   # bad
      #
      #   def foo
      #     1
      #   end
      #
      #   alias foo bar
      #
      # @example
      #
      #   # good
      #
      #   def foo
      #     1
      #   end
      #
      #   def bar
      #     2
      #   end
      #
      # @example
      #
      #   # good
      #
      #   def foo
      #     1
      #   end
      #
      #   alias bar foo
      class DuplicateMethods < Base
        MSG = 'Method `%<method>s` is defined at both %<defined>s and ' \
              '%<current>s.'

        RESTRICT_ON_SEND = %i[alias_method attr_reader attr_writer
                              attr_accessor attr].freeze

        def initialize(config = nil, options = nil)
          super
          @definitions = {}
        end

        def on_def(node)
          # if a method definition is inside an if, it is very likely
          # that a different definition is used depending on platform, etc.
          return if node.ancestors.any?(&:if_type?)
          return if possible_dsl?(node)

          found_instance_method(node, node.method_name)
        end

        def on_defs(node)
          return if node.ancestors.any?(&:if_type?)
          return if possible_dsl?(node)

          if node.receiver.const_type?
            _, const_name = *node.receiver
            check_const_receiver(node, node.method_name, const_name)
          elsif node.receiver.self_type?
            check_self_receiver(node, node.method_name)
          end
        end

        # @!method method_alias?(node)
        def_node_matcher :method_alias?, <<~PATTERN
          (alias (sym $_name) sym)
        PATTERN

        def on_alias(node)
          return unless (name = method_alias?(node))
          return if node.ancestors.any?(&:if_type?)
          return if possible_dsl?(node)

          found_instance_method(node, name)
        end

        # @!method alias_method?(node)
        def_node_matcher :alias_method?, <<~PATTERN
          (send nil? :alias_method (sym $_name) _)
        PATTERN

        # @!method sym_name(node)
        def_node_matcher :sym_name, '(sym $_name)'
        def on_send(node)
          if (name = alias_method?(node))
            return if node.ancestors.any?(&:if_type?)
            return if possible_dsl?(node)

            found_instance_method(node, name)
          elsif (attr = node.attribute_accessor?)
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
          format(MSG, method: method_name, defined: source_location(@definitions[method_name]),
                      current: source_location(node))
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
            loc = case node.type
                  when :def, :defs
                    node.loc.keyword.join(node.loc.name)
                  else
                    node.loc.expression
                  end
            message = message_for_dup(node, method_name)

            add_offense(loc, message: message)
          else
            @definitions[method_name] = node
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
