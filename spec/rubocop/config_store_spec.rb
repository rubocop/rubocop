# encoding: utf-8

require 'spec_helper'

describe RuboCop::ConfigStore do
  subject(:config_store) { described_class.new }

  before do
    allow(RuboCop::ConfigLoader).to receive(:configuration_file_for) do |arg|
      # File tree:
      # file1
      # dir/.rubocop.yml
      # dir/file2
      # dir/subdir/file3
      (arg =~ /dir/ ? 'dir' : '.') + '/.rubocop.yml'
    end
    allow(RuboCop::ConfigLoader)
      .to receive(:configuration_from_file) { |arg| arg }
    allow(RuboCop::ConfigLoader)
      .to receive(:load_file) { |arg| RuboCop::Config.new(arg) }
    allow(RuboCop::ConfigLoader)
      .to receive(:merge_with_default) { |config| "merged #{config}" }
  end

  describe '.for' do
    it 'always uses config specified in command line' do
      config_store.options_config = { options_config: true }
      expect(config_store.for('file1')).to eq('merged {:options_config=>true}')
    end

    context 'when no config specified in command line' do
      it 'gets config path and config from cache if available' do
        expect(RuboCop::ConfigLoader)
          .to receive(:configuration_file_for).once.with('dir')
        expect(RuboCop::ConfigLoader)
          .to receive(:configuration_file_for).once.with('dir/subdir')
        # The stub returns the same config path for dir and dir/subdir.
        expect(RuboCop::ConfigLoader)
          .to receive(:configuration_from_file).once.with('dir/.rubocop.yml')

        config_store.for('dir/file2')
        config_store.for('dir/file2')
        config_store.for('dir/subdir/file3')
      end

      it 'searches for config path if not available in cache' do
        expect(RuboCop::ConfigLoader).to receive(:configuration_file_for).once
        expect(RuboCop::ConfigLoader).to receive(:configuration_from_file).once
        config_store.for('file1')
      end
    end
  end
end
