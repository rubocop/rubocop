# encoding: utf-8

module RuboCop
  module Cop
    module Metrics
      # This cop checks if the length a method exceeds some maximum value.
      # Comment lines can optionally be ignored.
      # The maximum allowed length is configurable.
      # Methods can be ignored by name (e.g. MyModule::MyClass#my_method).
      class MethodLength < Cop
        include OnMethodDef
        include CodeLength

        private

        def on_method_def(node, method_name, _args, _body)
          separator = method_separator(node)
          full_name = [namespace(node), method_name].join(separator)

          check_code_length(node) unless ignored_methods.include?(full_name)
        end

        def namespace(node)
          modules = node.ancestors.select do |ancestor|
            [:class, :module].include?(ancestor.type)
          end

          modules.map { |mod| mod.loc.name.source }.reverse.join('::')
        end

        def method_separator(node)
          class_method?(node) ? '.' : '#'
        end

        def class_method?(node)
          node.type == :defs || (node.parent && node.parent.sclass_type?)
        end

        def ignored_methods
          cop_config['IgnoredMethods'] || []
        end

        def message(length, max_length)
          format('Method has too many lines. [%d/%d]', length, max_length)
        end

        def code_length(node)
          lines = node.loc.expression.source.lines.to_a[1..-2] || []

          lines.reject! { |line| irrelevant_line(line) }

          lines.size
        end
      end
    end
  end
end
