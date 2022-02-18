# frozen_string_literal: true

RSpec.describe RuboCop::Version do
  include FileHelper

  describe '.extension_versions', :isolated_environment, :restore_registry do
    subject(:extension_versions) { described_class.extension_versions(env) }

    let(:env) { instance_double(RuboCop::CLI::Environment, config_store: config_store) }
    let(:config_store) { RuboCop::ConfigStore.new }

    before { RuboCop::ConfigLoader.clear_options }

    context 'when no extensions are required' do
      before do
        create_file('.rubocop.yml', <<~YAML)
          AllCops:
            TargetRubyVersion: 2.6
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
  end
end
