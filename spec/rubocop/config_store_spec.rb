# encoding: utf-8

require 'spec_helper'

describe Rubocop::ConfigStore do
  subject(:config_store) { described_class.new }

  before do
    Rubocop::ConfigLoader.stub(:configuration_file_for) do |arg|
      # File tree:
      # file1
      # dir/.rubocop.yml
      # dir/file2
      # dir/subdir/file3
      (arg =~ /dir/ ? 'dir' : '.') + '/.rubocop.yml'
    end
    Rubocop::ConfigLoader.stub(:configuration_from_file) { |arg| arg }
    Rubocop::ConfigLoader.stub(:load_file) { |arg| "#{arg} loaded" }
    Rubocop::ConfigLoader.stub(:merge_with_default) do |config, file|
      "merged #{config}"
    end
  end

  describe '.for' do
    it 'always uses config specified in command line' do
      config_store.set_options_config(:options_config)
      expect(config_store.for('file1')).to eq('merged options_config loaded')
    end

    context 'when no config specified in command line' do
      it 'gets config path and config from cache if available' do
        Rubocop::ConfigLoader.should_receive(:configuration_file_for).once
          .with('dir')
        Rubocop::ConfigLoader.should_receive(:configuration_file_for).once
          .with('dir/subdir')
        # The stub returns the same config path for dir and dir/subdir.
        Rubocop::ConfigLoader.should_receive(:configuration_from_file).once
          .with('dir/.rubocop.yml')

        config_store.for('dir/file2')
        config_store.for('dir/file2')
        config_store.for('dir/subdir/file3')
      end

      it 'searches for config path if not available in cache' do
        Rubocop::ConfigLoader.should_receive(:configuration_file_for).once
        Rubocop::ConfigLoader.should_receive(:configuration_from_file).once
        config_store.for('file1')
      end
    end
  end
end
