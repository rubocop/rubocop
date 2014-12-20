# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::Lint::LiteralInInterpolation do
  subject(:cop) { described_class.new }

  %w(1 2.0 [1] {}).each do |lit|
    it "registers an offense for #{lit} in interpolation" do
      inspect_source(cop,
                     "\"this is the \#{#{lit}}\"")
      expect(cop.offenses.size).to eq(1)
    end

    it "registers an offense only for final #{lit} in interpolation" do
      inspect_source(cop,
                     "\"this is the \#{#{lit};#{lit}}\"")
      expect(cop.offenses.size).to eq(1)
    end
  end

  it 'accepts empty interpolation' do
    inspect_source(cop, '"this is #{} silly"')
    expect(cop.offenses).to be_empty
  end

  it 'accepts strings like __FILE__' do
    inspect_source(cop, '"this is #{__FILE__} silly"')
    expect(cop.offenses).to be_empty
  end
end
