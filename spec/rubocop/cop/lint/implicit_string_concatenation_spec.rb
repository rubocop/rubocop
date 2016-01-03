# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Lint::ImplicitStringConcatenation do
  subject(:cop) { described_class.new }

  before do
    inspect_source(cop, source)
  end

  context 'on a single string literal' do
    let(:source) { 'abc' }

    it 'does not register an offense' do
      expect(cop.offenses).to be_empty
    end
  end

  context 'on adjacent string literals on the same line' do
    let(:source) { 'class A; "abc" "def"; end' }

    it 'registers an offense' do
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages).to eq(['Combine "abc" and "def" into a single ' \
                                  'string literal, rather than using ' \
                                  'implicit string concatenation.'])
      expect(cop.highlights).to eq(['"abc" "def"'])
    end
  end

  context 'on adjacent string literals on different lines' do
    let(:source) { "array = [\n  'abc'\\\n  'def'\n]" }

    it 'does not register an offense' do
      expect(cop.offenses).to be_empty
    end
  end

  context 'when the string literals contain newlines' do
    let(:source) { "def method; 'ab\nc' 'de\nf'; end" }

    it 'registers an offense' do
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages).to eq(['Combine "ab\nc" and "de\nf" into a ' \
                                  'single string literal, rather than using ' \
                                  'implicit string concatenation.'])
      expect(cop.highlights).to eq(["'ab\nc' 'de\nf'"])
    end
  end

  context 'on a string with interpolations' do
    let(:source) { 'array = ["abc#{something}def#{something_else}"]' }

    it 'does register an offense' do
      expect(cop.offenses).to be_empty
    end
  end

  context 'when inside an array' do
    let(:source) { 'array = ["abc" "def"]' }

    it 'notes that the strings could be separated by a comma instead' do
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages).to eq(['Combine "abc" and "def" into a single ' \
                                  'string literal, rather than using ' \
                                  'implicit string concatenation. Or, if they' \
                                  ' were intended to be separate array ' \
                                  'elements, separate them with a comma.'])
      expect(cop.highlights).to eq(['"abc" "def"'])
    end
  end

  context "when in a method call's argument list" do
    let(:source) { 'method("abc" "def")' }

    it 'notes that the strings could be separated by a comma instead' do
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages).to eq(['Combine "abc" and "def" into a single ' \
                                  'string literal, rather than using ' \
                                  'implicit string concatenation. Or, if they' \
                                  ' were intended to be separate method ' \
                                  'arguments, separate them with a comma.'])
      expect(cop.highlights).to eq(['"abc" "def"'])
    end
  end
end
