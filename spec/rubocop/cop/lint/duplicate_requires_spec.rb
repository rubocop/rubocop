# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::Lint::DuplicateRequires do
  subject(:cop) { described_class.new }

  it %(registers an offense for duplicate requires in file) do
    inspect_source(cop,
                   ['require "something"',
                    'require "something"',
                    'class A',
                    'end'])
    expect(cop.offenses.size).to eq(1)
  end

  it %(does not register an offense for duplicate requires in a file) do
    inspect_source(cop,
                   ['require "something"',
                    'require "something-else"',
                    'class A',
                    'end'])
    expect(cop.offenses).to be_empty
  end

  it %(registers offenses when requires are in various parts of the file) do
    inspect_source(cop,
                   ['require "something"',
                    'class A',
                    '  require "something"',
                    '  def a_method',
                    '    require "something"',
                    '  end',
                    'end'])
    expect(cop.offenses.size).to eq(2)
  end

  it %(generated offenses with a specific message) do
    inspect_source(cop,
                   ['require "something"',
                    'class A',
                    '  require "something"',
                    'end'])
    expect(cop.messages).to match_array([
      %(`something` has already been required in this file.)
    ])
  end
end
