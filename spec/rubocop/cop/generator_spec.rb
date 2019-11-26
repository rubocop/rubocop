# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Generator do
  subject(:generator) do
    described_class.new(cop_identifier, 'your_id', output: stdout)
  end

  HOME_DIR = Dir.pwd

  let(:stdout) { StringIO.new }
  let(:cop_identifier) { 'Style/FakeCop' }

  before do
    allow(File).to receive(:write)
  end

  describe '#write_source' do
    include_context 'cli spec behavior'

    it 'generates a helpful source file with the name filled in' do
      generated_source = <<~RUBY
        # frozen_string_literal: true

        # TODO: when finished, run `rake generate_cops_documentation` to update the docs
        module RuboCop
          module Cop
            module Style
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
              class FakeCop < Cop
                # TODO: Implement the cop in here.
                #
                # In many cases, you can use a node matcher for matching node pattern.
                # See https://github.com/rubocop-hq/rubocop/blob/master/lib/rubocop/node_pattern.rb
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

      expect(File)
        .to receive(:write)
        .with('lib/rubocop/cop/style/fake_cop.rb', generated_source)

      generator.write_source

      expect(stdout.string)
        .to eq("[create] lib/rubocop/cop/style/fake_cop.rb\n")
    end

    it 'refuses to overwrite existing files' do
      new_cop = described_class.new('Layout/Tab', 'your_id')

      allow(new_cop).to receive(:exit!)
      expect { new_cop.write_source }
        .to output(
          "rake new_cop: lib/rubocop/cop/layout/tab.rb already exists!\n"
        ).to_stderr
    end
  end

  describe '#write_spec' do
    include_context 'cli spec behavior'

    it 'generates a helpful starting spec file with the class filled in' do
      generated_source = <<~SPEC
        # frozen_string_literal: true

        RSpec.describe RuboCop::Cop::Style::FakeCop do
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

      expect(File)
        .to receive(:write)
        .with('spec/rubocop/cop/style/fake_cop_spec.rb', generated_source)

      generator.write_spec
    end

    it 'refuses to overwrite existing files' do
      new_cop = described_class.new('Layout/Tab', 'your_id')

      allow(new_cop).to receive(:exit!)
      expect { new_cop.write_spec }
        .to output(
          "rake new_cop: spec/rubocop/cop/layout/tab_spec.rb already exists!\n"
        ).to_stderr
    end
  end

  describe '#todo' do
    it 'provides a checklist for implementing the cop' do
      expect(generator.todo).to eql(<<~TODO)
        Do 3 steps:
          1. Add an entry to the "New features" section in CHANGELOG.md,
             e.g. "Add new `Style/FakeCop` cop. ([@your_id][])"
          2. Modify the description of Style/FakeCop in config/default.yml
          3. Implement your new cop in the generated file!
      TODO
    end
  end

  describe '.new' do
    it 'does not accept an unqualified cop' do
      expect { described_class.new('FakeCop', 'your_id') }
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
      IO.write(path, <<~YAML)
        Style/Alias:
          Enabled: true

        Style/Lambda:
          Enabled: true

        Style/SpecialGlobalVars:
          Enabled: true
      YAML

      stub_const('RuboCop::Version::STRING', '0.58.2')
    end

    context 'when it is the middle in alphabetical order' do
      it 'inserts the cop' do
        expect(File).to receive(:write).with(path, <<~YAML)
          Style/Alias:
            Enabled: true

          Style/FakeCop:
            Description: 'TODO: Write a description of the cop.'
            Enabled: true
            VersionAdded: '0.59'

          Style/Lambda:
            Enabled: true

          Style/SpecialGlobalVars:
            Enabled: true
        YAML

        generator.inject_config(config_file_path: path)

        expect(stdout.string).to eq(<<~MESSAGE)
          [modify] A configuration for the cop is added into #{path}.
                   If you want to disable the cop by default, set `Enabled` option to false.
        MESSAGE
      end
    end

    context 'when it is the first in alphabetical order' do
      let(:cop_identifier) { 'Style/Aaa' }

      it 'inserts the cop' do
        expect(File).to receive(:write).with(path, <<~YAML)
          Style/Aaa:
            Description: 'TODO: Write a description of the cop.'
            Enabled: true
            VersionAdded: '0.59'

          Style/Alias:
            Enabled: true

          Style/Lambda:
            Enabled: true

          Style/SpecialGlobalVars:
            Enabled: true
        YAML

        generator.inject_config(config_file_path: path)

        expect(stdout.string).to eq(<<~MESSAGE)
          [modify] A configuration for the cop is added into #{path}.
                   If you want to disable the cop by default, set `Enabled` option to false.
        MESSAGE
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
            Enabled: true
            VersionAdded: '0.59'
        YAML

        generator.inject_config(config_file_path: path)

        expect(stdout.string).to eq(<<~MESSAGE)
          [modify] A configuration for the cop is added into #{path}.
                   If you want to disable the cop by default, set `Enabled` option to false.
        MESSAGE
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

    it 'converts "RSpec" to snake_case' do
      expect(generator.__send__(:snake_case, 'RSpec')).to eq('rspec')
    end
  end

  describe 'compliance with rubocop', :isolated_environment do
    include FileHelper

    around do |example|
      orig_registry = RuboCop::Cop::Cop.registry
      RuboCop::Cop::Cop.instance_variable_set(
        :@registry,
        RuboCop::Cop::Registry.new(
          [RuboCop::Cop::InternalAffairs::NodeDestructuring]
        )
      )
      example.run
      RuboCop::Cop::Cop.instance_variable_set(:@registry, orig_registry)
    end

    let(:config) do
      config = RuboCop::ConfigStore.new
      path = File.join(RuboCop::ConfigLoader::RUBOCOP_HOME,
                       RuboCop::ConfigLoader::DOTFILE)
      config.options_config = path
      config
    end
    let(:options) { { formatters: [] } }
    let(:runner) { RuboCop::Runner.new(options, config) }

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
