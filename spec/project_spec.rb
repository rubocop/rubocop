# encoding: utf-8

require 'spec_helper'

describe 'RuboCop Project' do
  describe 'default configuration file' do
    let(:cop_names) { Rubocop::Cop::Cop.all.map(&:cop_name) }

    subject(:default_config) do
      Rubocop::ConfigLoader.load_file('config/default.yml')
    end

    it 'has configuration for all cops' do
      expect(default_config.keys.sort).to eq((['AllCops'] + cop_names).sort)
    end

    it 'has a nicely formatted description for all cops' do
      cop_names.each do |name|
        description = default_config[name]['Description']
        expect(description).not_to be_nil
        expect(description).not_to include("\n")
      end
    end
  end
end
