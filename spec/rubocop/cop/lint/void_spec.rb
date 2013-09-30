# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Lint::Void do
  subject(:cop) { described_class.new }

  described_class::OPS.each do |op|
    it "registers an offence for void op #{op} if not on last line" do
      inspect_source(cop,
                     ["a #{op} b",
                      "a #{op} b",
                      "a #{op} b"
                     ])
      expect(cop.offences.size).to eq(2)
    end
  end

  described_class::OPS.each do |op|
    it "accepts void op #{op} if on last line" do
      inspect_source(cop,
                     ['something',
                      "a #{op} b"
                     ])
      expect(cop.offences).to be_empty
    end
  end

  described_class::OPS.each do |op|
    it "accepts void op #{op} by itself without a begin block" do
      inspect_source(cop, ["a #{op} b"])
      expect(cop.offences).to be_empty
    end
  end

  %w(var @var @@var VAR).each do |var|
    it "registers an offence for void var #{var} if not on last line" do
      inspect_source(cop,
                     ["#{var} = 5",
                      "#{var}",
                      'top'
                     ])
      expect(cop.offences.size).to eq(1)
    end
  end

  %w(1 2.0 /test/ [1] {}).each do |lit|
    it "registers an offence for void lit #{lit} if not on last line" do
      inspect_source(cop,
                     ["#{lit}",
                      'top'
                     ])
      expect(cop.offences.size).to eq(1)
    end
  end

end
