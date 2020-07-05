# frozen_string_literal: true

require 'set'

module RuboCop
  module Cop
    module Style
      # This cop checks for places where `attr_reader` and `attr_writer`
      # for the same method can be combined into single `attr_accessor`.
      #
      # @example
      #   # bad
      #   class Foo
      #     attr_reader :bar
      #     attr_writer :bar
      #   end
      #
      #   # good
      #   class Foo
      #     attr_accessor :bar
      #   end
      #
      class BisectedAttrAccessor < Cop
        MSG = 'Combine both accessors into `attr_accessor :%<name>s`.'

        def on_class(class_node)
          reader_names, writer_names = accessor_names(class_node)

          accessor_macroses(class_node).each do |macro|
            check(macro, reader_names, writer_names)
          end
        end
        alias on_module on_class

        def autocorrect(node)
          macro = node.parent

          lambda do |corrector|
            corrector.replace(macro, replacement(macro, node))
          end
        end

        private

        def accessor_names(class_node)
          reader_names = Set.new
          writer_names = Set.new

          accessor_macroses(class_node).each do |macro|
            names = macro.arguments.map(&:value)

            names.each do |name|
              if attr_reader?(macro)
                reader_names.add(name)
              else
                writer_names.add(name)
              end
            end
          end

          [reader_names, writer_names]
        end

        def accessor_macroses(class_node)
          class_def = class_node.body
          return [] if !class_def || class_def.def_type?

          send_nodes =
            if class_def.send_type?
              [class_def]
            else
              class_def.each_child_node(:send)
            end

          send_nodes.select { |node| node.macro? && (attr_reader?(node) || attr_writer?(node)) }
        end

        def attr_reader?(send_node)
          send_node.method?(:attr_reader) || send_node.method?(:attr)
        end

        def attr_writer?(send_node)
          send_node.method?(:attr_writer)
        end

        def check(macro, reader_names, writer_names)
          macro.arguments.each do |arg_node|
            name = arg_node.value

            if (attr_reader?(macro) && writer_names.include?(name)) ||
               (attr_writer?(macro) && reader_names.include?(name))
              add_offense(arg_node, message: format(MSG, name: name))
            end
          end
        end

        def replacement(macro, node)
          rest_args = macro.arguments
          rest_args.delete(node)
          args = rest_args.map(&:source).join(', ')

          if attr_reader?(macro)
            if args.empty?
              "attr_accessor #{node.source}"
            else
              "attr_accessor #{node.source}\n#{indent(macro)}#{macro.method_name} #{args}"
            end
          elsif args.empty?
            ''
          else
            "#{indent(macro)}#{macro.method_name} #{args}"
          end
        end

        def indent(node)
          ' ' * node.loc.column
        end
      end
    end
  end
end
