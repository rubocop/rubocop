# frozen_string_literal: true

RSpec.describe RuboCop::PendingCopsReporter do
  include FileHelper

  describe 'when pending cops exist', :isolated_environment do
    subject(:report_pending_cops) { described_class.warn_if_needed(config) }

    let(:config) { RuboCop::Config.new(parent_config) }

    before do
      create_empty_file('.rubocop.yml')

      # Setup similar to https://github.com/rubocop/rubocop-rspec/blob/master/lib/rubocop/rspec/inject.rb#L16
      # and https://github.com/runtastic/rt_rubocop_defaults/blob/master/lib/rt_rubocop_defaults/inject.rb#L21
      loader = RuboCop::ConfigLoader.configuration_from_file('.rubocop.yml')
      loader.instance_variable_set(:@default_configuration, config)
    end

    context 'when NewCops is set in a required file' do
      let(:parent_config) { { 'AllCops' => { 'NewCops' => 'enable' } } }

      it 'does not print a warning' do
        expect(described_class).not_to receive(:warn_on_pending_cops)
        report_pending_cops
      end
    end

    context 'when NewCops is not configured in a required file' do
      let(:parent_config) { { 'AllCops' => { 'Exclude:' => ['coverage/**/*'] } } }

      context 'when `pending_cops_only_qualified` returns empty array' do
        before do
          allow(described_class).to receive(:pending_cops_only_qualified).and_return([])
        end

        it 'does not print a warning' do
          expect(described_class).not_to receive(:warn_on_pending_cops)
          report_pending_cops
        end
      end

      context 'when `pending_cops_only_qualified` returns not empty array' do
        before do
          allow(described_class).to receive(:pending_cops_only_qualified).and_return(['Foo/Bar'])
        end

        it 'prints a warning' do
          expect(described_class).to receive(:warn_on_pending_cops)
          report_pending_cops
        end
      end
    end
  end
end
