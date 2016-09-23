# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'
require 'pry'

describe RuboCop::Cop::Style::AsciiCodeString do
  subject(:cop) { described_class.new }

  it 'allows strings using single quotes' do
    inspect_source(cop, "'a'")

    expect(cop.offenses).to be_empty
  end

  it 'allows strings using double quotes' do
    inspect_source(cop, '"a"')

    expect(cop.offenses).to be_empty
  end

  it 'allows strings using %' do
    inspect_source(cop, '%(a)')

    expect(cop.offenses).to be_empty
  end

  it 'allows strings using %q' do
    inspect_source(cop, '%q(a)')

    expect(cop.offenses).to be_empty
  end

  it 'allows strings using %Q' do
    inspect_source(cop, '%Q(a)')

    expect(cop.offenses).to be_empty
  end

  it 'allows strings using interpolation quotes' do
    inspect_source(cop, '"#{a}"')

    expect(cop.offenses).to be_empty
  end

  it 'allows strings that do not have beginning or ending symbols' do
    inspect_source(cop, '%x(ls)')

    expect(cop.offenses).to be_empty
  end

  it 'registers an offense for ascii code strings' do
    inspect_source(cop, '?a')

    expect(cop.messages).to eq([described_class::MSG])
  end

  context 'auto-correct' do
    it 'corrects an ascii code string to single quotes' do
      new_source = autocorrect_source(cop, '?a')

      expect(new_source).to eq("'a'")
    end
  end
end
