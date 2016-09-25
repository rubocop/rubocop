# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Lint::LiteralInCondition do
  subject(:cop) { described_class.new }

  %w(1 2.0 [1] {} :sym :"#{a}").each do |lit|
    it "registers an offense for literal #{lit} in if" do
      inspect_source(cop,
                     ["if #{lit}",
                      '  top',
                      'end'])
      expect(cop.offenses.size).to eq(1)
    end

    it "registers an offense for literal #{lit} in while" do
      inspect_source(cop,
                     ["while #{lit}",
                      '  top',
                      'end'])
      expect(cop.offenses.size).to eq(1)
    end

    it "registers an offense for literal #{lit} in post-loop while" do
      inspect_source(cop,
                     ['begin',
                      '  top',
                      "end while(#{lit})"])
      expect(cop.offenses.size).to eq(1)
    end

    it "registers an offense for literal #{lit} in until" do
      inspect_source(cop,
                     ["until #{lit}",
                      '  top',
                      'end'])
      expect(cop.offenses.size).to eq(1)
    end

    it "registers an offense for literal #{lit} in post-loop until" do
      inspect_source(cop,
                     ['begin',
                      '  top',
                      "end until #{lit}"])
      expect(cop.offenses.size).to eq(1)
    end

    it "registers an offense for literal #{lit} in case" do
      inspect_source(cop,
                     ["case #{lit}",
                      'when x then top',
                      'end'])
      expect(cop.offenses.size).to eq(1)
    end

    it "registers an offense for literal #{lit} in a when " \
       'of a case without anything after case keyword' do
      inspect_source(cop,
                     ['case',
                      "when #{lit} then top",
                      'end'])
      expect(cop.offenses.size).to eq(1)
    end

    it "accepts literal #{lit} in a when of a case with " \
       'something after case keyword' do
      inspect_source(cop,
                     ['case x',
                      "when #{lit} then top",
                      'end'])
      expect(cop.offenses).to be_empty
    end

    it "registers an offense for literal #{lit} in &&" do
      inspect_source(cop,
                     ["if x && #{lit}",
                      '  top',
                      'end'])
      expect(cop.offenses.size).to eq(1)
    end

    it "registers an offense for literal #{lit} in complex cond" do
      inspect_source(cop,
                     ["if x && !(a && #{lit}) && y && z",
                      '  top',
                      'end'])
      expect(cop.offenses.size).to eq(1)
    end

    it "registers an offense for literal #{lit} in !" do
      inspect_source(cop,
                     ["if !#{lit}",
                      '  top',
                      'end'])
      expect(cop.offenses.size).to eq(1)
    end

    it "registers an offense for literal #{lit} in complex !" do
      inspect_source(cop,
                     ["if !(x && (y && #{lit}))",
                      '  top',
                      'end'])
      expect(cop.offenses.size).to eq(1)
    end

    it "accepts literal #{lit} if it's not an and/or operand" do
      inspect_source(cop,
                     ["if test(#{lit})",
                      '  top',
                      'end'])
      expect(cop.offenses).to be_empty
    end

    it "accepts literal #{lit} in non-toplevel and/or" do
      inspect_source(cop,
                     ["if (a || #{lit}).something",
                      '  top',
                      'end'])
      expect(cop.offenses).to be_empty
    end
  end

  it 'accepts array literal in case, if it has non-literal elements' do
    inspect_source(cop,
                   ['case [1, 2, x]',
                    'when [1, 2, 5] then top',
                    'end'])
    expect(cop.offenses).to be_empty
  end

  it 'accepts array literal in case, if it has non-literal elements' do
    inspect_source(cop,
                   ['case [1, 2, [x, 1]]',
                    'when [1, 2, 5] then top',
                    'end'])
    expect(cop.offenses).to be_empty
  end

  it 'registers an offense for case with a primitive array condition' do
    inspect_source(cop,
                   ['case [1, 2, [3, 4]]',
                    'when [1, 2, 5] then top',
                    'end'])
    expect(cop.offenses.size).to eq(1)
  end

  it 'accepts dstr literal in case' do
    inspect_source(cop,
                   ['case "#{x}"',
                    'when [1, 2, 5] then top',
                    'end'])
    expect(cop.offenses).to be_empty
  end
end
