# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::NumericLiteralPrefix do
  subject(:cop) { described_class.new }

  context 'octal literals' do
    it 'registers an offense for prefixes `0` and `0O`' do
      inspect_source(cop, ['a = 01234',
                           'b(0O123)'])
      expect(cop.offenses.size).to eq(2)
    end

    it 'does not register offense for lowercase prefix' do
      inspect_source(cop, ['a = 0o101',
                           'b = 0o567'])
      expect(cop.messages).to be_empty
    end

    it 'autocorrects a octal literal starting with 0' do
      corrected = autocorrect_source(cop, ['a = 01234'])
      expect(corrected).to eq 'a = 0o1234'
    end

    it 'autocorrects a octal literal starting with 0O' do
      corrected = autocorrect_source(cop, ['b(0O1234, a)'])
      expect(corrected).to eq 'b(0o1234, a)'
    end
  end

  context 'hex literals' do
    it 'registers an offense for uppercase prefix' do
      inspect_source(cop, ['a = 0X1AC',
                           'b(0XABC)'])
      expect(cop.offenses.size).to eq(2)
    end

    it 'does not register offense for lowercase prefix' do
      inspect_source(cop, 'a = 0x101')
      expect(cop.messages).to be_empty
    end

    it 'autocorrects literals with uppercase prefix' do
      corrected = autocorrect_source(cop, ['a = 0XAB'])
      expect(corrected).to eq 'a = 0xAB'
    end
  end

  context 'binary literals' do
    it 'registers an offense for uppercase prefix' do
      inspect_source(cop, ['a = 0B10101',
                           'b(0B111)'])
      expect(cop.offenses.size).to eq(2)
    end

    it 'does not register offense for lowercase prefix' do
      inspect_source(cop, 'a = 0b101')
      expect(cop.messages).to be_empty
    end

    it 'autocorrects literals with uppercase prefix' do
      corrected = autocorrect_source(cop, ['a = 0B1010'])
      expect(corrected).to eq 'a = 0b1010'
    end
  end

  context 'decimal literals' do
    it 'registers an offense for prefixes' do
      inspect_source(cop, ['a = 0d1234',
                           'b(0D123)'])
      expect(cop.offenses.size).to eq(2)
    end

    it 'does not register offense for no prefix' do
      inspect_source(cop, 'a = 101')
      expect(cop.messages).to be_empty
    end

    it 'autocorrects literals with prefix' do
      corrected = autocorrect_source(cop, ['a = 0d1234', 'b(0D1990)'])
      expect(corrected).to eq "a = 1234\nb(1990)"
    end

    it 'does not autocorrect literals with no prefix' do
      corrected = autocorrect_source(cop, ['a = 1234', 'b(1990)'])
      expect(corrected).to eq "a = 1234\nb(1990)"
    end
  end
end
