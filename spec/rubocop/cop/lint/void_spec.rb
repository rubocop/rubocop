# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::Lint::Void do
  subject(:cop) { described_class.new }

  described_class::OPS.each do |op|
    it "registers an offense for void op #{op} if not on last line" do
      inspect_source(cop,
                     ["a #{op} b",
                      "a #{op} b",
                      "a #{op} b"
                     ])
      expect(cop.offenses.size).to eq(2)
    end
  end

  described_class::OPS.each do |op|
    it "accepts void op #{op} if on last line" do
      inspect_source(cop,
                     ['something',
                      "a #{op} b"
                     ])
      expect(cop.offenses).to be_empty
    end
  end

  described_class::OPS.each do |op|
    it "accepts void op #{op} by itself without a begin block" do
      inspect_source(cop, "a #{op} b")
      expect(cop.offenses).to be_empty
    end
  end

  %w(var @var @@var VAR).each do |var|
    it "registers an offense for void var #{var} if not on last line" do
      inspect_source(cop,
                     ["#{var} = 5",
                      "#{var}",
                      'top'
                     ])
      expect(cop.offenses.size).to eq(1)
    end
  end

  %w(1 2.0 /test/ [1] {}).each do |lit|
    it "registers an offense for void lit #{lit} if not on last line" do
      inspect_source(cop,
                     ["#{lit}",
                      'top'
                     ])
      expect(cop.offenses.size).to eq(1)
    end
  end

  it 'accepts short call syntax' do
    inspect_source(cop,
                   ['lambda.(a)',
                    'top'
                   ])
    expect(cop.offenses).to be_empty
  end
end
