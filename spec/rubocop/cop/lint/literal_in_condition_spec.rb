# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Lint::LiteralInCondition do
  subject(:cop) { described_class.new }

  %w(1 2.0 [1] {}).each do |lit|
    it "registers an offence for literal #{lit} in &&" do
      inspect_source(cop,
                     ["if x && #{lit}",
                      '  top',
                      'end'
                     ])
      expect(cop.offences.size).to eq(1)
    end

    it "registers an offence for literal #{lit} in complex cond" do
      inspect_source(cop,
                     ["if x && !(a && #{lit}) && y && z",
                      '  top',
                      'end'
                     ])
      expect(cop.offences.size).to eq(1)
    end

    it "registers an offence for literal #{lit} in !" do
      inspect_source(cop,
                     ["if !#{lit}",
                      '  top',
                      'end'
                     ])
      expect(cop.offences.size).to eq(1)
    end

    it "registers an offence for literal #{lit} in complex !" do
      inspect_source(cop,
                     ["if !(x && (y && #{lit}))",
                      '  top',
                      'end'
                     ])
      expect(cop.offences.size).to eq(1)
    end

    it "accepts literal #{lit} if it's not an and/or operand" do
      inspect_source(cop,
                     ["if test(#{lit})",
                      '  top',
                      'end'
                     ])
      expect(cop.offences).to be_empty
    end

    it "accepts literal #{lit} in non-toplevel and/or" do
      inspect_source(cop,
                     ["if (a || #{lit}).something",
                      '  top',
                      'end'
                     ])
      expect(cop.offences).to be_empty
    end
  end
end
