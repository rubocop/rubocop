# frozen_string_literal: true

require 'lint_roller'

RSpec.describe RuboCop::Plugin::ConfigurationIntegrator do
  describe '.integrate_plugins_into_rubocop_config' do
    subject(:integrated_config) do
      described_class.integrate_plugins_into_rubocop_config(rubocop_config, plugins)
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

    context 'when using a plugin' do
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

      after do
        default_configuration = RuboCop::ConfigLoader.default_configuration
        default_configuration.delete('inherit_mode')

        RuboCop::ConfigLoader.instance_variable_set(:@default_configuration, default_configuration)
      end

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
