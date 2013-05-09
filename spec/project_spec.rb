# encoding: utf-8

require 'spec_helper'

describe 'RuboCop Project' do
  describe '.rubocop.yml' do
    it 'has configuration for all cops' do
      cop_names = Rubocop::Cop::Cop.all.map(&:cop_name)
      expect(Rubocop::Config.load_file('.rubocop.yml').keys.sort)
        .to eq((['AllCops'] + cop_names).sort)
    end
  end

  describe 'source codes' do
    before { $stdout = StringIO.new }
    after  { $stdout = STDOUT }

    it 'has no violations' do
      # Need to pass an empty array explicitly
      # so that the CLI does not refer arguments of `rspec`
      Rubocop::CLI.new.run([])
      expect($stdout.string).to match(
        /files inspected, no offences detected\n/
      )
    end
  end
end
