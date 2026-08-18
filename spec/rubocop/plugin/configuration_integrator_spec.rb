# frozen_string_literal: true

require 'lint_roller'

RSpec.describe RuboCop::Plugin::ConfigurationIntegrator, :isolated_environment do
  include FileHelper

  describe '.integrate_plugins_into_rubocop_config' do
    subject(:integrated_config) do
      described_class.integrate_plugins_into_rubocop_config(rubocop_config, plugins)
    end

    after do
      default_configuration = RuboCop::ConfigLoader.default_configuration
      default_configuration.delete('inherit_mode')

      RuboCop::ConfigLoader.instance_variable_set(:@default_configuration, default_configuration)
    end

    context 'when using internal plugin' do
      let(:rubocop_config) { RuboCop::Config.new }
      let(:plugins) { RuboCop::Plugin::Loader.load(['rubocop/cop/internal_affairs']) }

      it 'integrates base cops' do
        expect(rubocop_config.to_h['Style/HashSyntax']['SupportedStyles']).to eq(
          %w[ruby19 hash_rockets no_mixed_keys ruby19_no_mixed_keys]
        )
      end

      it 'integrates plugin cops' do
        expect(integrated_config.to_h['InternalAffairs/CopDescription']).to eq(
          { 'Include' => ['lib/rubocop/cop/**/*.rb'] }
        )
      end
    end

    context 'when using a plugin with `Plugin` type is `:path`' do
      let(:rubocop_config) do
        RuboCop::Config.new
      end
      let(:fake_plugin) do
        Class.new(LintRoller::Plugin) do
          def rules(_context)
            LintRoller::Rules.new(type: :path, config_format: :rubocop, value: 'default.yml')
          end
        end
      end
      let(:plugins) { [fake_plugin.new] }
      let(:all_cops_exclude) { integrated_config.to_h['AllCops']['Exclude'] }

      before do
        create_file('default.yml', <<~YAML)
          AllCops:
            Exclude:
              - db/*schema.rb
        YAML
      end

      it 'integrates `Exclude` values from plugin cops as absolute paths into the configuration' do
        expect(all_cops_exclude.count).to eq 5
        expect(all_cops_exclude.last).to end_with('/db/*schema.rb')
      end
    end

    context 'when a plugin declares a custom `AllCops` key alongside another plugin' do
      let(:rubocop_config) { RuboCop::Config.new }
      let(:declaring_plugin) do
        Class.new(LintRoller::Plugin) do
          def rules(_context)
            LintRoller::Rules.new(
              type: :path, config_format: :rubocop, value: 'declaring_default.yml'
            )
          end
        end
      end
      let(:other_plugin) do
        Class.new(LintRoller::Plugin) do
          def rules(_context)
            LintRoller::Rules.new(type: :path, config_format: :rubocop, value: 'other_default.yml')
          end
        end
      end

      before do
        create_file('declaring_default.yml', <<~YAML)
          AllCops:
            TargetFrameworkVersion: ~
        YAML
        create_file('other_default.yml', <<~YAML)
          AllCops:
            Exclude:
              - db/*schema.rb
        YAML
      end

      after do
        RuboCop::ConfigLoader.default_configuration = nil
      end

      shared_examples 'keeps the declared key' do
        it 'keeps the key in the default configuration' do
          integrated_config

          default_all_cops = RuboCop::ConfigLoader.default_configuration['AllCops']
          expect(default_all_cops).to have_key('TargetFrameworkVersion')
        end

        it 'recognizes the key when validating a user configuration' do
          integrated_config

          expect do
            RuboCop::Config.create(
              { 'AllCops' => { 'TargetFrameworkVersion' => 7.1 } }, '.rubocop.yml', check: true
            )
          end.not_to output(/AllCops does not support TargetFrameworkVersion parameter/).to_stderr
        end
      end

      context 'when the other plugin is loaded after the declaring plugin' do
        let(:plugins) { [declaring_plugin.new, other_plugin.new] }

        it_behaves_like 'keeps the declared key'
      end

      context 'when the declaring plugin is loaded after the other plugin' do
        let(:plugins) { [other_plugin.new, declaring_plugin.new] }

        it_behaves_like 'keeps the declared key'
      end
    end

    context 'when using a plugin with `Plugin` type is `:object`' do
      let(:rubocop_config) do
        RuboCop::Config.new('Style/FrozenStringLiteralComment' => { 'Exclude' => %w[**/*.arb] })
      end
      let(:fake_plugin) do
        Class.new(LintRoller::Plugin) do
          def rules(_context)
            LintRoller::Rules.new(
              type: :object,
              config_format: :rubocop,
              value: {
                'inherit_mode' => {
                  'merge' => ['Exclude']
                },
                'Style/FrozenStringLiteralComment' => {
                  'Exclude' => %w[**/*.erb]
                }
              }
            )
          end
        end
      end
      let(:plugins) { [fake_plugin.new] }
      let(:exclude) { integrated_config.to_h['Style/FrozenStringLiteralComment']['Exclude'] }

      it 'integrates `Exclude` values from plugin cops into the configuration' do
        expect(exclude.count).to eq 2
        expect(exclude[0]).to end_with('.arb')
        expect(exclude[1]).to end_with('.erb')
      end
    end

    context 'when using a plugin with an unsupported RuboCop engine' do
      let(:rubocop_config) do
        RuboCop::Config.new
      end
      let(:unsupported_plugin) do
        Class.new(LintRoller::Plugin) do
          def supported?(context)
            context.engine == :not_rubocop
          end
        end
      end
      let(:plugins) { [unsupported_plugin.new] }

      it 'raises `RuboCop::Plugin::NotSupportedError`' do
        expect { integrated_config }.to raise_error(RuboCop::Plugin::NotSupportedError)
      end
    end
  end
end
