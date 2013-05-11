# encoding: utf-8

require 'spec_helper'

module Rubocop
  describe ConfigStore do
    before(:each) { ConfigStore.prepare }
    before do
      Config.stub(:configuration_file_for) do |arg|
        # File tree:
        # file1
        # dir/.rubocop.yml
        # dir/file2
        # dir/subdir/file3
        (arg =~ /dir/ ? 'dir' : '.') + '/.rubocop.yml'
      end
      Config.stub(:configuration_from_file) { |arg| arg }
      Config.stub(:load_file) { |arg| "#{arg} loaded" }
      Config.stub(:merge_with_default) { |config, file| "merged #{config}" }
    end

    describe '.prepare' do
      it 'resets @options_config' do
        ConfigStore.set_options_config(:options_config)
        ConfigStore.prepare
        Config.should_receive(:configuration_file_for)
        ConfigStore.for('file1')
      end

      it 'resets @config_cache' do
        ConfigStore.for('file1')
        ConfigStore.prepare
        Config.should_receive(:configuration_file_for)
        ConfigStore.for('file1')
      end
    end

    describe '.for' do
      it 'always uses config specified in command line' do
        ConfigStore.set_options_config(:options_config)
        expect(ConfigStore.for('file1')).to eq('merged options_config loaded')
      end

      context 'when no config specified in command line' do
        it 'gets config path and config from cache if available' do
          Config.should_receive(:configuration_file_for).once.with('dir')
          Config.should_receive(:configuration_file_for).once.with('dir/' +
                                                                   'subdir')
          # The stub returns the same config path for dir and dir/subdir.
          Config.should_receive(:configuration_from_file).once.
            with('dir/.rubocop.yml')

          ConfigStore.for('dir/file2')
          ConfigStore.for('dir/file2')
          ConfigStore.for('dir/subdir/file3')
        end

        it 'searches for config path if not available in cache' do
          Config.should_receive(:configuration_file_for).once
          Config.should_receive(:configuration_from_file).once
          ConfigStore.for('file1')
        end
      end
    end
  end
end
