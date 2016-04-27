# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Lint::ElseLayout do
  subject(:cop) { described_class.new }

  it 'registers an offense for expr on same line as else' do
    inspect_source(cop,
                   ['if something',
                    '  test',
                    'else ala',
                    '  something',
                    '  test',
                    'end'])
    expect(cop.offenses.size).to eq(1)
  end

  it 'accepts proper else' do
    inspect_source(cop,
                   ['if something',
                    '  test',
                    'else',
                    '  something',
                    '  test',
                    'end'])
    expect(cop.offenses).to be_empty
  end

  it 'accepts single-expr else regardless of layout' do
    inspect_source(cop,
                   ['if something',
                    '  test',
                    'else bala',
                    'end'])
    expect(cop.offenses).to be_empty
  end

  it 'can handle elsifs' do
    inspect_source(cop,
                   ['if something',
                    '  test',
                    'elsif something',
                    '  bala',
                    'else ala',
                    '  something',
                    '  test',
                    'end'])
    expect(cop.offenses.size).to eq(1)
  end

  it 'handles ternary ops' do
    inspect_source(cop, 'x ? a : b')
    expect(cop.offenses).to be_empty
  end

  it 'handles modifier forms' do
    inspect_source(cop, 'x if something')
    expect(cop.offenses).to be_empty
  end
end
