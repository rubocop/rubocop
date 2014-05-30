# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::Style::PredicateName, :config do
  subject(:cop) { described_class.new(config) }
  let(:cop_config) { { 'NamePrefixBlacklist' => %w(has_ is_) } }

  %w(has is).each do |prefix|
    it 'registers an offense for blacklisted method_name' do
      inspect_source(cop, ["def #{prefix}_attr",
                           '  # ...',
                           'end'])
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages).to eq(["Rename `#{prefix}_attr` to `attr?`."])
      expect(cop.highlights).to eq(["#{prefix}_attr"])
    end
  end

  it 'accepts non-blacklisted method name' do
    inspect_source(cop, ['def have_attr',
                         '  # ...',
                         'end'])
    expect(cop.offenses).to be_empty
  end
end
