# frozen_string_literal: true

module RuboCop
  module Cop
    # Source and spec generator for new cops
    #
    # This generator will take a cop name and generate a source file
    # and spec file when given a valid qualified cop name.
    class Generator
      SOURCE_TEMPLATE = <<-RUBY.strip_indent
        # frozen_string_literal: true

        # TODO: when finished, run `rake generate_cops_documentation` to update the docs
        module RuboCop
          module Cop
            module %<department>s
              # TODO: Write cop description and example of bad / good code.
              #
              # @example
              #   # bad
              #   bad_method()
              #
              #   # bad
              #   bad_method(args)
              #
              #   # good
              #   good_method()
              #
              #   # good
              #   good_method(args)
              class %<cop_name>s < Cop
                # TODO: Implement the cop into here.
                #
                # In many cases, you can use a node matcher for matching node pattern.
                # See. https://github.com/bbatsov/rubocop/blob/master/lib/rubocop/node_pattern.rb
                #
                # For example
                MSG = 'Message of %<cop_name>s'.freeze

                def_node_matcher :bad_method?, <<-PATTERN
                  (send nil :bad_method ...)
                PATTERN

                def on_send(node)
                  return unless bad_method?(node)
                  add_offense(node)
                end
              end
            end
          end
        end
      RUBY

      SPEC_TEMPLATE = <<-SPEC.strip_indent
        # frozen_string_literal: true

        describe RuboCop::Cop::%<department>s::%<cop_name>s do
          let(:config) { RuboCop::Config.new }
          subject(:cop) { described_class.new(config) }

          # TODO: Write test code
          #
          # For example
          it 'registers an offense when using `#bad_method`' do
            expect_offense(<<-RUBY.strip_indent)
              bad_method
              ^^^^^^^^^^ Use `#good_method` instead of `#bad_method`.
            RUBY
          end

          it 'does not register an offense when using `#good_method`' do
            expect_no_offenses(<<-RUBY.strip_indent)
              good_method
            RUBY
          end
        end
      SPEC

      def initialize(name)
        @badge = Badge.parse(name)

        return if badge.qualified?

        raise ArgumentError, 'Specify a cop name with Department/Name style'
      end

      def write_source
        write_unless_file_exists(source_path, generated_source)
      end

      def write_spec
        write_unless_file_exists(spec_path, generated_spec)
      end

      def inject_require
        RequireFileInjector.new(require_path).inject
      end

      def todo
        <<-TODO.strip_indent
          Files created:
            - #{source_path}
            - #{spec_path}
          File modified:
            - `require_relative '#{require_path}'` added into lib/rubocop.rb

          Do 3 steps:
            1. Add an entry to the "New features" section in CHANGELOG.md,
               e.g. "Add new `#{badge}` cop. ([@your_id][])"
            2. Add an entry into config/enabled.yml or config/disabled.yml
            3. Implement your new cop in the generated file!
        TODO
      end

      private

      attr_reader :badge

      def write_unless_file_exists(path, contents)
        raise "#{path} already exists!" if File.exist?(path)

        dir = File.dirname(path)
        FileUtils.mkdir_p(dir) unless File.exist?(dir)

        File.write(path, contents)
      end

      def generated_source
        generate(SOURCE_TEMPLATE)
      end

      def generated_spec
        generate(SPEC_TEMPLATE)
      end

      def generate(template)
        format(template, department: badge.department, cop_name: badge.cop_name)
      end

      def require_path
        source_path.sub('lib/', '').sub('.rb', '')
      end

      def spec_path
        File.join(
          'spec',
          'rubocop',
          'cop',
          snake_case(badge.department.to_s),
          "#{snake_case(badge.cop_name.to_s)}_spec.rb"
        )
      end

      def source_path
        File.join(
          'lib',
          'rubocop',
          'cop',
          snake_case(badge.department.to_s),
          "#{snake_case(badge.cop_name.to_s)}.rb"
        )
      end

      def snake_case(camel_case_string)
        camel_case_string
          .gsub(/([^A-Z])([A-Z]+)/, '\1_\2')
          .gsub(/([A-Z])([A-Z][^A-Z\d]+)/, '\1_\2')
          .downcase
      end

      # A class that injects a require directive into the root RuboCop file.
      # It looks for other directives that require files in the same (cop)
      # namespace and injects the provided one in alpha
      class RequireFileInjector
        REQUIRE_PATH = /require_relative ['"](.+)['"]/

        def initialize(require_path)
          @require_path    = require_path
          @require_entries = File.readlines(rubocop_root_file_path)
        end

        def inject
          return if require_exists? || !target_line

          File.write(rubocop_root_file_path, updated_directives)
        end

        private

        attr_reader :require_path, :require_entries

        def rubocop_root_file_path
          File.join('lib', 'rubocop.rb')
        end

        def require_exists?
          require_entries.any? do |entry|
            entry == injectable_require_directive
          end
        end

        def updated_directives
          require_entries.insert(target_line,
                                 injectable_require_directive).join
        end

        def target_line
          @target_line ||= begin
            in_the_same_department = false
            inject_parts = require_path_fragments(injectable_require_directive)

            require_entries.find.with_index do |entry, index|
              current_entry_parts = require_path_fragments(entry)

              if inject_parts[0..-2] == current_entry_parts[0..-2]
                in_the_same_department = true

                break index if inject_parts.last < current_entry_parts.last
              elsif in_the_same_department
                break index
              end
            end
          end
        end

        def require_path_fragments(require_directove)
          path = require_directove.match(REQUIRE_PATH)

          path ? path.captures.first.split('/') : []
        end

        def injectable_require_directive
          "require_relative '#{require_path}'\n"
        end
      end
    end
  end
end
