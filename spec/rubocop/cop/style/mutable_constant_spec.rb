# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::Style::MutableConstant do
  subject(:cop) { described_class.new }

  MUTABLE_OBJECTS = [
    '[1, 2, 3]',
    '{ a: 1, b: 2 }',
    "'str'",
    '"top#{1 + 2}"'
  ]

  MUTABLE_OBJECTS.each do |o|
    it "registers an offense for #{o} assigned to a constant" do
      inspect_source(cop, "CONST = #{o}")
      expect(cop.offenses.size).to eq(1)
    end

    it 'auto-corrects by adding .freeze' do
      new_source = autocorrect_source(cop, "CONST = #{o}")
      expect(new_source).to eq("CONST = #{o}.freeze")
    end
  end

  IMMUTABLE_OBJECTS = [
    '1',
    '1.5',
    ':sym'
  ]

  IMMUTABLE_OBJECTS.each do |o|
    it "allows #{o} to be assigned to a constant" do
      inspect_source(cop, "CONST = #{o}")
      expect(cop.offenses).to be_empty
    end
  end

  it 'allows method call assignments' do
    inspect_source(cop, 'TOP_TEST = Something.new')
    expect(cop.offenses).to be_empty
  end
end
