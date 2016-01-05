# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::Style::IfInsideElse do
  subject(:cop) { described_class.new }

  it 'catches an if node nested inside an else' do
    inspect_source(cop, ['if a',
                         '  blah',
                         'else',
                         '  if b',
                         '    foo',
                         '  end',
                         'end'])
    expect(cop.offenses.size).to eq(1)
    expect(cop.messages).to eq(
      ['Convert `if` nested inside `else` to `elsif`.'])
    expect(cop.highlights).to eq(['if'])
  end

  it 'catches an if..else nested inside an else' do
    inspect_source(cop, ['if a',
                         '  blah',
                         'else',
                         '  if b',
                         '    foo',
                         '  else',
                         '    bar',
                         '  end',
                         'end'])
    expect(cop.offenses.size).to eq(1)
    expect(cop.messages).to eq(
      ['Convert `if` nested inside `else` to `elsif`.'])
    expect(cop.highlights).to eq(['if'])
  end

  it 'catches a modifier if nested inside an else' do
    inspect_source(cop, ['if a',
                         '  blah',
                         'else',
                         '  foo if b',
                         'end'])
    expect(cop.offenses.size).to eq(1)
    expect(cop.messages).to eq(
      ['Convert `if` nested inside `else` to `elsif`.'])
    expect(cop.highlights).to eq(['if'])
  end

  it "isn't offended if there is a statement following the if node" do
    inspect_source(cop, ['if a',
                         '  blah',
                         'else',
                         '  if b',
                         '    foo',
                         '  end',
                         '  bar',
                         'end'])
    expect(cop.offenses).to be_empty
  end

  it "isn't offended if there is a statement preceding the if node" do
    inspect_source(cop, ['if a',
                         '  blah',
                         'else',
                         '  bar',
                         '  if b',
                         '    foo',
                         '  end',
                         'end'])
    expect(cop.offenses).to be_empty
  end

  it "isn't offended by if..elsif..else" do
    inspect_source(cop, ['if a',
                         '  blah',
                         'elsif b',
                         '  blah',
                         'else',
                         '  blah',
                         'end'])
    expect(cop.offenses).to be_empty
  end

  it 'ignores unless inside else' do
    inspect_source(cop, ['if a',
                         '  blah',
                         'else',
                         '  unless b',
                         '    foo',
                         '  end',
                         'end'])
    expect(cop.offenses).to be_empty
  end

  it 'ignores if inside unless' do
    inspect_source(cop, ['unless a',
                         '  if b',
                         '    foo',
                         '  end',
                         'end'])
    expect(cop.offenses).to be_empty
  end

  it 'ignores nested ternary expressions' do
    inspect_source(cop, 'a ? b : c ? d : e')
    expect(cop.offenses).to be_empty
  end

  it 'ignores ternary inside if..else' do
    inspect_source(cop, ['if a',
                         '  blah',
                         'else',
                         '  a ? b : c',
                         'end'])
    expect(cop.offenses).to be_empty
  end
end
