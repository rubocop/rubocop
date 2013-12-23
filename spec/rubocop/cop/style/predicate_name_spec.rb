# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::PredicateName, :config do
  subject(:cop) { described_class.new(config) }
  let(:cop_config) { { 'NamePrefixBlacklist' => %w(has_ is_) } }

  %w(has_ is_).each do |prefix|
    it 'registers an offence for blacklisted method_name' do
      inspect_source(cop, ["def #{prefix}_attr",
                           '  # ...',
                           'end'])
      expect(cop.offences.size).to eq(1)
      expect(cop.highlights).to eq(["#{prefix}_attr"])
    end
  end

  it 'accepts non-blacklisted method name' do
    inspect_source(cop, ['def have_attr',
                         '  # ...',
                         'end'])
    expect(cop.offences).to be_empty
  end
end
