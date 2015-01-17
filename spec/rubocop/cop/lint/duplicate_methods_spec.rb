# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::Lint::DuplicateMethods do
  subject(:cop) { described_class.new }

  it 'registers an offense for duplicate method in class' do
    inspect_source(cop,
                   ['class A',
                    '  def some_method',
                    '    implement 1',
                    '  end',
                    '  def some_method',
                    '    implement 2',
                    '  end',
                    'end'])
    expect(cop.offenses.size).to eq(1)
  end

  it 'does not register an offense for non-duplicate method in class' do
    inspect_source(cop,
                   ['class A',
                    '  def some_method',
                    '    implement 1',
                    '  end',
                    '  def any_method',
                    '    implement 2',
                    '  end',
                    'end'])
    expect(cop.offenses).to be_empty
  end

  it 'registers an offense for duplicate method in module' do
    inspect_source(cop,
                   ['module A',
                    '  def some_method',
                    '    implement 1',
                    '  end',
                    '  def some_method',
                    '    implement 2',
                    '  end',
                    'end'])
    expect(cop.offenses.size).to eq(1)
  end

  it 'does not register an offense for non-duplicate method in module' do
    inspect_source(cop,
                   ['module A',
                    '  def some_method',
                    '    implement 1',
                    '  end',
                    '  def any_method',
                    '    implement 2',
                    '  end',
                    'end'])
    expect(cop.offenses).to be_empty
  end

  it 'registers an offense for duplicate class methods in module' do
    inspect_source(cop,
                   ['module A',
                    '  def self.some_method',
                    '    implement 1',
                    '  end',
                    '  def self.some_method',
                    '    implement 2',
                    '  end',
                    'end'])
    expect(cop.offenses.size).to eq(1)
  end
  it 'doesn`t registers an offense for non-duplicate class methods in module' do
    inspect_source(cop,
                   ['module A',
                    '  def self.some_method',
                    '    implement 1',
                    '  end',
                    '  def self.any_method',
                    '    implement 2',
                    '  end',
                    'end'])
    expect(cop.offenses.size).to eq(0)
  end

  it 'differ instance and class methods in module' do
    inspect_source(cop,
                   ['module A',
                    '  def some_method',
                    '    implement 1',
                    '  end',
                    '  def self.some_method',
                    '    implement 2',
                    '  end',
                    'end'])
    expect(cop.offenses.size).to eq(0)
  end

  it %(registers an offense for duplicate private methods in class) do
    inspect_source(cop,
                   ['class A',
                    '  private def some_method',
                    '    implement 1',
                    '  end',
                    '  private def some_method',
                    '    implement 2',
                    '  end',
                    'end'])
    expect(cop.offenses.size).to eq(1)
  end

  it %(registers an offense for duplicate private self methods in class) do
    inspect_source(cop,
                   ['class A',
                    '  private def self.some_method',
                    '    implement 1',
                    '  end',
                    '  private def self.some_method',
                    '    implement 2',
                    '  end',
                    'end'])
    expect(cop.offenses.size).to eq(1)
  end

  it %(don`t registers an offense for different private methods in class) do
    inspect_source(cop,
                   ['class A',
                    '  private def some_method',
                    '    implement 1',
                    '  end',
                    '  private def any_method',
                    '    implement 2',
                    '  end',
                    'end'])
    expect(cop.offenses.size).to eq(0)
  end

  it %(registers an offense for duplicate protected methods in class) do
    inspect_source(cop,
                   ['class A',
                    '  protected def some_method',
                    '    implement 1',
                    '  end',
                    '  protected def some_method',
                    '    implement 2',
                    '  end',
                    'end'])
    expect(cop.offenses.size).to eq(1)
  end

  it %(registers 2 offenses for pair of duplicate methods in class) do
    inspect_source(cop,
                   ['class A',
                    '  def some_method',
                    '    implement 1',
                    '  end',
                    '  def some_method',
                    '    implement 2',
                    '  end',
                    '  def any_method',
                    '    implement 1',
                    '  end',
                    '  def any_method',
                    '    implement 2',
                    '  end',
                    'end'])
    expect(cop.offenses.size).to eq(2)
  end

  it %(generate 2 offenses with specified messages) do
    inspect_source(cop,
                   ['class A',
                    '  def some_method',
                    '    implement 1',
                    '  end',
                    '  def some_method',
                    '    implement 2',
                    '  end',
                    '  def any_method',
                    '    implement 1',
                    '  end',
                    '  def any_method',
                    '    implement 2',
                    '  end',
                    'end'])
    expect(cop.messages).to match_array([
      %(Duplicate methods `some_method` at lines `2, 5` detected.),
      %(Duplicate methods `any_method` at lines `8, 11` detected.)])
  end
end
