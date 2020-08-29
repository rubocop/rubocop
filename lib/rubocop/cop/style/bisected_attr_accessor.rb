# frozen_string_literal: true

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
      class BisectedAttrAccessor < Base
        include VisibilityHelp
        extend AutoCorrector

        MSG = 'Combine both accessors into `attr_accessor %<name>s`.'

        def on_class(class_node)
          VISIBILITY_SCOPES.each do |visibility|
            reader_names, writer_names = accessor_names(class_node, visibility)
            next unless reader_names && writer_names

            accessor_macroses(class_node, visibility).each do |macro|
              check(macro, reader_names, writer_names)
            end
          end
        end
        alias on_sclass on_class
        alias on_module on_class

        private

        def accessor_names(class_node, visibility)
          reader_names = nil
          writer_names = nil

          accessor_macroses(class_node, visibility).each do |macro|
            names = macro.arguments.map(&:source)

            names.each do |name|
              if attr_reader?(macro)
                (reader_names ||= Set.new).add(name)
              else
                (writer_names ||= Set.new).add(name)
              end
            end
          end

          [reader_names, writer_names]
        end

        def accessor_macroses(class_node, visibility)
          class_def = class_node.body
          return [] if !class_def || class_def.def_type?

          send_nodes =
            if class_def.send_type?
              [class_def]
            else
              class_def.each_child_node(:send)
            end

          send_nodes.select { |node| attr_within_visibility_scope?(node, visibility) }
        end

        def attr_within_visibility_scope?(node, visibility)
          node.macro? &&
            (attr_reader?(node) || attr_writer?(node)) &&
            node_visibility(node) == visibility
        end

        def attr_reader?(send_node)
          send_node.method?(:attr_reader) || send_node.method?(:attr)
        end

        def attr_writer?(send_node)
          send_node.method?(:attr_writer)
        end

        def check(macro, reader_names, writer_names)
          macro.arguments.each do |arg_node|
            name = arg_node.source

            next unless (attr_reader?(macro) && writer_names.include?(name)) ||
                        (attr_writer?(macro) && reader_names.include?(name))

            add_offense(arg_node, message: format(MSG, name: name)) do |corrector|
              macro = arg_node.parent

              corrector.replace(macro, replacement(macro, arg_node))
            end
          end
        end

        def replacement(macro, node)
          class_node = macro.each_ancestor(:class, :sclass, :module).first
          reader_names, writer_names = accessor_names(class_node, node_visibility(macro))

          rest_args = rest_args(macro.arguments, reader_names, writer_names)

          if attr_reader?(macro)
            attr_reader_replacement(macro, node, rest_args)
          elsif rest_args.empty?
            ''
          else
            "#{macro.method_name} #{rest_args.map(&:source).join(', ')}"
          end
        end

        def rest_args(args, reader_names, writer_names)
          args.reject do |arg|
            name = arg.source
            reader_names.include?(name) && writer_names.include?(name)
          end
        end

        def attr_reader_replacement(macro, node, rest_args)
          if rest_args.empty?
            "attr_accessor #{node.source}"
          else
            "attr_accessor #{node.source}\n"\
            "#{indent(macro)}#{macro.method_name} #{rest_args.map(&:source).join(', ')}"
          end
        end

        def indent(node)
          ' ' * node.loc.column
        end
      end
    end
  end
end
