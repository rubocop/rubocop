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
              # TODO: Write cop description and example of bad / good code. For every
              # `SupportedStyle` and unique configuration, there needs to be examples.
              # Examples must have valid Ruby syntax. Do not use upticks.
              #
              # @example EnforcedStyle: bar (default)
              #   # Description of the `bar` style.
              #
              #   # bad
              #   bad_bar_method
              #
              #   # bad
              #   bad_bar_method(args)
              #
              #   # good
              #   good_bar_method
              #
              #   # good
              #   good_bar_method(args)
              #
              # @example EnforcedStyle: foo
              #   # Description of the `foo` style.
              #
              #   # bad
              #   bad_foo_method
              #
              #   # bad
              #   bad_foo_method(args)
              #
              #   # good
              #   good_foo_method
              #
              #   # good
              #   good_foo_method(args)
              #
              class %<cop_name>s < Cop
                # TODO: Implement the cop in here.
                #
                # In many cases, you can use a node matcher for matching node pattern.
                # See https://github.com/bbatsov/rubocop/blob/master/lib/rubocop/node_pattern.rb
                #
                # For example
                MSG = 'Use `#good_method` instead of `#bad_method`.'.freeze

                def_node_matcher :bad_method?, <<-PATTERN
                  (send nil? :bad_method ...)
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

        RSpec.describe RuboCop::Cop::%<department>s::%<cop_name>s do
          subject(:cop) { described_class.new(config) }

          let(:config) { RuboCop::Config.new }

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

      def initialize(name, output: $stdout)
        @badge = Badge.parse(name)
        @output = output
        return if badge.qualified?

        raise ArgumentError, 'Specify a cop name with Department/Name style'
      end

      def write_source
        write_unless_file_exists(source_path, generated_source)
      end

      def write_spec
        write_unless_file_exists(spec_path, generated_spec)
      end

      def inject_require(root_file_path: 'lib/rubocop.rb')
        RequireFileInjector.new(
          source_path: source_path,
          root_file_path: root_file_path
        ).inject
      end

      def inject_config(config_file_path: 'config/enabled.yml')
        config = File.readlines(config_file_path)
        content = <<-YAML.strip_indent
          #{badge}:
            Description: 'TODO: Write a description of the cop.'
            Enabled: true

        YAML
        target_line = config.find.with_index(1) do |line, index|
          next if line =~ /^[\s#]/
          break index - 1 if badge.to_s < line
        end
        config.insert(target_line, content)
        File.write(config_file_path, config.join)
        output.puts <<-MESSAGE.strip_indent
          [modify] A configuration for the cop is added into #{config_file_path}.
                   If you want to disable the cop by default, move the added config to config/disabled.yml
        MESSAGE
      end

      def todo
        <<-TODO.strip_indent
          Do 3 steps:
            1. Add an entry to the "New features" section in CHANGELOG.md,
               e.g. "Add new `#{badge}` cop. ([@your_id][])"
            2. Modify the description of #{badge} in config/enabled.yml
            3. Implement your new cop in the generated file!
        TODO
      end

      private

      attr_reader :badge, :output

      def write_unless_file_exists(path, contents)
        if File.exist?(path)
          warn "rake new_cop: #{path} already exists!"
          exit!
        end

        dir = File.dirname(path)
        FileUtils.mkdir_p(dir) unless File.exist?(dir)

        File.write(path, contents)
        output.puts "[create] #{path}"
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
        return 'rspec' if camel_case_string == 'RSpec'
        camel_case_string
          .gsub(/([^A-Z])([A-Z]+)/, '\1_\2')
          .gsub(/([A-Z])([A-Z][^A-Z\d]+)/, '\1_\2')
          .downcase
      end
    end
  end
end
