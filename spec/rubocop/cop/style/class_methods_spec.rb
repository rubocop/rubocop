# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::ClassMethods do
  subject(:cop) { described_class.new }

  it 'registers an offence for methods using a class name' do
    inspect_source(cop,
                   ['class Test',
                    '  def Test.some_method',
                    '    do_something',
                    '  end',
                    'end'])
    expect(cop.offences.size).to eq(1)
  end

  it 'registers an offence for methods using a module name' do
    inspect_source(cop,
                   ['module Test',
                    '  def Test.some_method',
                    '    do_something',
                    '  end',
                    'end'])
    expect(cop.offences.size).to eq(1)
  end

  it 'does not register an offence for methods using self' do
    inspect_source(cop,
                   ['module Test',
                    '  def self.some_method',
                    '    do_something',
                    '  end',
                    'end'])
    expect(cop.offences).to be_empty
  end

  it 'does not register an offence outside class/module bodies' do
    inspect_source(cop,
                   ['def self.some_method',
                    '  do_something',
                    'end'])
    expect(cop.offences).to be_empty
  end
end
