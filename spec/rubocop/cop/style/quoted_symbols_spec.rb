# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::QuotedSymbols, :config do
  shared_examples_for 'enforce single quotes' do
    it 'accepts unquoted symbols' do
      expect_no_offenses(<<~RUBY)
        :a
      RUBY
    end

    it 'accepts single quotes' do
      expect_no_offenses(<<~RUBY)
        :'a'
      RUBY
    end

    it 'accepts double quotes with interpolation' do
      expect_no_offenses(<<~'RUBY')
        :"#{a}"
      RUBY
    end

    it 'accepts double quotes when interpolating an instance variable' do
      expect_no_offenses(<<~'RUBY')
        :"#@test"
      RUBY
    end

    it 'accepts double quotes when interpolating a global variable' do
      expect_no_offenses(<<~'RUBY')
        :"#$test"
      RUBY
    end

    it 'accepts double quotes when interpolating a class variable' do
      expect_no_offenses(<<~'RUBY')
        :"#@@test"
      RUBY
    end

    it 'accepts double quotes with escape sequences' do
      expect_no_offenses(<<~RUBY)
        :"a\nb"
      RUBY
    end

    it 'accepts single quotes with double quotes' do
      expect_no_offenses(<<~RUBY)
        :'"'
      RUBY
    end

    it 'accepts double quotes with single quotes' do
      expect_no_offenses(<<~RUBY)
        :"'"
      RUBY
    end

    it 'accepts single quotes with line breaks' do
      expect_no_offenses(<<~RUBY)
        :'a
          bc'
      RUBY
    end

    it 'accepts double quotes with line breaks' do
      expect_no_offenses(<<~RUBY)
        :"a
          bc"
      RUBY
    end

    it 'accepts double quotes when control characters are used' do
      expect_no_offenses(<<~'RUBY')
        :"\e"
      RUBY
    end

    it 'accepts double quotes when unicode control sequence is used' do
      expect_no_offenses(<<~'RUBY')
        :"Espa\u00f1a"
      RUBY
    end

    it 'accepts double quotes with some other special symbols' do
      # "Substitutions in double-quoted symbols"
      # http://www.ruby-doc.org/docs/ProgrammingRuby/html/language.html
      expect_no_offenses(<<~'RUBY')
        g = :"\x3D"
        copyright = :"\u00A9"
      RUBY
    end

    it 'registers an offense and corrects for double quotes without interpolation' do
      expect_offense(<<~RUBY)
        :"a"
        ^^^^ Prefer single-quoted symbols when you don't need string interpolation or special symbols.
      RUBY

      expect_correction(<<~RUBY)
        :'a'
      RUBY
    end

    it 'registers an offense and corrects for double quotes in hash keys' do
      expect_offense(<<~RUBY)
        { "a": value }
          ^^^ Prefer single-quoted symbols when you don't need string interpolation or special symbols.
      RUBY

      expect_correction(<<~RUBY)
        { 'a': value }
      RUBY
    end

    it 'registers an offense and corrects for an escaped quote within double quotes' do
      expect_offense(<<~'RUBY')
        :"my\"quote"
        ^^^^^^^^^^^^ Prefer single-quoted symbols when you don't need string interpolation or special symbols.
      RUBY

      expect_correction(<<~RUBY)
        :'my"quote'
      RUBY
    end

    it 'registers an offense and corrects escape characters properly' do
      expect_offense(<<~'RUBY')
        :"foo\\bar"
        ^^^^^^^^^^^ Prefer single-quoted symbols when you don't need string interpolation or special symbols.
      RUBY

      expect_correction(<<~'RUBY')
        :'foo\\bar'
      RUBY
    end

    it 'accepts single quoted symbol with an escaped quote' do
      expect_no_offenses(<<~'RUBY')
        :'o\'clock'
      RUBY
    end

    context 'hash with hash rocket style' do
      it 'accepts properly quoted symbols' do
        expect_no_offenses(<<~RUBY)
          { :'a' => value }
        RUBY
      end

      it 'corrects wrong quotes' do
        expect_offense(<<~RUBY)
          { :"a" => value }
            ^^^^ Prefer single-quoted symbols when you don't need string interpolation or special symbols.
        RUBY

        expect_correction(<<~RUBY)
          { :'a' => value }
        RUBY
      end
    end
  end

  shared_examples_for 'enforce double quotes' do
    it 'accepts unquoted symbols' do
      expect_no_offenses(<<~RUBY)
        :a
      RUBY
    end

    it 'accepts double quotes' do
      expect_no_offenses(<<~RUBY)
        :"a"
      RUBY
    end

    it 'accepts double quotes with interpolation' do
      expect_no_offenses(<<~'RUBY')
        :"#{a}"
      RUBY
    end

    it 'accepts double quotes when interpolating an instance variable' do
      expect_no_offenses(<<~'RUBY')
        :"#@test"
      RUBY
    end

    it 'accepts double quotes when interpolating a global variable' do
      expect_no_offenses(<<~'RUBY')
        :"#$test"
      RUBY
    end

    it 'accepts double quotes when interpolating a class variable' do
      expect_no_offenses(<<~'RUBY')
        :"#@@test"
      RUBY
    end

    it 'accepts double quotes with escape sequences' do
      expect_no_offenses(<<~RUBY)
        :"a\nb"
      RUBY
    end

    it 'accepts single quotes with double quotes' do
      expect_no_offenses(<<~RUBY)
        :'"'
      RUBY
    end

    it 'accepts double quotes with single quotes' do
      expect_no_offenses(<<~RUBY)
        :"'"
      RUBY
    end

    it 'accepts single quotes with line breaks' do
      expect_no_offenses(<<~RUBY)
        :'a
          bc'
      RUBY
    end

    it 'accepts double quotes with line breaks' do
      expect_no_offenses(<<~RUBY)
        :'a
          bc'
      RUBY
    end

    it 'registers an offense for single quotes' do
      expect_offense(<<~RUBY)
        :'a'
        ^^^^ Prefer double-quoted symbols unless you need single quotes to avoid extra backslashes for escaping.
      RUBY

      expect_correction(<<~RUBY)
        :"a"
      RUBY
    end

    it 'registers an offense and corrects for an escaped quote within single quotes' do
      expect_offense(<<~'RUBY')
        :'o\'clock'
        ^^^^^^^^^^^ Prefer double-quoted symbols unless you need single quotes to avoid extra backslashes for escaping.
      RUBY

      expect_correction(<<~RUBY)
        :"o'clock"
      RUBY
    end

    it 'registers an offense and corrects escape characters properly' do
      expect_offense(<<~'RUBY')
        :'foo\\bar'
        ^^^^^^^^^^^ Prefer double-quoted symbols unless you need single quotes to avoid extra backslashes for escaping.
      RUBY

      expect_correction(<<~'RUBY')
        :"foo\\bar"
      RUBY
    end

    it 'accepts double quoted symbol with an escaped quote' do
      expect_no_offenses(<<~'RUBY')
        :"my\"quote"
      RUBY
    end

    context 'hash with hash rocket style' do
      it 'accepts properly quoted symbols' do
        expect_no_offenses(<<~RUBY)
          { :"a" => value }
        RUBY
      end

      it 'corrects wrong quotes' do
        expect_offense(<<~RUBY)
          { :'a' => value }
            ^^^^ Prefer double-quoted symbols unless you need single quotes to avoid extra backslashes for escaping.
        RUBY

        expect_correction(<<~RUBY)
          { :"a" => value }
        RUBY
      end
    end
  end

  context 'configured with `same_as_string_literals`' do
    let(:cop_config) { { 'EnforcedStyle' => 'same_as_string_literals' } }

    context 'when Style/StringLiterals is configured with single_quotes' do
      let(:other_cops) { { 'Style/StringLiterals' => { 'EnforcedStyle' => 'single_quotes' } } }

      it_behaves_like 'enforce single quotes'
    end

    context 'when Style/StringLiterals is configured with double_quotes' do
      let(:other_cops) { { 'Style/StringLiterals' => { 'EnforcedStyle' => 'double_quotes' } } }

      it_behaves_like 'enforce double quotes'
    end

    context 'when Style/StringLiterals is disabled' do
      let(:other_cops) { { 'Style/StringLiterals' => { 'Enabled' => false } } }

      it_behaves_like 'enforce single quotes'
    end
  end

  context 'configured with `single_quotes`' do
    let(:cop_config) { { 'EnforcedStyle' => 'single_quotes' } }

    it_behaves_like 'enforce single quotes'
  end

  context 'configured with `double_quotes`' do
    let(:cop_config) { { 'EnforcedStyle' => 'double_quotes' } }

    it_behaves_like 'enforce double quotes'
  end
end
