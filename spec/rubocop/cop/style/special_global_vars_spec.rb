# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::Style::SpecialGlobalVars do
  subject(:cop) { described_class.new }

  it 'registers an offense for $:' do
    inspect_source(cop, 'puts $:')
    expect(cop.offenses.size).to eq(1)
    expect(cop.messages)
      .to eq(['Prefer `$LOAD_PATH` over `$:`.'])
  end

  it 'registers an offense for $"' do
    inspect_source(cop, 'puts $"')
    expect(cop.offenses.size).to eq(1)
    expect(cop.messages)
      .to eq(['Prefer `$LOADED_FEATURES` over `$"`.'])
  end

  it 'registers an offense for $0' do
    inspect_source(cop, 'puts $0')
    expect(cop.offenses.size).to eq(1)
    expect(cop.messages)
      .to eq(['Prefer `$PROGRAM_NAME` over `$0`.'])
  end

  it 'registers an offense for $$' do
    inspect_source(cop, 'puts $$')
    expect(cop.offenses.size).to eq(1)
    expect(cop.messages)
      .to eq(['Prefer `$PROCESS_ID` or `$PID` from the English ' \
              'library over `$$`.'])
  end

  it 'is clear about variables from the English library vs those not' do
    inspect_source(cop, 'puts $*')
    expect(cop.messages)
      .to eq(['Prefer `$ARGV` from the English library, or `ARGV` over `$*`.'])
  end

  it 'does not register an offense for backrefs like $1' do
    inspect_source(cop, 'puts $1')
    expect(cop.offenses).to be_empty
  end

  it 'auto-corrects $: to $LOAD_PATH' do
    new_source = autocorrect_source(cop, '$:')
    expect(new_source).to eq('$LOAD_PATH')
  end

  it 'auto-corrects $/ to $INPUT_RECORD_SEPARATOR' do
    new_source = autocorrect_source(cop, '$/')
    expect(new_source).to eq('$INPUT_RECORD_SEPARATOR')
  end

  it 'auto-corrects #$: to #{$LOAD_PATH}' do
    new_source = autocorrect_source(cop, '"#$:"')
    expect(new_source).to eq('"#{$LOAD_PATH}"')
  end
end
