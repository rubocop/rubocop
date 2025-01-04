# frozen_string_literal: true

RSpec.describe RuboCop::Plugin::Loader do
  describe '.load' do
    subject(:plugins) { described_class.load(plugin_configs) }

    context 'when plugin config is a string' do
      let(:plugin_configs) { ['rubocop/cop/internal_affairs'] }
      let(:plugin) { plugins.first }

      it 'returns an instance of plugin' do
        expect(plugin).to be_an_instance_of(RuboCop::InternalAffairs::Plugin)
      end

      describe 'about' do
        let(:about) { plugin.about }

        it 'has plugin name' do
          expect(plugin.about.name).to eq 'rubocop-internal_affairs'
        end
      end

      describe 'rules' do
        let(:runner_context) { LintRoller::Context.new }
        let(:rules) { plugin.rules(runner_context) }

        it 'has plugin configuration path' do
          expect(rules.value.to_s).to end_with 'config/internal_affairs.yml'
        end
      end
    end
  end
end
