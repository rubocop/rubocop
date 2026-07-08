# frozen_string_literal: true

module RuboCop
  module Cop
    class Generator
      # A class that injects a `register_cop` directive into the cop's department module
      # so that the new cop is registered for lazy loading.
      # The directive is injected in alphabetical order among the existing directives without
      # reordering them, since the registration order defines the cop execution order.
      # When the department module file does not exist yet, it is created, and a require for
      # it is injected into the root RuboCop file.
      #
      # Anything unexpected in the department module, such as a commented-out or otherwise
      # unparsable `register_cop` line, raises an error instead of silently producing
      # a broken registration.
      class RegistrationInjector
        EXTEND_PATTERN = /\A(?<indent>\s*)extend LazyLoader\n\z/.freeze
        ENTRY_PATTERN = %r{
          \A(?<indent>\s*)register_cop\s
          :(?<constant>[A-Za-z0-9]+),\s
          "\#\{__dir__\}/(?<path>[a-z0-9_/]+)"\n\z
        }x.freeze
        DEPARTMENT_REQUIRE_PATTERN = %r{\Arequire_relative 'rubocop/cop/[a-z0-9_/]+'\n\z}.freeze

        def initialize(source_path:, badge:, root_file_path: 'lib/rubocop.rb', output: $stdout)
          @source_path = Pathname(source_path)
          @badge = badge
          @root_file_path = root_file_path
          @department_file_path = Pathname("#{@source_path.dirname}.rb")
          @output = output
        end

        def inject
          if File.exist?(department_file_path)
            inject_directive
          else
            create_department_file
            inject_department_require
          end
        end

        private

        attr_reader :source_path, :badge, :root_file_path, :department_file_path, :output

        def inject_directive
          lines = File.readlines(department_file_path)
          entries = parse_entries(lines)
          return if entries.any? { |entry| entry[:path] == cop_path }

          line, indent = insertion_point(lines, entries)
          lines.insert(line, "#{indent}#{directive}\n")

          write_department_file(lines)
        end

        def create_department_file
          File.write(department_file_path, department_module_source)

          output.puts "[create] #{department_file_path}"
        end

        def inject_department_require
          require_path = department_file_path.sub_ext('').to_s.delete_prefix('lib/')
          require_directive = "require_relative '#{require_path}'\n"

          lines = File.readlines(root_file_path)
          return if lines.include?(require_directive)

          lines.insert(department_require_index(lines, require_directive), require_directive)
          File.write(root_file_path, lines.join)

          output.puts "[modify] #{root_file_path} - `#{require_directive.strip}` was injected."
        end

        def write_department_file(lines)
          File.write(department_file_path, lines.join)

          output.puts "[modify] #{department_file_path} - `#{directive}` was injected."
        end

        # @return [Array<Hash>] the `register_cop` entries with their line numbers
        def parse_entries(lines)
          lines.filter_map.with_index do |line, index|
            match = ENTRY_PATTERN.match(line)

            if match
              { line: index, indent: match[:indent], constant: match[:constant],
                path: match[:path] }
            elsif line.include?('register_cop')
              raise Error, "unexpected `register_cop` line in #{department_file_path}:" \
                           "#{index + 1}; fix it or register the cop manually: #{line}"
            end
          end
        end

        # The directive path is relative to the department module file's directory,
        # which `__dir__` resolves to at load time.
        def cop_path
          source_path.relative_path_from(department_file_path.dirname).to_s.delete_suffix('.rb')
        end

        def insertion_point(lines, entries)
          if entries.empty?
            first_directive_position(lines)
          else
            successor = entries.find { |entry| entry[:path] > cop_path }
            entry = successor || entries.last

            [entry[:line] + (successor ? 0 : 1), entry[:indent]]
          end
        end

        def directive
          "register_cop :#{badge.cop_name}, \"\#{__dir__}/#{cop_path}\""
        end

        # The department requires form the contiguous block right before
        # the `rubocop/cop/team` require in the root RuboCop file.
        def department_require_index(lines, require_directive)
          anchor = lines.index("require_relative 'rubocop/cop/team'\n")
          unless anchor
            raise Error, "could not find the department require block in #{root_file_path}"
          end

          block_end = anchor - 1
          block_end -= 1 while lines[block_end] == "\n"
          block_start = block_end
          block_start -= 1 while lines[block_start - 1]&.match?(DEPARTMENT_REQUIRE_PATTERN)

          (block_start..block_end).find do |index|
            lines[index] > require_directive
          end || (block_end + 1)
        end

        def first_directive_position(lines)
          extend_lines = lines.filter_map.with_index do |line, index|
            [index, EXTEND_PATTERN.match(line)[:indent]] if EXTEND_PATTERN.match?(line)
          end

          unless extend_lines.size == 1
            raise Error, "expected `extend LazyLoader` in #{department_file_path}; " \
                         'add it or register the cop manually'
          end

          index, indent = extend_lines.first
          blank_after_extend = lines[index + 1] == "\n"

          [index + (blank_after_extend ? 2 : 1), indent]
        end

        def department_module_source
          modules = %w[RuboCop Cop] + badge.department.to_s.split('/')
          body_indent = '  ' * modules.size

          lines = ['# frozen_string_literal: true', '']
          lines.concat(module_opening_lines(modules))
          lines << "#{body_indent}extend LazyLoader"
          lines << ''
          lines << "#{body_indent}#{directive}"
          lines.concat(module_closing_lines(modules))

          "#{lines.join("\n")}\n"
        end

        def module_opening_lines(modules)
          modules.flat_map.with_index do |mod, nesting|
            indent = '  ' * nesting
            lines = []

            if mod == modules.last
              lines << "#{indent}# Cops for the `#{badge.department}` department. " \
                       "The department's cops are"
              lines << "#{indent}# registered for lazy loading and their files are " \
                       'loaded on demand.'
            end

            lines << "#{indent}module #{mod}"
          end
        end

        def module_closing_lines(modules)
          (modules.size - 1).downto(0).map { |nesting| "#{'  ' * nesting}end" }
        end
      end
    end
  end
end
