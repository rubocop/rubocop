# frozen_string_literal: true

RSpec.describe RuboCop::Plugin::ConfigurationIntegrator do
  describe '.integrate_plugins_into_rubocop_config' do
    before { described_class.integrate_plugins_into_rubocop_config(rubocop_config, plugins) }

    let(:rubocop_config) { RuboCop::Config.new }

    context 'when using plugin' do
      let(:plugins) { RuboCop::Plugin::Loader.load(['rubocop/cop/internal_affairs']) }

      it 'integrates base cops' do
        expect(rubocop_config.to_h['Style/HashSyntax']['SupportedStyles']).to eq(
          %w[ruby19 hash_rockets no_mixed_keys ruby19_no_mixed_keys]
        )
      end

      it 'integrates plugin cops' do
        expect(rubocop_config.to_h['InternalAffairs/CopDescription']).to eq(
          { 'Include' => ['lib/rubocop/cop/**/*.rb'] }
        )
      end
    end
  end
end
