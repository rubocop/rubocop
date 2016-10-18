# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Lint::ConditionPosition do
  subject(:cop) { described_class.new }

  %w[if unless while until].each do |keyword|
    it 'registers an offense for condition on the next line' do
      inspect_source(cop,
                     [keyword,
                      'x == 10',
                      'end'])
      expect(cop.offenses.size).to eq(1)
    end

    it 'accepts condition on the same line' do
      inspect_source(cop,
                     ["#{keyword} x == 10",
                      ' bala',
                      'end'])
      expect(cop.offenses).to be_empty
    end

    it 'accepts condition on a different line for modifiers' do
      inspect_source(cop,
                     ["do_something #{keyword}",
                      '  something && something_else'])
      expect(cop.offenses).to be_empty
    end
  end

  it 'registers an offense for elsif condition on the next line' do
    inspect_source(cop,
                   ['if something',
                    '  test',
                    'elsif',
                    '  something',
                    '  test',
                    'end'])
    expect(cop.offenses.size).to eq(1)
  end

  it 'handles ternary ops' do
    inspect_source(cop, 'x ? a : b')
    expect(cop.offenses).to be_empty
  end
end
