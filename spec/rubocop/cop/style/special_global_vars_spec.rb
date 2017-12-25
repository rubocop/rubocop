# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::SpecialGlobalVars, :config do
  subject(:cop) { described_class.new(config) }

  context 'when style is use_english_names' do
    let(:cop_config) { { 'EnforcedStyle' => 'use_english_names' } }

    it 'registers an offense for $:' do
      expect_offense(<<-RUBY.strip_indent)
        puts $:
             ^^ Prefer `$LOAD_PATH` over `$:`.
      RUBY
    end

    it 'registers an offense for $"' do
      expect_offense(<<-RUBY.strip_indent)
        puts $"
             ^^ Prefer `$LOADED_FEATURES` over `$"`.
      RUBY
    end

    it 'registers an offense for $0' do
      expect_offense(<<-RUBY.strip_indent)
        puts $0
             ^^ Prefer `$PROGRAM_NAME` over `$0`.
      RUBY
    end

    it 'registers an offense for $$' do
      expect_offense(<<-RUBY.strip_indent)
        puts $$
             ^^ Prefer `$PROCESS_ID` or `$PID` from the stdlib 'English' module (don't forget to require it) over `$$`.
      RUBY
    end

    it 'is clear about variables from the English library vs those not' do
      expect_offense(<<-RUBY.strip_indent)
        puts $*
             ^^ Prefer `$ARGV` from the stdlib 'English' module (don't forget to require it), or `ARGV` over `$*`.
      RUBY
    end

    it 'does not register an offense for backrefs like $1' do
      expect_no_offenses('puts $1')
    end

    it 'auto-corrects $: to $LOAD_PATH' do
      new_source = autocorrect_source('$:')
      expect(new_source).to eq('$LOAD_PATH')
    end

    it 'auto-corrects $/ to $INPUT_RECORD_SEPARATOR' do
      new_source = autocorrect_source('$/')
      expect(new_source).to eq('$INPUT_RECORD_SEPARATOR')
    end

    it 'auto-corrects #$: to #{$LOAD_PATH}' do
      new_source = autocorrect_source('"#$:"')
      expect(new_source).to eq('"#{$LOAD_PATH}"')
    end

    it 'auto-corrects #{$!} to #{$ERROR_INFO}' do
      new_source = autocorrect_source('"#{$!}"')
      expect(new_source).to eq('"#{$ERROR_INFO}"')
    end

    it 'generates correct auto-config when Perl variable names are used' do
      inspect_source('$0')
      expect(cop.config_to_allow_offenses).to eq(
        'EnforcedStyle' => 'use_perl_names'
      )
    end

    it 'generates correct auto-config when mixed styles are used' do
      inspect_source('$!; $ERROR_INFO')
      expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
    end
  end

  context 'when style is use_perl_names' do
    let(:cop_config) { { 'EnforcedStyle' => 'use_perl_names' } }

    it 'registers an offense for $LOAD_PATH' do
      expect_offense(<<-RUBY.strip_indent)
        puts $LOAD_PATH
             ^^^^^^^^^^ Prefer `$:` over `$LOAD_PATH`.
      RUBY
    end

    it 'registers an offense for $LOADED_FEATURES' do
      expect_offense(<<-RUBY.strip_indent)
        puts $LOADED_FEATURES
             ^^^^^^^^^^^^^^^^ Prefer `$"` over `$LOADED_FEATURES`.
      RUBY
    end

    it 'registers an offense for $PROGRAM_NAME' do
      expect_offense(<<-RUBY.strip_indent)
        puts $PROGRAM_NAME
             ^^^^^^^^^^^^^ Prefer `$0` over `$PROGRAM_NAME`.
      RUBY
    end

    it 'registers an offense for $PID' do
      expect_offense(<<-RUBY.strip_indent)
        puts $PID
             ^^^^ Prefer `$$` over `$PID`.
      RUBY
    end

    it 'registers an offense for $PROCESS_ID' do
      expect_offense(<<-RUBY.strip_indent)
        puts $PROCESS_ID
             ^^^^^^^^^^^ Prefer `$$` over `$PROCESS_ID`.
      RUBY
    end

    it 'does not register an offense for backrefs like $1' do
      expect_no_offenses('puts $1')
    end

    it 'auto-corrects $LOAD_PATH to $:' do
      new_source = autocorrect_source('$LOAD_PATH')
      expect(new_source).to eq('$:')
    end

    it 'auto-corrects $INPUT_RECORD_SEPARATOR to $/' do
      new_source = autocorrect_source('$INPUT_RECORD_SEPARATOR')
      expect(new_source).to eq('$/')
    end

    it 'auto-corrects #{$LOAD_PATH} to #$:' do
      new_source = autocorrect_source('"#{$LOAD_PATH}"')
      expect(new_source).to eq('"#$:"')
    end
  end
end
