# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::Lint::NestedMethodDefinition do
  subject(:cop) { described_class.new }

  it 'registers an offense for a nested method definition' do
    inspect_source(cop, 'def x; def y; end; end')
    expect(cop.offenses.size).to eq(1)
  end

  it 'registers an offense for a nested singleton method definition' do
    inspect_source(cop, ['class Foo',
                         'end',
                         'foo = Foo.new',
                         'def foo.bar',
                         '  def baz',
                         '  end',
                         'end'])
    expect(cop.offenses.size).to eq(1)
  end

  it 'registers an offense for a nested method definition inside lambda' do
    inspect_source(cop, ['def foo',
                         '  bar = -> { def baz; puts; end }',
                         'end'])
    expect(cop.offenses.size).to eq(1)
  end

  it 'does not register an offense for a lambda definition inside method' do
    inspect_source(cop, ['def foo',
                         '  bar = -> { puts  }',
                         '  bar.call',
                         'end'])
    expect(cop.offenses.size).to eq(0)
  end

  it 'does not register an offense for a nested class method definition' do
    inspect_source(cop, ['class Foo',
                         '  def self.x',
                         '    def self.y',
                         '    end',
                         '  end',
                         'end'])
    expect(cop.offenses.size).to eq(0)
  end
end
