# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::Style::SpecialGlobalVars, :config do
  subject(:cop) { described_class.new(config) }

  context 'when style is use_english_names' do
    let(:cop_config) { { 'EnforcedStyle' => 'use_english_names' } }

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
        .to eq(['Prefer `$PROCESS_ID` or `$PID` from the stdlib \'English\' ' \
                'module over `$$`.'])
    end

    it 'is clear about variables from the English library vs those not' do
      inspect_source(cop, 'puts $*')
      expect(cop.messages)
        .to eq(['Prefer `$ARGV` from the stdlib \'English\' module, ' \
                'or `ARGV` over `$*`.'])
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

    it 'generates correct auto-config when Perl variable names are used' do
      inspect_source(cop, '$0')
      expect(cop.config_to_allow_offenses).to eq(
        'EnforcedStyle' => 'use_perl_names')
    end

    it 'generates correct auto-config when mixed styles are used' do
      inspect_source(cop, '$!; $ERROR_INFO')
      expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
    end
  end

  context 'when style is use_perl_names' do
    let(:cop_config) { { 'EnforcedStyle' => 'use_perl_names' } }

    it 'registers an offense for $LOAD_PATH' do
      inspect_source(cop, 'puts $LOAD_PATH')
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages).to eq(['Prefer `$:` over `$LOAD_PATH`.'])
    end

    it 'registers an offense for $LOADED_FEATURES' do
      inspect_source(cop, 'puts $LOADED_FEATURES')
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages).to eq(['Prefer `$"` over `$LOADED_FEATURES`.'])
    end

    it 'registers an offense for $PROGRAM_NAME' do
      inspect_source(cop, 'puts $PROGRAM_NAME')
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages).to eq(['Prefer `$0` over `$PROGRAM_NAME`.'])
    end

    it 'registers an offense for $PID' do
      inspect_source(cop, 'puts $PID')
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(['Prefer `$$` over `$PID`.'])
    end

    it 'registers an offense for $PROCESS_ID' do
      inspect_source(cop, 'puts $PROCESS_ID')
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(['Prefer `$$` over `$PROCESS_ID`.'])
    end

    it 'does not register an offense for backrefs like $1' do
      inspect_source(cop, 'puts $1')
      expect(cop.offenses).to be_empty
    end

    it 'auto-corrects $LOAD_PATH to $:' do
      new_source = autocorrect_source(cop, '$LOAD_PATH')
      expect(new_source).to eq('$:')
    end

    it 'auto-corrects $INPUT_RECORD_SEPARATOR to $/' do
      new_source = autocorrect_source(cop, '$INPUT_RECORD_SEPARATOR')
      expect(new_source).to eq('$/')
    end

    it 'auto-corrects #{$LOAD_PATH} to #$:' do
      new_source = autocorrect_source(cop, '"#{$LOAD_PATH}"')
      expect(new_source).to eq('"#$:"')
    end
  end
end
