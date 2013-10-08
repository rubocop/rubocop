# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::Documentation do
  subject(:cop) { described_class.new }

  it 'registers an offence for non-empty class' do
    inspect_source(cop,
                   ['class My_Class',
                    '  TEST = 20',
                    'end'
                   ])
    expect(cop.offences.size).to eq(1)
  end

  it 'registers an offence for non-namespace' do
    inspect_source(cop,
                   ['module My_Class',
                    '  TEST = 20',
                    'end'
                   ])
    expect(cop.offences.size).to eq(1)
  end

  it 'registers an offence for empty module without documentation' do
    # Because why would you have an empty module? It requires some
    # explanation.
    inspect_source(cop,
                   ['module Test',
                    'end'
                   ])
    expect(cop.offences.size).to eq(1)
  end

  it 'accepts non-empty class with documentation' do
    inspect_source(cop,
                   ['# class comment',
                    'class My_Class',
                    '  TEST = 20',
                    'end'
                   ])
    expect(cop.offences).to be_empty
  end

  it 'accepts non-empty module with documentation' do
    inspect_source(cop,
                   ['# class comment',
                    'module My_Class',
                    '  TEST = 20',
                    'end'
                   ])
    expect(cop.offences).to be_empty
  end

  it 'accepts empty class without documentation' do
    inspect_source(cop,
                   ['class My_Class',
                    'end'
                   ])
    expect(cop.offences).to be_empty
  end

  it 'accepts namespace module without documentation' do
    inspect_source(cop,
                   ['module Test',
                    '  class A; end',
                    '  class B; end',
                    'end'
                   ])
    expect(cop.offences).to be_empty
  end

  it 'accepts namespace class without documentation' do
    inspect_source(cop,
                   ['class Test',
                    '  class A; end',
                    '  class B; end',
                    'end'
                   ])
    expect(cop.offences).to be_empty
  end
end
