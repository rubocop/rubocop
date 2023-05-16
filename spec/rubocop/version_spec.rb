# frozen_string_literal: true

RSpec.describe RuboCop::Version do
  include FileHelper

  describe '.version' do
    subject { described_class.version(debug: debug) }

    context 'debug is false (default)' do
      let(:debug) { false }

      it { is_expected.to match(/\d+\.\d+\.\d+/) }
      it { is_expected.not_to match(/\d+\.\d+\.\d+ \(using Parser/) }
    end

    context 'debug is true' do
      let(:debug) { true }

      it { is_expected.to match(/\d+\.\d+\.\d+ \(using Parser/) }
    end
  end

  describe '.extension_versions', :isolated_environment, :restore_registry do
    subject(:extension_versions) { described_class.extension_versions(env) }

    let(:env) { instance_double(RuboCop::CLI::Environment, config_store: config_store) }
    let(:config_store) { RuboCop::ConfigStore.new }

    before { RuboCop::ConfigLoader.clear_options }

    context 'when no extensions are required' do
      before do
        create_file('.rubocop.yml', <<~YAML)
          AllCops:
            TargetRubyVersion: 2.7
        YAML
      end

      it 'does not return any the extensions' do
        expect(extension_versions).to eq([])
      end
    end

    context 'when extensions are required' do
      before do
        create_file('.rubocop.yml', <<~YAML)
          require:
            - rubocop-performance
            - rubocop-rspec
        YAML
      end

      it 'returns the extensions' do
        expect(extension_versions).to contain_exactly(
          /- rubocop-performance \d+\.\d+\.\d+/,
          /- rubocop-rspec \d+\.\d+\.\d+/
        )
      end
    end

    context 'when unknown extensions are required' do
      before do
        create_file('.rubocop.yml', <<~YAML)
          require:
            - ./rubocop-foobarbaz
        YAML

        create_file('rubocop-foobarbaz.rb', <<~RUBY)
          module RuboCop
            module FooBarBaz
            end
          end
        RUBY
      end

      it 'does not return any the extensions' do
        expect(extension_versions).to eq([])
      end
    end

    context 'with an obsolete config' do
      before do
        create_file('.rubocop.yml', <<~YAML)
          require:
            - rubocop-performance
            - rubocop-rspec

          Style/MethodMissing:
            Enabled: true
        YAML
      end

      it 'returns the extensions' do
        expect do
          expect(extension_versions).to contain_exactly(
            /- rubocop-performance \d+\.\d+\.\d+/,
            /- rubocop-rspec \d+\.\d+\.\d+/
          )
        end.not_to raise_error
      end
    end

    context 'with an invalid cop in config' do
      before do
        create_file('.rubocop.yml', <<~YAML)
          require:
            - rubocop-performance
            - rubocop-rspec

          Style/SomeCop:
            Enabled: true
        YAML
      end

      it 'returns the extensions' do
        expect do
          expect(extension_versions).to contain_exactly(
            /- rubocop-performance \d+\.\d+\.\d+/,
            /- rubocop-rspec \d+\.\d+\.\d+/
          )
        end.not_to raise_error
      end
    end

    context 'with all known mappings' do
      let(:config) { instance_double(RuboCop::Config) }

      let(:known_features) do
        %w[
          rubocop-performance
          rubocop-rspec
          rubocop-graphql
          rubocop-md
          rubocop-thread_safety
          rubocop-capybara
          rubocop-factory_bot
        ]
      end

      before do
        allow(config).to receive(:loaded_features).and_return(known_features)
        allow(config_store).to receive(:for_dir).and_return(config)

        stub_const('RuboCop::GraphQL::Version::STRING', '1.0.0')
        stub_const('RuboCop::Markdown::Version::STRING', '1.0.0')
        stub_const('RuboCop::ThreadSafety::Version::STRING', '1.0.0')
      end

      it 'returns the extensions' do
        expect(extension_versions).to contain_exactly(
          /- rubocop-performance \d+\.\d+\.\d+/,
          /- rubocop-rspec \d+\.\d+\.\d+/,
          /- rubocop-graphql \d+\.\d+\.\d+/,
          /- rubocop-md \d+\.\d+\.\d+/,
          /- rubocop-thread_safety \d+\.\d+\.\d+/,
          /- rubocop-capybara \d+\.\d+\.\d+/,
          /- rubocop-factory_bot \d+\.\d+\.\d+/
        )
      end
    end
  end
end
