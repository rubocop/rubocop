# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::Style::Documentation do
  subject(:cop) { described_class.new(config) }
  let(:config) do
    RuboCop::Config.new('Style/CommentAnnotation' => {
                          'Keywords' => %w(TODO FIXME OPTIMIZE HACK REVIEW)
                        })
  end

  it 'registers an offense for non-empty class' do
    inspect_source(cop,
                   ['class My_Class',
                    '  TEST = 20',
                    'end'
                   ])
    expect(cop.offenses.size).to eq(1)
  end

  it 'does not consider comment followed by empty line to be class ' \
     'documentation' do
    inspect_source(cop,
                   ['# Copyright 2014',
                    '# Some company',
                    '',
                    'class My_Class',
                    '  TEST = 20',
                    'end'
                   ])
    expect(cop.offenses.size).to eq(1)
  end

  it 'registers an offense for non-namespace' do
    inspect_source(cop,
                   ['module My_Class',
                    '  TEST = 20',
                    'end'
                   ])
    expect(cop.offenses.size).to eq(1)
  end

  it 'registers an offense for empty module without documentation' do
    # Because why would you have an empty module? It requires some
    # explanation.
    inspect_source(cop,
                   ['module Test',
                    'end'
                   ])
    expect(cop.offenses.size).to eq(1)
  end

  it 'accepts non-empty class with documentation' do
    inspect_source(cop,
                   ['# class comment',
                    'class My_Class',
                    '  TEST = 20',
                    'end'
                   ])
    expect(cop.offenses).to be_empty
  end

  it 'registers an offense for non-empty class with annotation comment' do
    inspect_source(cop,
                   ['# OPTIMIZE: Make this faster.',
                    'class My_Class',
                    '  TEST = 20',
                    'end'
                   ])
    expect(cop.offenses.size).to eq(1)
  end

  it 'accepts non-empty class with annotation comment followed by other ' \
     'comment' do
    inspect_source(cop,
                   ['# OPTIMIZE: Make this faster.',
                    '# Class comment.',
                    'class My_Class',
                    '  TEST = 20',
                    'end'
                   ])
    expect(cop.offenses).to be_empty
  end

  it 'accepts non-empty class with comment that ends with an annotation' do
    inspect_source(cop,
                   ['# Does fooing.',
                    '# FIXME: Not yet implemented.',
                    'class Foo',
                    '  def initialize',
                    '  end',
                    'end'
                   ])
    expect(cop.offenses).to be_empty
  end

  it 'accepts non-empty module with documentation' do
    inspect_source(cop,
                   ['# class comment',
                    'module My_Class',
                    '  TEST = 20',
                    'end'
                   ])
    expect(cop.offenses).to be_empty
  end

  it 'accepts empty class without documentation' do
    inspect_source(cop,
                   ['class My_Class',
                    'end'
                   ])
    expect(cop.offenses).to be_empty
  end

  it 'accepts namespace module without documentation' do
    inspect_source(cop,
                   ['module Test',
                    '  class A; end',
                    '  class B; end',
                    'end'
                   ])
    expect(cop.offenses).to be_empty
  end

  it 'accepts namespace class without documentation' do
    inspect_source(cop,
                   ['class Test',
                    '  class A; end',
                    '  class B; end',
                    'end'
                   ])
    expect(cop.offenses).to be_empty
  end

  it 'does not raise an error for an implicit match conditional' do
    expect do
      inspect_source(cop,
                     ['class Test',
                      '  if //',
                      '  end',
                      'end'
                     ])
    end.to_not raise_error
  end
end
