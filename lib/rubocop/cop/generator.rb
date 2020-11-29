# frozen_string_literal: true

module RuboCop
  module Cop
    # Source and spec generator for new cops
    #
    # This generator will take a cop name and generate a source file
    # and spec file when given a valid qualified cop name.
    # @api private
    class Generator
      # NOTE: RDoc 5.1.0 or lower has the following issue.
      # https://github.com/rubocop-hq/rubocop/issues/7043
      #
      # The following `String#gsub` can be replaced with
      # squiggly heredoc when RuboCop supports Ruby 2.5 or higher
      # (RDoc 6.0 or higher).
      SOURCE_TEMPLATE = <<-RUBY.gsub(/^ {8}/, '')
        # frozen_string_literal: true

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
              class %<cop_name>s < Base
                # TODO: Implement the cop in here.
                #
                # In many cases, you can use a node matcher for matching node pattern.
                # See https://github.com/rubocop-hq/rubocop-ast/blob/master/lib/rubocop/ast/node_pattern.rb
                #
                # For example
                MSG = 'Use `#good_method` instead of `#bad_method`.'

                def_node_matcher :bad_method?, <<~PATTERN
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

      SPEC_TEMPLATE = <<~SPEC
        # frozen_string_literal: true

        RSpec.describe RuboCop::Cop::%<department>s::%<cop_name>s do
          subject(:cop) { described_class.new(config) }

          let(:config) { RuboCop::Config.new }

          # TODO: Write test code
          #
          # For example
          it 'registers an offense when using `#bad_method`' do
            expect_offense(<<~RUBY)
              bad_method
              ^^^^^^^^^^ Use `#good_method` instead of `#bad_method`.
            RUBY
          end

          it 'does not register an offense when using `#good_method`' do
            expect_no_offenses(<<~RUBY)
              good_method
            RUBY
          end
        end
      SPEC

      CONFIGURATION_ADDED_MESSAGE =
        '[modify] A configuration for the cop is added into ' \
          '%<configuration_file_path>s.'

      def initialize(name, github_user, output: $stdout)
        @badge = Badge.parse(name)
        @github_user = github_user
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

      def inject_config(config_file_path: 'config/default.yml',
                        version_added: '<<next>>')
        injector =
          ConfigurationInjector.new(configuration_file_path: config_file_path,
                                    badge: badge,
                                    version_added: version_added)

        injector.inject do # rubocop:disable Lint/UnexpectedBlockArity
          output.puts(format(CONFIGURATION_ADDED_MESSAGE,
                             configuration_file_path: config_file_path))
        end
      end

      def todo
        <<~TODO
          Do 3 steps:
            1. Add an entry to the "New features" section in CHANGELOG.md,
               e.g. "Add new `#{badge}` cop. ([@#{github_user}][])"
            2. Modify the description of #{badge} in config/default.yml
            3. Implement your new cop in the generated file!
        TODO
      end

      private

      attr_reader :badge, :github_user, :output

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
