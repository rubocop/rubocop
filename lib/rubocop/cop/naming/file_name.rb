# frozen_string_literal: true

require 'pathname'

module RuboCop
  module Cop
    module Naming
      # This cop makes sure that Ruby source files have snake_case
      # names. Ruby scripts (i.e. source files with a shebang in the
      # first line) are ignored.
      #
      # @example
      #   # bad
      #   lib/layoutManager.rb
      #
      #   anything/usingCamelCase
      #
      #   # good
      #   lib/layout_manager.rb
      #
      #   anything/using_snake_case.rake
      class FileName < Cop
        MSG_SNAKE_CASE = 'The name of this source file (`%<basename>s`) ' \
                         'should use snake_case.'.freeze
        MSG_NO_DEFINITION = '%<basename>s should define a class or module ' \
                            'called `%<namespace>s`.'.freeze
        MSG_REGEX = '`%<basename>s` should match `%<regex>s`.'.freeze

        SNAKE_CASE = /^[\da-z_.?!]+$/

        def investigate(processed_source)
          file_path = processed_source.buffer.name
          return if config.file_to_include?(file_path)

          for_bad_filename(file_path) do |range, msg|
            add_offense(nil, location: range, message: msg)
          end
        end

        private

        def for_bad_filename(file_path)
          basename = File.basename(file_path)
          msg = if filename_good?(basename)
                  return unless expect_matching_definition?
                  return if find_class_or_module(processed_source.ast,
                                                 to_namespace(file_path))

                  no_definition_message(basename, file_path)
                else
                  return if ignore_executable_scripts? && shebang?(first_line)
                  other_message(basename)
                end

          yield source_range(processed_source.buffer, 1, 0), msg
        end

        def first_line
          processed_source.lines.first
        end

        def no_definition_message(basename, file_path)
          format(MSG_NO_DEFINITION,
                 basename: basename,
                 namespace: to_namespace(file_path).join('::'))
        end

        def other_message(basename)
          if regex
            format(MSG_REGEX, basename: basename, regex: regex)
          else
            format(MSG_SNAKE_CASE, basename: basename)
          end
        end

        def shebang?(line)
          line && line.start_with?('#!')
        end

        def ignore_executable_scripts?
          cop_config['IgnoreExecutableScripts']
        end

        def expect_matching_definition?
          cop_config['ExpectMatchingDefinition']
        end

        def regex
          cop_config['Regex']
        end

        def allowed_acronyms
          cop_config['AllowedAcronyms'] || []
        end

        def filename_good?(basename)
          basename = basename.sub(/\.[^\.]+$/, '')
          basename =~ (regex || SNAKE_CASE)
        end

        # rubocop:disable Metrics/CyclomaticComplexity
        def find_class_or_module(node, namespace)
          return nil unless node

          name = namespace.pop

          on_node(%i[class module casgn], node) do |child|
            next unless (const = child.defined_module)

            const_namespace, const_name = *const
            next if name != const_name && !match_acronym?(name, const_name)
            next unless namespace.empty? ||
                        match_namespace(child, const_namespace, namespace)

            return node
          end

          nil
        end
        # rubocop:enable Metrics/CyclomaticComplexity

        def match_namespace(node, namespace, expected)
          match_partial = partial_matcher!(expected)

          match_partial.call(namespace)

          node.each_ancestor(:class, :module, :sclass, :casgn) do |ancestor|
            return false if ancestor.sclass_type?
            match_partial.call(ancestor.defined_module)
          end

          match?(expected)
        end

        def partial_matcher!(expected)
          lambda do |namespace|
            while namespace
              return match?(expected) if namespace.cbase_type?

              namespace, name = *namespace

              if name == expected.last || match_acronym?(expected.last, name)
                expected.pop
              end
            end

            false
          end
        end

        def match?(expected)
          expected.empty? || expected == [:Object]
        end

        def match_acronym?(expected, name)
          expected = expected.to_s
          name = name.to_s

          allowed_acronyms.any? do |acronym|
            expected.gsub(acronym.capitalize, acronym) == name
          end
        end

        def to_namespace(path)
          components = Pathname(path).each_filename.to_a
          # To convert a pathname to a Ruby namespace, we need a starting point
          # But RC can be run from any working directory, and can check any path
          # We can't assume that the working directory, or any other, is the
          # "starting point" to build a namespace
          start = %w[lib spec test src]
          start_index = nil

          # To find the closest namespace root take the path components, and
          # then work through them backwards until we find a candidate. This
          # makes sure we work from the actual root in the case of a path like
          # /home/user/src/project_name/lib.
          components.reverse.each_with_index do |c, i|
            if start.include?(c)
              start_index = components.size - i
              break
            end
          end

          if start_index.nil?
            [to_module_name(components.last)]
          else
            components[start_index..-1].map { |c| to_module_name(c) }
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
