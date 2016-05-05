# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::ClassAndModuleChildren, :config do
  subject(:cop) { described_class.new(config) }

  context 'nested style' do
    let(:cop_config) { { 'EnforcedStyle' => 'nested' } }

    it 'registers an offense for not nested classes' do
      inspect_source(cop, ['class FooClass::BarClass',
                           'end'])

      expect(cop.offenses.size).to eq 1
      expect(cop.messages).to eq [
        'Use nested module/class definitions instead of compact style.'
      ]
      expect(cop.highlights).to eq ['FooClass::BarClass']
    end

    it 'registers an offense for not nested classes with explicit superclass' do
      inspect_source(cop, ['class FooClass::BarClass < Super',
                           'end'])

      expect(cop.offenses.size).to eq 1
      expect(cop.messages).to eq [
        'Use nested module/class definitions instead of compact style.'
      ]
      expect(cop.highlights).to eq ['FooClass::BarClass']
    end

    it 'registers an offense for not nested modules' do
      inspect_source(cop, ['module FooModule::BarModule',
                           'end'])

      expect(cop.offenses.size).to eq 1
      expect(cop.messages).to eq [
        'Use nested module/class definitions instead of compact style.'
      ]
      expect(cop.highlights).to eq ['FooModule::BarModule']
    end

    it 'accepts nested children' do
      inspect_source(cop,
                     ['class FooClass',
                      '  class BarClass',
                      '  end',
                      'end',
                      '',
                      'module FooModule',
                      '  module BarModule',
                      '  end',
                      'end'])
      expect(cop.offenses).to be_empty
    end

    it 'accepts :: in parent class on inheritance' do
      inspect_source(cop,
                     ['class FooClass',
                      '  class BarClass',
                      '  end',
                      'end',
                      '',
                      'class BazClass < FooClass::BarClass',
                      'end'])
      expect(cop.offenses).to be_empty
    end
  end

  context 'compact style' do
    let(:cop_config) { { 'EnforcedStyle' => 'compact' } }

    it 'registers a offense for classes with nested children' do
      inspect_source(cop,
                     ['class FooClass',
                      '  class BarClass',
                      '  end',
                      'end'])
      expect(cop.offenses.size).to eq 1
      expect(cop.messages).to eq [
        'Use compact module/class definition instead of nested style.'
      ]
      expect(cop.highlights).to eq ['FooClass']
    end

    it 'registers a offense for modules with nested children' do
      inspect_source(cop,
                     ['module FooModule',
                      '  module BarModule',
                      '  end',
                      'end'])
      expect(cop.offenses.size).to eq 1
      expect(cop.messages).to eq [
        'Use compact module/class definition instead of nested style.'
      ]
      expect(cop.highlights).to eq ['FooModule']
    end

    it 'accepts compact style for classes/modules' do
      inspect_source(cop,
                     ['class FooClass::BarClass',
                      'end',
                      '',
                      'module FooClass::BarModule',
                      'end'])
      expect(cop.offenses).to be_empty
    end

    it 'accepts nesting for classes/modules with more than one child' do
      inspect_source(cop,
                     ['class FooClass',
                      '  class BarClass',
                      '  end',
                      '  class BazClass',
                      '  end',
                      'end',
                      '',
                      'module FooModule',
                      '  module BarModule',
                      '  end',
                      '  class BazModule',
                      '  end',
                      'end'])
      expect(cop.offenses).to be_empty
    end

    it 'accepts class/module with single method' do
      inspect_source(cop,
                     ['class FooClass',
                      '  def bar_method',
                      '  end',
                      'end'])
      expect(cop.offenses).to be_empty
    end

    it 'accepts nesting for classes with an explicit superclass' do
      inspect_source(cop,
                     ['class FooClass < Super',
                      '  class BarClass',
                      '  end',
                      'end'])
      expect(cop.offenses).to be_empty
    end
  end
end
