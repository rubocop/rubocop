# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::NumericLiteralPrefix, :config do
  context 'octal literals' do
    context 'when config is zero_with_o' do
      let(:cop_config) { { 'EnforcedOctalStyle' => 'zero_with_o' } }

      it 'registers an offense for prefixes `0` and `0O`' do
        expect_offense(<<~RUBY)
          a = 01234
              ^^^^^ Use 0o for octal literals.
          b(0O1234)
            ^^^^^^ Use 0o for octal literals.
        RUBY

        expect_correction(<<~RUBY)
          a = 0o1234
          b(0o1234)
        RUBY
      end

      it 'does not register offense for lowercase prefix' do
        expect_no_offenses(<<~RUBY)
          a = 0o101
          b = 0o567
        RUBY
      end
    end

    context 'when config is zero_only' do
      let(:cop_config) { { 'EnforcedOctalStyle' => 'zero_only' } }

      it 'registers an offense for prefix `0O` and `0o`' do
        expect_offense(<<~RUBY)
          a = 0O1234
              ^^^^^^ Use 0 for octal literals.
          b(0o1234)
            ^^^^^^ Use 0 for octal literals.
        RUBY

        expect_correction(<<~RUBY)
          a = 01234
          b(01234)
        RUBY
      end

      it 'does not register offense for prefix `0`' do
        expect_no_offenses('b = 0567')
      end
    end
  end

  context 'hex literals' do
    it 'registers an offense for uppercase prefix' do
      expect_offense(<<~RUBY)
        a = 0X1AC
            ^^^^^ Use 0x for hexadecimal literals.
        b(0XABC)
          ^^^^^ Use 0x for hexadecimal literals.
      RUBY

      expect_correction(<<~RUBY)
        a = 0x1AC
        b(0xABC)
      RUBY
    end

    it 'does not register offense for lowercase prefix' do
      expect_no_offenses('a = 0x101')
    end
  end

  context 'binary literals' do
    it 'registers an offense for uppercase prefix' do
      expect_offense(<<~RUBY)
        a = 0B10101
            ^^^^^^^ Use 0b for binary literals.
        b(0B111)
          ^^^^^ Use 0b for binary literals.
      RUBY

      expect_correction(<<~RUBY)
        a = 0b10101
        b(0b111)
      RUBY
    end

    it 'does not register offense for lowercase prefix' do
      expect_no_offenses('a = 0b101')
    end
  end

  context 'decimal literals' do
    it 'registers an offense for prefixes' do
      expect_offense(<<~RUBY)
        a = 0d1234
            ^^^^^^ Do not use prefixes for decimal literals.
        b(0D1990)
          ^^^^^^ Do not use prefixes for decimal literals.
      RUBY

      expect_correction(<<~RUBY)
        a = 1234
        b(1990)
      RUBY
    end

    it 'does not register offense for no prefix' do
      expect_no_offenses('a = 101')
    end
  end
end
