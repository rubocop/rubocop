# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Lint::UselessComparison do
  subject(:cop) { described_class.new }

  described_class::OPS.each do |op|
    it "registers an offence for a simple comparison with #{op}" do
      inspect_source(cop,
                     ["5 #{op} 5",
                      "a #{op} a"
                     ])
      expect(cop.offences.size).to eq(2)
    end

    it "registers an offence for a complex comparison with #{op}" do
      inspect_source(cop,
                     ["5 + 10 * 30 #{op} 5 + 10 * 30",
                      "a.top(x) #{op} a.top(x)"
                     ])
      expect(cop.offences.size).to eq(2)
    end
  end

  it 'works with lambda.()' do
    inspect_source(cop, ['a.(x) > a.(x)'])
    expect(cop.offences.size).to eq(1)
  end
end
