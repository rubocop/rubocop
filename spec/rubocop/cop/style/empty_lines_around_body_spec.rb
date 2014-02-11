# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::EmptyLinesAroundBody do
  subject(:cop) { described_class.new }

  it 'registers an offense for method body starting with a blank' do
    inspect_source(cop,
                   ['def some_method',
                    '',
                    '  do_something',
                    'end'])
    expect(cop.offenses.size).to eq(1)
  end

  # The cop only registers an offense if the extra line is completely emtpy. If
  # there is trailing whitespace, then that must be dealt with first. Having
  # two cops registering offense for the line with only spaces would cause
  # havoc in auto-correction.
  it 'accepts method body starting with a line with spaces' do
    inspect_source(cop,
                   ['def some_method',
                    '  ',
                    '  do_something',
                    'end'])
    expect(cop.offenses).to be_empty
  end

  it 'autocorrects method body starting with a blank' do
    corrected = autocorrect_source(cop,
                                   ['def some_method',
                                    '',
                                    '  do_something',
                                    'end'])
    expect(corrected).to eq ['def some_method',
                             '  do_something',
                             'end'].join("\n")
  end

  it 'registers an offense for class method body starting with a blank' do
    inspect_source(cop,
                   ['def Test.some_method',
                    '',
                    '  do_something',
                    'end'])
    expect(cop.offenses.size).to eq(1)
  end

  it 'autocorrects class method body starting with a blank' do
    corrected = autocorrect_source(cop,
                                   ['def Test.some_method',
                                    '',
                                    '  do_something',
                                    'end'])
    expect(corrected).to eq ['def Test.some_method',
                             '  do_something',
                             'end'].join("\n")
  end

  it 'registers an offense for method body ending with a blank' do
    inspect_source(cop,
                   ['def some_method',
                    '  do_something',
                    '',
                    'end'])
    expect(cop.offenses.size).to eq(1)
  end

  it 'registers an offense for class method body ending with a blank' do
    inspect_source(cop,
                   ['def Test.some_method',
                    '  do_something',
                    '',
                    'end'])
    expect(cop.offenses.size).to eq(1)
  end

  it 'registers an offense for class body starting with a blank' do
    inspect_source(cop,
                   ['class SomeClass',
                    '',
                    '  do_something',
                    'end'])
    expect(cop.offenses.size).to eq(1)
  end

  it 'autocorrects class body containing only a blank' do
    corrected = autocorrect_source(cop,
                                   ['class SomeClass',
                                    '',
                                    'end'])
    expect(corrected).to eq ['class SomeClass',
                             'end'].join("\n")
  end

  it 'registers an offense for module body starting with a blank' do
    inspect_source(cop,
                   ['module SomeModule',
                    '',
                    '  do_something',
                    'end'])
    expect(cop.offenses.size).to eq(1)
  end

  it 'registers an offense for class body ending with a blank' do
    inspect_source(cop,
                   ['class SomeClass',
                    '  do_something',
                    '',
                    'end'])
    expect(cop.offenses.size).to eq(1)
  end

  it 'registers an offense for module body ending with a blank' do
    inspect_source(cop,
                   ['module SomeModule',
                    '  do_something',
                    '',
                    'end'])
    expect(cop.offenses.size).to eq(1)
  end

  it 'is not fooled by single line methods' do
    inspect_source(cop,
                   ['def some_method; do_something; end',
                    '',
                    'something_else'])
    expect(cop.offenses).to be_empty
  end
end
