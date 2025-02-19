# frozen_string_literal: true

RSpec.describe RuboCop::Plugin do
  describe '.plugin_capable?' do
    subject { described_class.plugin_capable?(feature) }

    context 'when feature is a built-in plugin' do
      let(:feature) { 'rubocop/cop/internal_affairs' }

      it { is_expected.to be(true) }
    end

    context 'when feature is an unknown extension plugin' do
      let(:feature) { 'unknown_extension' }

      it { is_expected.to be(false) }
    end

    context 'when the plugin is not yet activated' do
      let(:feature) { 'rubocop-rspec' }

      around do |example|
        prev_loaded_spec = Gem.loaded_specs[feature]
        Gem.loaded_specs[feature] = nil
        example.call
        Gem.loaded_specs[feature] = prev_loaded_spec
      end

      it { is_expected.to be(true) }
    end
  end

  describe '.integrate_plugins' do
    before { described_class.integrate_plugins(rubocop_config, plugins) }

    let(:rubocop_config) { RuboCop::Config.new }

    context 'when using plugin' do
      let(:plugins) { ['rubocop/cop/internal_affairs'] }

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
