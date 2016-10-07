# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::PreferredHashMethods, :config do
  subject(:cop) { described_class.new(config) }

  context 'with enforced `short` style' do
    let(:cop_config) { { 'EnforcedStyle' => 'short' } }

    it 'registers an offense for has_key? with one arg' do
      inspect_source(cop,
                     'o.has_key?(o)')
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(['Use `Hash#key?` instead of `Hash#has_key?`.'])
    end

    it 'accepts has_key? with no args' do
      inspect_source(cop,
                     'o.has_key?')
      expect(cop.offenses).to be_empty
    end

    it 'registers an offense for has_value? with one arg' do
      inspect_source(cop,
                     'o.has_value?(o)')
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(['Use `Hash#value?` instead of `Hash#has_value?`.'])
    end

    it 'accepts has_value? with no args' do
      inspect_source(cop,
                     'o.has_value?')
      expect(cop.offenses).to be_empty
    end

    it 'auto-corrects has_key? with key?' do
      new_source = autocorrect_source(cop, 'hash.has_key?(:test)')
      expect(new_source).to eq('hash.key?(:test)')
    end

    it 'auto-corrects has_value? with value?' do
      new_source = autocorrect_source(cop, 'hash.has_value?(value)')
      expect(new_source).to eq('hash.value?(value)')
    end
  end

  context 'with enforced `verbose` style' do
    let(:cop_config) { { 'EnforcedStyle' => 'verbose' } }

    it 'registers an offense for key? with one arg' do
      inspect_source(cop,
                     'o.key?(o)')
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(['Use `Hash#has_key?` instead of `Hash#key?`.'])
    end

    it 'accepts key? with no args' do
      inspect_source(cop,
                     'o.key?')
      expect(cop.offenses).to be_empty
    end

    it 'registers an offense for value? with one arg' do
      inspect_source(cop,
                     'o.value?(o)')
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(['Use `Hash#has_value?` instead of `Hash#value?`.'])
    end

    it 'accepts value? with no args' do
      inspect_source(cop,
                     'o.value?')
      expect(cop.offenses).to be_empty
    end

    it 'auto-corrects key? with has_key?' do
      new_source = autocorrect_source(cop, 'hash.key?(:test)')
      expect(new_source).to eq('hash.has_key?(:test)')
    end

    it 'auto-corrects value? with has_value?' do
      new_source = autocorrect_source(cop, 'hash.value?(value)')
      expect(new_source).to eq('hash.has_value?(value)')
    end
  end
end
