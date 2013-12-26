# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Lint::ConditionPosition do
  subject(:cop) { described_class.new }

  %w(if unless while until).each do |keyword|
    it 'registers an offence for condition on the next line' do
      inspect_source(cop,
                     ["#{keyword}",
                      'x == 10',
                      'end'
                    ])
      expect(cop.offences.size).to eq(1)
    end

    it 'accepts condition on the same line' do
      inspect_source(cop,
                     ["#{keyword} x == 10",
                      ' bala',
                      'end'
                    ])
      expect(cop.offences).to be_empty
    end
  end

  it 'registers an offence for elsif condition on the next line' do
    inspect_source(cop,
                   ['if something',
                    '  test',
                    'elsif',
                    '  something',
                    '  test',
                    'end'
                  ])
    expect(cop.offences.size).to eq(1)
  end

  it 'handles ternary ops' do
    inspect_source(cop, ['x ? a : b'])
    expect(cop.offences).to be_empty
  end

  it 'handles modifier forms' do
    inspect_source(cop, ['x if something'])
    expect(cop.offences).to be_empty
  end
end
