# encoding: utf-8
# frozen_string_literal: true

require 'pathname'

module RuboCop
  module Cop
    module Style
      # This cop makes sure that Ruby source files have snake_case
      # names. Ruby scripts (i.e. source files with a shebang in the
      # first line) are ignored.
      class FileName < Cop
        MSG_SNAKE_CASE = 'Use snake_case for source file names.'.freeze
        MSG_NO_DEFINITION = '%s should define a class or module ' \
                            'called `%s`.'.freeze
        MSG_REGEX = '`%s` should match `%s`.'.freeze

        SNAKE_CASE = /^[\da-z_.]+$/

        def investigate(processed_source)
          file_path = processed_source.buffer.name
          return if config.file_to_include?(file_path)

          basename = File.basename(file_path)
          if filename_good?(basename)
            return unless expect_matching_definition?
            return if find_class_or_module(processed_source.ast,
                                           to_namespace(file_path))
            range = source_range(processed_source.buffer, 1, 0)
            msg   = format(MSG_NO_DEFINITION,
                           basename,
                           to_namespace(file_path).join('::'))
          else
            first_line = processed_source.lines.first
            return if cop_config['IgnoreExecutableScripts'] &&
                      shebang?(first_line)

            range = source_range(processed_source.buffer, 1, 0)
            msg = regex ? format(MSG_REGEX, basename, regex) : MSG_SNAKE_CASE
          end

          add_offense(nil, range, msg)
        end

        private

        def shebang?(line)
          line && line.start_with?('#!')
        end

        def expect_matching_definition?
          cop_config['ExpectMatchingDefinition']
        end

        def regex
          cop_config['Regex']
        end

        def filename_good?(basename)
          basename = basename.sub(/\.[^\.]+$/, '')
          basename =~ (regex || SNAKE_CASE)
        end

        def find_class_or_module(node, namespace)
          return nil if node.nil?
          name = namespace.pop

          on_node([:class, :module, :casgn], node) do |child|
            next unless (const = child.defined_module)

            const_namespace, const_name = *const
            next unless name == const_name

            return node if namespace.empty?
            return node if match_namespace(child, const_namespace, namespace)
          end
          nil
        end

        def match_namespace(node, namespace, expected)
          expected = expected.dup

          match_partial = lambda do |ns|
            next if ns.nil?
            while ns
              return expected.empty? || expected == [:Object] if ns.cbase_type?
              ns, name = *ns
              name == expected.last ? expected.pop : (return false)
            end
          end

          match_partial.call(namespace)

          node.each_ancestor(:class, :module, :sclass, :casgn) do |ancestor|
            return false if ancestor.sclass_type?
            match_partial.call(ancestor.defined_module)
          end

          expected.empty? || expected == [:Object]
        end

        def to_namespace(path)
          components = Pathname(path).each_filename.to_a
          # To convert a pathname to a Ruby namespace, we need a starting point
          # But RC can be run from any working directory, and can check any path
          # We can't assume that the working directory, or any other, is the
          # "starting point" to build a namespace
          start = %w(lib spec test src)
          if components.find { |c| start.include?(c) }
            components = components.drop_while { |c| !start.include?(c) }
            components.drop(1).map { |fn| to_module_name(fn) }
          else
            [to_module_name(components.last)]
          end
        end

        def to_module_name(basename)
          words = basename.sub(/\..*/, '').split('_')
          words.map(&:capitalize).join.to_sym
        end
      end
    end
  end
end
