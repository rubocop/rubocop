# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks that RSpec unit tests conform to a consistent naming
      # scheme - both for the describe call, and the file path.
      #
      # Disabled by default. Generally, you want to scope it to your project's
      # unit spec paths:
      #
      #   UnitSpecNaming:
      #     Enabled: true
      #     Include:
      #       - 'spec/rubocop/*'
      #
      class UnitSpecNaming < Cop
        DESCRIBE_CLASS_MSG = 'The first argument to describe should be the ' \
                             'class or module being tested.'

        METHOD_STRING_MSG = 'The second argument to describe should be the ' \
                            "method being tested. '#instance' or '.class'"

        CLASS_SPEC_MSG = 'Class unit spec should have a path ending with %s'

        METHOD_SPEC_MSG = 'Unit spec should have a path matching %s'

        METHOD_STRING_MATCHER = /^[\#\.].+/

        def on_send(node)
          return unless top_level_describe? node
          _receiver, _method_name, *args = *node
          # Ignore non-string args (RSpec metadata)
          args = [args.first] + args[1..-1].select { |a| a.type == :str }

          if cop_config['EnforceDescribeStatement']
            enforce_describe_statement(node, args)
          end

          if offences.size == 0 && cop_config['EnforceFilenames']
            enforce_filename(node, args)
          end
        end

        private

        def enforce_describe_statement(node, args)
          check_described_class(node, args.first)
          check_described_method(node, args[1])
        end

        def enforce_filename(node, args)
          class_name = const_name(args.first)
          path_parts = class_name.split('::').map do |part|
            camel_to_underscore(part)
          end

          if !args[1]
            check_class_spec(node, path_parts)
          else
            method_str = args[1].children.first if args[1]
            path_parts << 'class_methods' if method_str.start_with? '.'
            check_method_spec(node, path_parts, method_str)
          end
        end

        def check_described_class(node, first_arg)
          if !first_arg || first_arg.type != :const
            add_offence(first_arg || node, :expression, DESCRIBE_CLASS_MSG)
          end
        end

        def check_described_method(node, second_arg)
          return unless second_arg

          unless METHOD_STRING_MATCHER =~ second_arg.children.first
            add_offence(second_arg, :expression, METHOD_STRING_MSG)
          end
        end

        def check_class_spec(node, path_parts)
          spec_path = File.join(path_parts) + '_spec.rb'
          unless source_filename.end_with? spec_path
            add_offence(node, :expression, format(CLASS_SPEC_MSG, spec_path))
          end
        end

        def check_method_spec(node, path_parts, method_str)
          matcher_parts = path_parts.dup
          # Strip out symbols; it's not worth enforcing a vocabulary for them.
          matcher_parts << method_str[1..-1].gsub(/\W+/, '*') + '_spec.rb'

          glob_matcher = File.join(matcher_parts)
          unless source_filename =~ regexp_from_glob(glob_matcher)
            message = format(METHOD_SPEC_MSG, glob_matcher)
            add_offence(node, :expression, message)
          end
        end

        def top_level_describe?(node)
          _receiver, method_name, *_args = *node
          return false unless method_name == :describe

          root_node = processed_source.ast
          top_level_nodes = describe_statement_children(root_node)
          # If we have no top level describe statements, we need to check any
          # blocks on the top level (e.g. after a require).
          if top_level_nodes.size == 0
            top_level_nodes = node_children(root_node).map do |child|
              describe_statement_children(child) if child.type == :block
            end.flatten.compact
          end

          top_level_nodes.include? node
        end

        def describe_statement_children(node)
          node_children(node).select do |element|
            element.type == :send && element.children[1] == :describe
          end
        end

        def source_filename
          processed_source.buffer.name
        end

        def camel_to_underscore(string)
          string.dup.tap do |result|
            result.gsub!(/([^A-Z])([A-Z]+)/,       '\\1_\\2')
            result.gsub!(/([A-Z]+)([A-Z][^A-Z]+)/, '\\1_\\2')
            result.downcase!
          end
        end

        def regexp_from_glob(glob)
          Regexp.new(glob.gsub('.', '\\.').gsub('*', '.*') + '$')
        end
      end
    end
  end
end
