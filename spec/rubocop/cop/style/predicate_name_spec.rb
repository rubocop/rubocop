# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::Style::PredicateName, :config do
  subject(:cop) { described_class.new(config) }

  context 'with blacklisted prefices' do
    let(:cop_config) do
      { 'NamePrefix' => %w(has_ is_),
        'NamePrefixBlacklist' => %w(has_ is_) }
    end

    %w(has is).each do |prefix|
      it 'registers an offense when method name starts with known prefix' do
        inspect_source(cop, ["def #{prefix}_attr",
                             '  # ...',
                             'end'])
        expect(cop.offenses.size).to eq(1)
        expect(cop.messages).to eq(["Rename `#{prefix}_attr` to `attr?`."])
        expect(cop.highlights).to eq(["#{prefix}_attr"])
      end
    end

    it 'accepts method name that starts with unknown prefix' do
      inspect_source(cop, ['def have_attr',
                           '  # ...',
                           'end'])
      expect(cop.offenses).to be_empty
    end

    context 'with blacklisted prefices' do
      let(:cop_config) do
        { 'NamePrefix' => %w(has_ is_), 'NamePrefixBlacklist' => [] }
      end

      %w(has is).each do |prefix|
        it 'registers an offense when method name starts with known prefix' do
          inspect_source(cop, ["def #{prefix}_attr",
                               '  # ...',
                               'end'])
          expect(cop.offenses.size).to eq(1)
          expect(cop.messages)
            .to eq(["Rename `#{prefix}_attr` to `#{prefix}_attr?`."])
          expect(cop.highlights).to eq(["#{prefix}_attr"])
        end
      end

      it 'accepts method name that starts with unknown prefix' do
        inspect_source(cop, ['def have_attr',
                             '  # ...',
                             'end'])
        expect(cop.offenses).to be_empty
      end
    end
  end
end
