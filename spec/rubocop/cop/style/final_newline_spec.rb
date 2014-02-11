# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::FinalNewline do
  subject(:cop) { described_class.new }

  it 'registers an offense for missing final newline' do
    source = ['x = 0', 'top']
    inspect_source(cop, source)
    expect(cop.offenses.size).to eq(1)
  end

  it 'accepts a final newline' do
    source = ['x = 0', 'top', '']
    inspect_source(cop, source)
    expect(cop.offenses).to be_empty
  end

  it 'accepts an empty file' do
    source = ['']
    inspect_source(cop, source)
    expect(cop.offenses).to be_empty
  end

  it 'auto-corrects missing newline' do
    new_source = autocorrect_source(cop, ['x = 0'])
    expect(new_source).to eq(['x = 0', ''].join("\n"))
  end
end
