# encoding: utf-8

require 'spec_helper'

describe 'RuboCop Project' do
  describe 'default configuration file' do
    it 'has configuration for all cops' do
      cop_names = Rubocop::Cop::Cop.all.map(&:cop_name)
      expect(Rubocop::Config.load_file('config/default.yml').keys.sort)
        .to eq((['AllCops'] + cop_names).sort)
    end
  end
end
