# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::Attr do
  subject(:cop) { described_class.new }

  it 'registers an offense attr' do
    inspect_source(cop, ['class SomeClass',
                         '  attr :name',
                         'end'])
    expect(cop.offenses.size).to eq(1)
  end

  it 'accepts attr when it does not take arguments' do
    inspect_source(cop, 'func(attr)')
    expect(cop.offenses).to be_empty
  end

  it 'accepts attr when it has a receiver' do
    inspect_source(cop, 'x.attr arg')
    expect(cop.offenses).to be_empty
  end

  context 'auto-corrects' do
    it 'attr to attr_reader' do
      new_source = autocorrect_source(cop, 'attr :name')
      expect(new_source).to eq('attr_reader :name')
    end

    it 'attr, false to attr_reader' do
      new_source = autocorrect_source(cop, 'attr :name, false')
      expect(new_source).to eq('attr_reader :name')
    end

    it 'attr :name, true to attr_accessor :name' do
      new_source = autocorrect_source(cop, 'attr :name, true')
      expect(new_source).to eq('attr_accessor :name')
    end

    it 'attr with multiple names to attr_reader' do
      new_source = autocorrect_source(cop, 'attr :foo, :bar')
      expect(new_source).to eq('attr_reader :foo, :bar')
    end
  end

  context 'offense message' do
    let(:msg_reader) { 'Do not use `attr`. Use `attr_reader` instead.' }
    let(:msg_accessor) { 'Do not use `attr`. Use `attr_accessor` instead.' }

    it 'for attr :name suggests to use attr_reader' do
      inspect_source(cop, 'attr :name')
      expect(cop.offenses.first.message).to eq(msg_reader)
    end

    it 'for attr :name, false suggests to use attr_reader' do
      inspect_source(cop, 'attr :name, false')
      expect(cop.offenses.first.message).to eq(msg_reader)
    end

    it 'for attr :name, true suggests to use attr_accessor' do
      inspect_source(cop, 'attr :name, true')
      expect(cop.offenses.first.message).to eq(msg_accessor)
    end

    it 'for attr with multiple names suggests to use attr_reader' do
      inspect_source(cop, 'attr :foo, :bar')
      expect(cop.offenses.first.message).to eq(msg_reader)
    end
  end
end
