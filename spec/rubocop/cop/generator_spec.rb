# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Generator do
  subject(:generator) { described_class.new(cop_identifier, output: stdout) }

  let(:stdout) { StringIO.new }
  let(:cop_identifier) { 'Style/FakeCop' }

  before do
    allow(File).to receive(:write)
    stub_const('HOME_DIR', Dir.pwd)
  end

  describe '#write_source' do
    include_context 'cli spec behavior'

    it 'generates a helpful source file with the name filled in' do
      generated_source = <<~RUBY
        # frozen_string_literal: true

        module RuboCop
          module Cop
            module Style
              # TODO: Write cop description and example of bad / good code. For every
              # `SupportedStyle` and unique configuration, there needs to be examples.
              # Examples must have valid Ruby syntax. Do not use upticks.
              #
              # @safety
              #   Delete this section if the cop is not unsafe (`Safe: false` or
              #   `SafeAutoCorrect: false`), or use it to explain how the cop is
              #   unsafe.
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
              class FakeCop < Base
                # TODO: Implement the cop in here.
                #
                # In many cases, you can use a node matcher for matching node pattern.
                # See https://github.com/rubocop/rubocop-ast/blob/master/lib/rubocop/ast/node_pattern.rb
                #
                # For example
                MSG = 'Use `#good_method` instead of `#bad_method`.'

                # TODO: Don't call `on_send` unless the method name is in this list
                # If you don't need `on_send` in the cop you created, remove it.
                RESTRICT_ON_SEND = %i[bad_method].freeze

                # @!method bad_method?(node)
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

      expect(File).to receive(:write).with('lib/rubocop/cop/style/fake_cop.rb', generated_source)

      generator.write_source

      expect(stdout.string).to eq("[create] lib/rubocop/cop/style/fake_cop.rb\n")
    end

    it 'refuses to overwrite existing files' do
      new_cop = described_class.new('Layout/IndentationStyle')

      allow(new_cop).to receive(:exit!)
      expect { new_cop.write_source }
        .to output(
          'rake new_cop: lib/rubocop/cop/layout/indentation_style.rb ' \
          "already exists!\n"
        ).to_stderr
    end
  end

  describe '#write_spec' do
    include_context 'cli spec behavior'

    it 'generates a helpful starting spec file with the class filled in' do
      generated_source = <<~SPEC
        # frozen_string_literal: true

        RSpec.describe RuboCop::Cop::Style::FakeCop, :config do
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

      expect(File)
        .to receive(:write)
        .with('spec/rubocop/cop/style/fake_cop_spec.rb', generated_source)

      generator.write_spec
    end

    it 'refuses to overwrite existing files' do
      new_cop = described_class.new('Layout/IndentationStyle')

      allow(new_cop).to receive(:exit!)
      expect { new_cop.write_spec }
        .to output(
          'rake new_cop: spec/rubocop/cop/layout/indentation_style_spec.rb ' \
          "already exists!\n"
        ).to_stderr
    end
  end

  describe '#todo' do
    it 'provides a checklist for implementing the cop' do
      expect(generator.todo).to eql(<<~TODO)
        Do 4 steps:
          1. Modify the description of Style/FakeCop in config/default.yml
          2. Implement your new cop in the generated file!
          3. Commit your new cop with a message such as
             e.g. "Add new `Style/FakeCop` cop"
          4. Run `bundle exec rake changelog:new` to generate a changelog entry
             for your new cop.
      TODO
    end
  end

  describe '.new' do
    it 'does not accept an unqualified cop' do
      expect { described_class.new('FakeCop') }
        .to raise_error(ArgumentError)
        .with_message('Specify a cop name with Department/Name style')
    end
  end

  describe '#inject_config' do
    let(:path) { @path } # rubocop:disable RSpec/InstanceVariable

    around do |example|
      Tempfile.create('rubocop-config.yml') do |file|
        @path = file.path
        example.run
      end
    end

    before do
      # It is hacked to use `IO.write` to avoid mocking `File.write` for testing.
      IO.write(path, <<~YAML) # rubocop:disable Security/IoMethods
        Style/Alias:
          Enabled: true

        Style/Lambda:
          Enabled: true

        Style/SpecialGlobalVars:
          Enabled: true
      YAML
    end

    context 'when it is the middle in alphabetical order' do
      it 'inserts the cop' do
        expect(File).to receive(:write).with(path, <<~YAML)
          Style/Alias:
            Enabled: true

          Style/FakeCop:
            Description: 'TODO: Write a description of the cop.'
            Enabled: pending
            VersionAdded: '<<next>>'

          Style/Lambda:
            Enabled: true

          Style/SpecialGlobalVars:
            Enabled: true
        YAML

        generator.inject_config(config_file_path: path)

        expect(stdout.string)
          .to eq('[modify] A configuration for the cop is added into ' \
                 "#{path}.\n")
      end
    end

    context 'when it is the first in alphabetical order' do
      let(:cop_identifier) { 'Style/Aaa' }

      it 'inserts the cop' do
        expect(File).to receive(:write).with(path, <<~YAML)
          Style/Aaa:
            Description: 'TODO: Write a description of the cop.'
            Enabled: pending
            VersionAdded: '<<next>>'

          Style/Alias:
            Enabled: true

          Style/Lambda:
            Enabled: true

          Style/SpecialGlobalVars:
            Enabled: true
        YAML

        generator.inject_config(config_file_path: path)

        expect(stdout.string)
          .to eq('[modify] A configuration for the cop is added into ' \
                 "#{path}.\n")
      end
    end

    context 'when it is the last in alphabetical order' do
      let(:cop_identifier) { 'Style/Zzz' }

      it 'inserts the cop' do
        expect(File).to receive(:write).with(path, <<~YAML)
          Style/Alias:
            Enabled: true

          Style/Lambda:
            Enabled: true

          Style/SpecialGlobalVars:
            Enabled: true

          Style/Zzz:
            Description: 'TODO: Write a description of the cop.'
            Enabled: pending
            VersionAdded: '<<next>>'
        YAML

        generator.inject_config(config_file_path: path)

        expect(stdout.string)
          .to eq('[modify] A configuration for the cop is added into ' \
                 "#{path}.\n")
      end
    end

    context 'with version provided' do
      it 'uses the provided version' do
        expect(File).to receive(:write).with(path, <<~YAML)
          Style/Alias:
            Enabled: true

          Style/FakeCop:
            Description: 'TODO: Write a description of the cop.'
            Enabled: pending
            VersionAdded: '<<next>>'

          Style/Lambda:
            Enabled: true

          Style/SpecialGlobalVars:
            Enabled: true
        YAML

        generator.inject_config(config_file_path: path)
      end
    end
  end

  describe '#snake_case' do
    it 'converts "Lint" to snake_case' do
      expect(generator.__send__(:snake_case, 'Lint')).to eq('lint')
    end

    it 'converts "FooBar" to snake_case' do
      expect(generator.__send__(:snake_case, 'FooBar')).to eq('foo_bar')
    end

    it 'converts "FooBar/Baz" to snake_case' do
      expect(generator.__send__(:snake_case, 'FooBar/Baz')).to eq('foo_bar/baz')
    end

    it 'converts "RSpec" to snake_case' do
      expect(generator.__send__(:snake_case, 'RSpec')).to eq('rspec')
    end

    it 'converts "RSpec/Foo" to snake_case' do
      expect(generator.__send__(:snake_case, 'RSpec/Foo')).to eq('rspec/foo')
    end

    it 'converts "RSpecFoo/Bar" to snake_case' do
      expect(generator.__send__(:snake_case, 'RSpecFoo/Bar')).to eq('rspec_foo/bar')
    end
  end

  context 'nested departments' do
    let(:cop_identifier) { 'Plugin/Style/FakeCop' }

    include_context 'cli spec behavior'

    it 'generates source and spec files correctly namespaced within departments' do
      expect(File).to receive(:write).with('lib/rubocop/cop/plugin/style/fake_cop.rb',
                                           an_instance_of(String))
      generator.write_source
      expect(stdout.string).to eq("[create] lib/rubocop/cop/plugin/style/fake_cop.rb\n")

      expect(File).to receive(:write).with('spec/rubocop/cop/plugin/style/fake_cop_spec.rb',
                                           an_instance_of(String))
      generator.write_spec
      expect(stdout.string.include?("[create] spec/rubocop/cop/plugin/style/fake_cop_spec.rb\n"))
        .to be(true)
    end
  end

  describe 'compliance with rubocop', :isolated_environment do
    include FileHelper

    around do |example|
      new_global = RuboCop::Cop::Registry.new([RuboCop::Cop::InternalAffairs::NodeDestructuring])
      RuboCop::Cop::Registry.with_temporary_global(new_global) { example.run }
    end

    let(:config) do
      config = RuboCop::ConfigStore.new
      path = File.join(RuboCop::ConfigLoader::RUBOCOP_HOME, RuboCop::ConfigFinder::DOTFILE)
      config.options_config = path
      config
    end
    let(:options) { { formatters: [] } }
    let(:runner) { RuboCop::Runner.new(options, config) }

    before do
      # Ignore any config validation errors
      allow_any_instance_of(RuboCop::ConfigValidator).to receive(:validate) # rubocop:disable RSpec/AnyInstance
    end

    it 'generates a cop file that has no offense' do
      generator.write_source
      expect(runner.run([])).to be true
    end

    it 'generates a spec file that has no offense' do
      generator.write_spec
      expect(runner.run([])).to be true
    end
  end
end
