# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::UnlessElse do
  subject(:cop) { described_class.new }

  it 'registers an offense for an unless with else' do
    inspect_source(cop, ['unless x',
                         '  a = 1',
                         'else',
                         '  a = 0',
                         'end'])
    expect(cop.offenses.size).to eq(1)
  end

  it 'accepts an unless without else' do
    inspect_source(cop, ['unless x',
                         '  a = 1',
                         'end'])
    expect(cop.offenses).to be_empty
  end
end
