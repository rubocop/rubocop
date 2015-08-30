# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::Style::RedundantFreeze do
  subject(:cop) { described_class.new }

  # TODO: Turns out RSpec defines all constants in the same namespace.
  # I guess we should remove all usages of constants from out specs.
  MUTABLE_OBJECTS = [
    '[1, 2, 3]',
    '{ a: 1, b: 2 }',
    "'str'",
    '"top#{1 + 2}"'
  ]

  IMMUTABLE_OBJECTS = [
    '1',
    '1.5',
    ':sym'
  ]

  IMMUTABLE_OBJECTS.each do |o|
    it "registers an offense for frozen #{o}" do
      inspect_source(cop, "CONST = #{o}.freeze")
      expect(cop.offenses.size).to eq(1)
    end

    it 'auto-corrects by removing .freeze' do
      new_source = autocorrect_source(cop, "CONST = #{o}.freeze")
      expect(new_source).to eq("CONST = #{o}")
    end
  end

  MUTABLE_OBJECTS.each do |o|
    it "allows #{o} with freeze" do
      inspect_source(cop, "CONST = #{o}.freeze")
      expect(cop.offenses).to be_empty
    end
  end

  it 'allows .freeze on  method call' do
    inspect_source(cop, 'TOP_TEST = Something.new.freeze')
    expect(cop.offenses).to be_empty
  end
end
