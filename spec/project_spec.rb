# encoding: utf-8

require 'spec_helper'

describe 'RuboCop Project' do
  describe 'default configuration file' do
    it 'has configuration for all cops' do
      cop_names = Rubocop::Cop::Cop.all.map(&:cop_name)
      expect(Rubocop::ConfigLoader.load_file('config/default.yml').keys.sort)
        .to eq((['AllCops'] + cop_names).sort)
    end
    it 'has a description for all cops' do
      cop_names = Rubocop::Cop::Cop.all.map(&:cop_name)
      conf = Rubocop::ConfigLoader.load_file('config/default.yml')
      cop_names.each do |name|
        expect(conf[name]['Description']).not_to be_nil
      end
    end
  end
end
