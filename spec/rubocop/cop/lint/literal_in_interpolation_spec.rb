# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Lint::LiteralInInterpolation do
  subject(:cop) { described_class.new }

  %w(1 2.0 [1] {}).each do |lit|
    it "registers an offense for #{lit} in interpolation" do
      inspect_source(cop,
                     ["\"this is the \#{#{lit}}\""])
      expect(cop.offenses.size).to eq(1)
    end

    it "registers an offense only for final #{lit} in interpolation" do
      inspect_source(cop,
                     ["\"this is the \#{#{lit};#{lit}}\""])
      expect(cop.offenses.size).to eq(1)
    end
  end
end
