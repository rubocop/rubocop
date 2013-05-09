# encoding: utf-8

require 'spec_helper'

module Rubocop
  describe ConfigStore do
    before(:each) { ConfigStore.prepare }
    before do
      Config.stub(:configuration_for_path) { nil }
      Config.stub(:configuration_for_path).with('valid') { :config }
      Config.stub(:load_file) { |arg| "#{arg}_loaded" }
      Config.stub(:default_config) { :default_config }
    end

    describe '.prepare' do
      it 'resets @options_config' do
        ConfigStore.set_options_config(:options_config)
        ConfigStore.prepare
        Config.should_receive(:new)
        ConfigStore.for('invalid/file')
      end

      it 'resets @config_cache' do
        ConfigStore.for('valid/file')
        ConfigStore.prepare
        Config.should_receive(:configuration_for_path)
        ConfigStore.for('valid/file')
      end
    end

    describe '.for' do
      it 'always uses config specified in command line' do
        ConfigStore.set_options_config(:options_config)
        expect(ConfigStore.for('valid/file')).to eq('options_config_loaded')
      end

      context 'when no config specified in command line' do
        it 'gets config from cache if available' do
          ConfigStore.for('valid/file')
          Config.should_not_receive(:configuration_for_path)
          ConfigStore.for('valid/file')
        end

        it 'searches for config if not available in cache' do
          Config.should_receive(:configuration_for_path)
          ConfigStore.for('valid/file')
        end
      end
    end
  end
end
