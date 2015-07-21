# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::Lint::FormatParameterMismatch do
  subject(:cop) { described_class.new }

  it 'registers an offense when there are less arguments than expected' do
    inspect_source(cop, 'format("%s %s", 1)')
    expect(cop.offenses.size).to eq(1)

    msg = ['Number arguments (1) to `format` mismatches expected fields (2).']
    expect(cop.messages).to eq(msg)
  end

  it 'registers an offense when there are more arguments than expected' do
    inspect_source(cop, 'format("%s %s", 1, 2, 3)')
    expect(cop.offenses.size).to eq(1)

    msgs = ['Number arguments (3) to `format` mismatches expected fields (2).']
    expect(cop.messages)
      .to eq(msgs)
  end

  it 'does not register an offense when arguments and fields match' do
    inspect_source(cop, 'format("%s %d %i", 1, 2, 3)')
    expect(cop.offenses).to be_empty
  end

  it 'correctly ignores double percent' do
    inspect_source(cop, "format('%s %s %% %s %%%% %%%%%%', 1, 2, 3)")
    expect(cop.offenses).to be_empty
  end

  it 'constants do not register offenses' do
    inspect_source(cop, 'format(A_CONST, 1, 2, 3)')
    expect(cop.offenses).to be_empty
  end

  it 'registers offense with sprintf' do
    inspect_source(cop, 'format("%s %s", 1, 2, 3)')
    expect(cop.offenses.size).to eq(1)

    msg = ['Number arguments (3) to `format` mismatches expected fields (2).']
    expect(cop.messages).to eq(msg)
  end

  it 'correctly parses different sprintf formats' do
    inspect_source(cop, 'format("%020x%+g:% g %%%#20.8x %#.0e", 1, 2, 3, 4, 5)')
    expect(cop.offenses).to be_empty
  end

  it 'registers an offense for String#%' do
    inspect_source(cop, '"%s %s" % [1, 2, 3]')
    expect(cop.offenses.size).to eq(1)

    msg = ['Number arguments (3) to `String#%` mismatches expected fields (2).']
    expect(cop.messages).to eq(msg)
  end

  it 'does not register an offense for % when arguments and fields match' do
    inspect_source(cop, '"%s %s" % [1, 2]')
    expect(cop.offenses).to be_empty
  end

  it 'finds the correct number of fields' do
    expect(''.scan(cop.fields_regex).size)
      .to eq(0)
    expect('%s'.scan(cop.fields_regex).size)
      .to eq(1)
    expect('%s %s'.scan(cop.fields_regex).size)
      .to eq(2)
    expect('%s %s %%'.scan(cop.fields_regex).size)
      .to eq(2)
    expect('%s %s %%'.scan(cop.fields_regex).size)
      .to eq(2)
    expect('% d'.scan(cop.fields_regex).size)
      .to eq(1)
    expect('%+d'.scan(cop.fields_regex).size)
      .to eq(1)
    expect('%d'.scan(cop.fields_regex).size)
      .to eq(1)
    expect('%+o'.scan(cop.fields_regex).size)
      .to eq(1)
    expect('%#o'.scan(cop.fields_regex).size)
      .to eq(1)
    expect('%.0e'.scan(cop.fields_regex).size)
      .to eq(1)
    expect('%#.0e'.scan(cop.fields_regex).size)
      .to eq(1)
    expect('% 020d'.scan(cop.fields_regex).size)
      .to eq(1)
    expect('%20d'.scan(cop.fields_regex).size)
      .to eq(1)
    expect('%+20d'.scan(cop.fields_regex).size)
      .to eq(1)
    expect('%020d'.scan(cop.fields_regex).size)
      .to eq(1)
    expect('%+020d'.scan(cop.fields_regex).size)
      .to eq(1)
    expect('% 020d'.scan(cop.fields_regex).size)
      .to eq(1)
    expect('%-20d'.scan(cop.fields_regex).size)
      .to eq(1)
    expect('%-+20d'.scan(cop.fields_regex).size)
      .to eq(1)
    expect('%- 20d'.scan(cop.fields_regex).size)
      .to eq(1)
    expect('%020x'.scan(cop.fields_regex).size)
      .to eq(1)
    expect('%#20.8x'.scan(cop.fields_regex).size)
      .to eq(1)
    expect('%+g:% g:%-g'.scan(cop.fields_regex).size)
      .to eq(3)
  end
end
