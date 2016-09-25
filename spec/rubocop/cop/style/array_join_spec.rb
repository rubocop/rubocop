# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::ArrayJoin do
  subject(:cop) { described_class.new }

  it 'registers an offense for an array followed by string' do
    inspect_source(cop,
                   '%w(one two three) * ", "')
    expect(cop.offenses.size).to eq(1)
  end

  it "autocorrects '*' to 'join' when there are spaces" do
    corrected =
      autocorrect_source(cop,
                         '%w(one two three) * ", "')
    expect(corrected).to eq '%w(one two three).join(", ")'
  end

  it "autocorrects '*' to 'join' when there are no spaces" do
    corrected =
      autocorrect_source(cop,
                         '%w(one two three)*", "')
    expect(corrected).to eq '%w(one two three).join(", ")'
  end

  it "autocorrects '*' to 'join' when setting to a variable" do
    corrected =
      autocorrect_source(cop,
                         'foo = %w(one two three)*", "')
    expect(corrected).to eq 'foo = %w(one two three).join(", ")'
  end

  it 'does not register an offense for numbers' do
    inspect_source(cop,
                   '%w(one two three) * 4')
    expect(cop.offenses).to be_empty
  end

  it 'does not register an offense for ambiguous cases' do
    inspect_source(cop,
                   'test * ", "')
    expect(cop.offenses).to be_empty

    inspect_source(cop,
                   '%w(one two three) * test')
    expect(cop.offenses).to be_empty
  end
end
