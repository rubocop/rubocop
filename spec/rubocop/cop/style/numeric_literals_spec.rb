# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::NumericLiterals, :config do
  subject(:cop) { described_class.new(config) }
  let(:cop_config) { { 'MinDigits' => 5 } }

  it 'registers an offense for a long undelimited integer' do
    inspect_source(cop, 'a = 12345')
    expect(cop.offenses.size).to eq(1)
    expect(cop.config_to_allow_offenses).to eq('MinDigits' => 6)
  end

  it 'registers an offense for a float with a long undelimited integer part' do
    inspect_source(cop, 'a = 123456.789')
    expect(cop.offenses.size).to eq(1)
    expect(cop.config_to_allow_offenses).to eq('MinDigits' => 7)
  end

  it 'registers an offense for an integer with misplaced underscore' do
    inspect_source(cop, 'a = 123_456_78_90_00')
    expect(cop.offenses.size).to eq(1)
    expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
  end

  it 'accepts long numbers with underscore' do
    inspect_source(cop, ['a = 123_456',
                         'b = 123_456.55'])
    expect(cop.messages).to be_empty
  end

  it 'accepts a short integer without underscore' do
    inspect_source(cop, 'a = 123')
    expect(cop.messages).to be_empty
  end

  it 'does not count a leading minus sign as a digit' do
    inspect_source(cop, 'a = -1230')
    expect(cop.messages).to be_empty
  end

  it 'accepts short numbers without underscore' do
    inspect_source(cop, ['a = 123',
                         'b = 123.456'])
    expect(cop.messages).to be_empty
  end

  it 'ignores non-decimal literals' do
    inspect_source(cop, ['a = 0b1010101010101',
                         'b = 01717171717171',
                         'c = 0xab11111111bb'])
    expect(cop.offenses).to be_empty
  end

  it 'autocorrects a long integer offense' do
    corrected = autocorrect_source(cop, ['a = 123456'])
    expect(corrected).to eq 'a = 123_456'
  end

  it 'autocorrects an integer with misplaced underscore' do
    corrected = autocorrect_source(cop, ['a = 123_456_78_90_00'])
    expect(corrected).to eq 'a = 123_456_789_000'
  end

  it 'autocorrects negative numbers' do
    corrected = autocorrect_source(cop, ['a = -123456'])
    expect(corrected).to eq 'a = -123_456'
  end

  it 'autocorrects floating-point numbers' do
    corrected = autocorrect_source(cop, ['a = 123456.78'])
    expect(corrected).to eq 'a = 123_456.78'
  end

  it 'autocorrects negative floating-point numbers' do
    corrected = autocorrect_source(cop, ['a = -123456.78'])
    expect(corrected).to eq 'a = -123_456.78'
  end
end
