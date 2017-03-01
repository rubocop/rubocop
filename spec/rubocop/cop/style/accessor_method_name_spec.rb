# frozen_string_literal: true

describe RuboCop::Cop::Style::AccessorMethodName do
  subject(:cop) { described_class.new }

  it 'registers an offense for method get_... with no args' do
    inspect_source(cop, ['def get_attr',
                         '  # ...',
                         'end'])
    expect(cop.offenses.size).to eq(1)
    expect(cop.highlights).to eq(['get_attr'])
  end

  it 'registers an offense for singleton method get_... with no args' do
    inspect_source(cop, ['def self.get_attr',
                         '  # ...',
                         'end'])
    expect(cop.offenses.size).to eq(1)
    expect(cop.highlights).to eq(['get_attr'])
  end

  it 'accepts method get_something with args' do
    inspect_source(cop, ['def get_something(arg)',
                         '  # ...',
                         'end'])
    expect(cop.offenses).to be_empty
  end

  it 'accepts singleton method get_something with args' do
    inspect_source(cop, ['def self.get_something(arg)',
                         '  # ...',
                         'end'])
    expect(cop.offenses).to be_empty
  end

  it 'registers an offense for method set_something with one arg' do
    inspect_source(cop, ['def set_attr(arg)',
                         '  # ...',
                         'end'])
    expect(cop.offenses.size).to eq(1)
    expect(cop.highlights).to eq(['set_attr'])
  end

  it 'registers an offense for singleton method set_... with one args' do
    inspect_source(cop, ['def self.set_attr(arg)',
                         '  # ...',
                         'end'])
    expect(cop.offenses.size).to eq(1)
    expect(cop.highlights).to eq(['set_attr'])
  end

  it 'accepts method set_something with no args' do
    inspect_source(cop, ['def set_something',
                         '  # ...',
                         'end'])
    expect(cop.offenses).to be_empty
  end

  it 'accepts singleton method set_something with no args' do
    inspect_source(cop, ['def self.set_something',
                         '  # ...',
                         'end'])
    expect(cop.offenses).to be_empty
  end

  it 'accepts method set_something with two args' do
    inspect_source(cop, ['def set_something(arg1, arg2)',
                         '  # ...',
                         'end'])
    expect(cop.offenses).to be_empty
  end

  it 'accepts singleton method set_something with two args' do
    inspect_source(cop, ['def self.get_something(arg1, arg2)',
                         '  # ...',
                         'end'])
    expect(cop.offenses).to be_empty
  end
end
