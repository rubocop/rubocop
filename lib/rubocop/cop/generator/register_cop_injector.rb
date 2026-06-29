# frozen_string_literal: true

module RuboCop
  module Cop
    class Generator
      # A class that injects a register_cop directive into the cop's department module.
      # It looks for other directives in the same module, and injects the directive in
      # alphabetical order.
      class RegisterCopInjector
        REGISTER_COP_PATTERN = /register_cop :.+, (.+)/.freeze

        MODULE_TEMPLATE = <<~RUBY
          # frozen_string_literal: true

          module RuboCop
            module Cop
              module %<department>s
                extend CopLazyLoader

                %<directive>s
              end
            end
          end
        RUBY

        def initialize(source_path:, root_dir:, badge:, output: $stdout)
          @source_path = Pathname(source_path)
          @root_dir = root_dir
          @department_module_path = Pathname("#{@source_path.dirname}.rb")
          @badge = badge
          @output = output
        end

        def inject # rubocop:disable Metrics/AbcSize
          if File.exist?(department_module_path)
            return if register_cop_directive_exists? || !target_line

            File.write(department_module_path, updated_directives)
            directive = injectable_register_cop_directive.chomp
            output.puts "[modify] #{department_module_path} - `#{directive}` was injected."
          else
            File.write(department_module_path, generated_module)
            output.puts "[create] #{department_module_path}"
          end
        end

        private

        attr_reader :source_path, :root_dir, :department_module_path, :badge, :output

        def register_cop_directive_exists?
          register_cop_entries.any? { |entry| entry.include?(injectable_register_cop_directive) }
        end

        def updated_directives
          indentation = if (entry = register_cop_entries.grep(REGISTER_COP_PATTERN).first)
                          entry[/\A */]
                        else
                          "  #{register_cop_entries[module_end_index][/\A */]}"
                        end

          register_cop_entries.insert(target_line,
                                      "#{indentation}#{injectable_register_cop_directive}").join
        end

        def target_line
          @target_line ||= begin
            inject_parts = directive_fragments(injectable_register_cop_directive)

            register_cop_entries.find.with_index do |entry, index|
              current_entry_parts = directive_fragments(entry)
              next unless current_entry_parts.any?

              break index if inject_parts.last < current_entry_parts.last
            end || last_register_cop_line || module_end_index
          end
        end

        def last_register_cop_line
          return unless (index = register_cop_entries.rindex do |entry|
            entry.match?(REGISTER_COP_PATTERN)
          end)

          index + 1
        end

        def module_end_index
          register_cop_entries.find_index { |entry| entry.strip == 'end' }
        end

        def directive_fragments(register_cop_directive)
          directive = register_cop_directive.match(REGISTER_COP_PATTERN)

          directive ? directive.captures.first.split('/') : []
        end

        def injectable_register_cop_directive
          "register_cop :#{badge.cop_name}, '#{require_path}'\n"
        end

        def require_path
          path = source_path.relative_path_from(root_dir)
          path.to_s.delete_suffix('.rb')
        end

        def generated_module
          format(MODULE_TEMPLATE, department: badge.department_name.gsub('/', '::'),
                                  directive: injectable_register_cop_directive.chomp)
        end

        def register_cop_entries
          @register_cop_entries ||= File.readlines(department_module_path)
        end
      end
    end
  end
end
