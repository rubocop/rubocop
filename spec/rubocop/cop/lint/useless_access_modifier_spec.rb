# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::Lint::UselessAccessModifier do
  subject(:cop) { described_class.new }

  context 'when an access modifier has no effect' do
    let(:source) do
      [
        'class SomeClass',
        '  def some_method',
        '    puts 10',
        '  end',
        '  private',
        '  def self.some_method',
        '    puts 10',
        '  end',
        'end'
      ]
    end

    it 'registers an offense' do
      inspect_source(cop, source)
      expect(cop.offenses.size).to eq(1)
      expect(cop.offenses.first.message)
        .to eq('Useless `private` access modifier.')
      expect(cop.offenses.first.line).to eq(5)
      expect(cop.highlights).to eq(['private'])
    end
  end

  context 'when an access modifier has no methods' do
    let(:source) do
      [
        'class SomeClass',
        '  protected',
        'end'
      ]
    end

    it 'registers an offense' do
      inspect_source(cop, source)
      expect(cop.offenses.size).to eq(1)
      expect(cop.offenses.first.message)
        .to eq('Useless `protected` access modifier.')
      expect(cop.offenses.first.line).to eq(2)
      expect(cop.highlights).to eq(['protected'])
    end
  end

  context 'when an access modifier is followed by attr_*' do
    let(:source) do
      [
        'class SomeClass',
        '  protected',
        '  attr_accessor :some_property',
        'end'
      ]
    end

    it 'does not register an offense' do
      inspect_source(cop, source)
      expect(cop.offenses.size).to eq(0)
    end
  end

  context 'when an access modifier is followed by a ' \
    'class method defined on constant' do
    let(:source) do
      [
        'class SomeClass',
        '  protected',
        '  def SomeClass.some_method',
        '  end',
        'end'
      ]
    end

    it 'registers an offense' do
      inspect_source(cop, source)
      expect(cop.offenses.size).to eq(1)
      expect(cop.offenses.first.message)
        .to eq('Useless `protected` access modifier.')
      expect(cop.offenses.first.line).to eq(2)
      expect(cop.highlights).to eq(['protected'])
    end
  end

  context 'when consecutive access modifiers' do
    let(:source) do
      [
        'class SomeClass',
        ' private',
        ' private',
        '  def some_method',
        '    puts 10',
        '  end',
        '  def some_other_method',
        '    puts 10',
        '  end',
        'end'
      ]
    end

    it 'registers an offense' do
      inspect_source(cop, source)
      expect(cop.offenses.size).to eq(1)
      expect(cop.offenses.first.message)
        .to eq('Useless `private` access modifier.')
      expect(cop.offenses.first.line).to eq(2)
      expect(cop.highlights).to eq(['private'])
    end
  end

  context 'when passing method as symbol' do
    let(:source) do
      [
        'class SomeClass',
        '  def some_method',
        '    puts 10',
        '  end',
        '  private :some_method',
        'end'
      ]
    end

    it 'does not register an offense' do
      inspect_source(cop, source)
      expect(cop.offenses.size).to eq(0)
    end
  end

  context 'when class is empty save modifier' do
    let(:source) do
      [
        'class SomeClass',
        '  private',
        'end'
      ]
    end

    it 'registers an offense' do
      inspect_source(cop, source)
      expect(cop.offenses.size).to eq(1)
      expect(cop.offenses.first.message)
        .to eq('Useless `private` access modifier.')
      expect(cop.offenses.first.line).to eq(2)
      expect(cop.highlights).to eq(['private'])
    end
  end

  context 'when multiple class definitions in file but only one has offense' do
    let(:source) do
      [
        'class SomeClass',
        '  private',
        'end',
        'class SomeOtherClass',
        'end'
      ]
    end

    it 'registers an offense' do
      inspect_source(cop, source)
      expect(cop.offenses.size).to eq(1)
      expect(cop.offenses.first.message)
        .to eq('Useless `private` access modifier.')
      expect(cop.offenses.first.line).to eq(2)
      expect(cop.highlights).to eq(['private'])
    end
  end

  if RUBY_ENGINE == 'ruby' && RUBY_VERSION.start_with?('2.1')
    context 'ruby 2.1 style modifiers' do
      let(:source) do
        [
          'class SomeClass',
          '  private def some_method',
          '    puts 10',
          '  end',
          'end'
        ]
      end

      it 'does not register an offense' do
        inspect_source(cop, source)
        expect(cop.offenses.size).to eq(0)
      end
    end
  end
end
