# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Lint::DuplicatedKey do
  subject(:cop) { described_class.new }
  context 'When there is a duplicated key in the hash literal' do
    let(:source) do
      "hash = { 'otherkey' => 'value', 'key' => 'value', 'key' => 'hi' }"
    end

    it 'registers an offense' do
      inspect_source(cop, source)
      expect(cop.offenses.size).to eq(1)
      expect(cop.offenses.first.message)
        .to eq('Duplicated key in hash literal.')
      expect(cop.highlights).to eq ["'key'"]
    end
  end

  context 'When there are two duplicated keys in a hash' do
    let(:source) do
      "hash = { fruit: 'apple', veg: 'kale', veg: 'cuke', fruit: 'orange' }"
    end

    it 'registers two offenses' do
      inspect_source(cop, source)
      expect(cop.offenses.size).to eq(2)
      expect(cop.messages).to eq(['Duplicated key in hash literal.'] * 2)
      expect(cop.highlights).to eq %w(veg fruit)
    end
  end

  context 'When a key is duplicated three times in a hash literal' do
    let(:source) do
      'hash = { 1 => 2, 1 => 3, 1 => 4 }'
    end

    it 'registers two offenses' do
      inspect_source(cop, source)
      expect(cop.offenses.size).to eq(2)
      expect(cop.messages).to eq(['Duplicated key in hash literal.'] * 2)
      expect(cop.highlights).to eq %w(1 1)
    end
  end

  context 'When there is no duplicated key in the hash' do
    let(:source) do
      "hash = { ['one', 'two'] => ['hello, bye'], ['two'] => ['yes, no'] }"
    end

    it 'does not register an offense' do
      inspect_source(cop, source)
      expect(cop.offenses).to be_empty
    end
  end

  context 'when the keys are method calls' do
    let(:source) do
      'hash = { [some_method_call] => 1, [some_method_call] => 4 }'
    end

    it 'does not register an offense, because the result may be different' do
      inspect_source(cop, source)
      expect(cop.offenses).to be_empty
    end
  end

  context 'when the keys are collections of literals' do
    let(:source) do
      'hash = { [1, 2] => 1, [1, 2] => 4 }'
    end

    it 'registers an offense' do
      inspect_source(cop, source)
      expect(cop.offenses.size).to eq(1)
      expect(cop.offenses.first.message)
        .to eq('Duplicated key in hash literal.')
      expect(cop.highlights).to eq ['[1, 2]']
    end
  end
end
