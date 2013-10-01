# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::SpecialGlobalVars do
  subject(:cop) { described_class.new }

  it 'registers an offence for $:' do
    inspect_source(cop, ['puts $:'])
    expect(cop.offences.size).to eq(1)
    expect(cop.messages)
      .to eq(['Prefer $LOAD_PATH over $:.'])
  end

  it 'registers an offence for $"' do
    inspect_source(cop, ['puts $"'])
    expect(cop.offences.size).to eq(1)
    expect(cop.messages)
      .to eq(['Prefer $LOADED_FEATURES over $".'])
  end

  it 'registers an offence for $0' do
    inspect_source(cop, ['puts $0'])
    expect(cop.offences.size).to eq(1)
    expect(cop.messages)
      .to eq(['Prefer $PROGRAM_NAME over $0.'])
  end

  it 'registers an offence for $$' do
    inspect_source(cop, ['puts $$'])
    expect(cop.offences.size).to eq(1)
    expect(cop.messages)
      .to eq(['Prefer $PID or $PROCESS_ID from English library' +
        ' over $$.'])
  end

  it 'does not register an offence for backrefs like $1' do
    inspect_source(cop, ['puts $1'])
    expect(cop.offences).to be_empty
  end

  it 'auto-corrects $: to $LOAD_PATH' do
    new_source = autocorrect_source(cop, '$:')
    expect(new_source).to eq('$LOAD_PATH')
  end
end
