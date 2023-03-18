# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::FormatString, :config do
  context 'when enforced style is sprintf' do
    let(:cop_config) { { 'EnforcedStyle' => 'sprintf' } }

    it 'registers an offense for a string followed by something' do
      expect_offense(<<~RUBY)
        puts "%d" % 10
                  ^ Favor `sprintf` over `String#%`.
      RUBY

      expect_correction(<<~RUBY)
        puts sprintf("%d", 10)
      RUBY
    end

    it 'registers an offense for something followed by an array' do
      expect_offense(<<~RUBY)
        puts x % [10, 11]
               ^ Favor `sprintf` over `String#%`.
      RUBY

      expect_correction(<<~RUBY)
        puts sprintf(x, 10, 11)
      RUBY
    end

    it 'registers an offense for String#% with a hash argument' do
      expect_offense(<<~RUBY)
        puts x % { a: 10, b: 11 }
               ^ Favor `sprintf` over `String#%`.
      RUBY

      expect_correction(<<~RUBY)
        puts sprintf(x, a: 10, b: 11)
      RUBY
    end

    it 'registers an offense for variable argument but does not autocorrect' do
      expect_offense(<<~RUBY)
        puts "%f" % a
                  ^ Favor `sprintf` over `String#%`.
      RUBY

      expect_no_corrections
    end

    it 'registers an offense for variable argument and assignment but does not autocorrect' do
      expect_offense(<<~RUBY)
        a = something()
        puts "%d" % a
                  ^ Favor `sprintf` over `String#%`.
      RUBY

      expect_no_corrections
    end

    it 'does not register an offense for numbers' do
      expect_no_offenses('puts 10 % 4')
    end

    it 'does not register an offense for ambiguous cases' do
      expect_no_offenses('puts x % Y')
    end

    it 'works if the first operand contains embedded expressions' do
      expect_offense(<<~'RUBY')
        puts "#{x * 5} %d #{@test}" % 10
                                    ^ Favor `sprintf` over `String#%`.
      RUBY

      expect_correction(<<~'RUBY')
        puts sprintf("#{x * 5} %d #{@test}", 10)
      RUBY
    end

    it 'registers an offense for format' do
      expect_offense(<<~RUBY)
        format(something, a, b)
        ^^^^^^ Favor `sprintf` over `format`.
      RUBY

      expect_correction(<<~RUBY)
        sprintf(something, a, b)
      RUBY
    end

    it 'registers an offense for format with 2 arguments' do
      expect_offense(<<~RUBY)
        format("%X", 123)
        ^^^^^^ Favor `sprintf` over `format`.
      RUBY

      expect_correction(<<~RUBY)
        sprintf("%X", 123)
      RUBY
    end
  end

  context 'when enforced style is format' do
    let(:cop_config) { { 'EnforcedStyle' => 'format' } }

    it 'registers an offense for a string followed by something' do
      expect_offense(<<~RUBY)
        puts "%d" % 10
                  ^ Favor `format` over `String#%`.
      RUBY

      expect_correction(<<~RUBY)
        puts format("%d", 10)
      RUBY
    end

    it 'registers an offense for something followed by an array' do
      expect_offense(<<~RUBY)
        puts x % [10, 11]
               ^ Favor `format` over `String#%`.
      RUBY

      expect_correction(<<~RUBY)
        puts format(x, 10, 11)
      RUBY
    end

    it 'registers an offense for something followed by a hash' do
      expect_offense(<<~RUBY)
        puts x % { a: 10, b: 11 }
               ^ Favor `format` over `String#%`.
      RUBY

      expect_correction(<<~RUBY)
        puts format(x, a: 10, b: 11)
      RUBY
    end

    it 'registers an offense for variable argument but does not autocorrect' do
      expect_offense(<<~RUBY)
        puts "%f" % a
                  ^ Favor `format` over `String#%`.
      RUBY

      expect_no_corrections
    end

    it 'does not register an offense for numbers' do
      expect_no_offenses('puts 10 % 4')
    end

    it 'does not register an offense for ambiguous cases' do
      expect_no_offenses('puts x % Y')
    end

    it 'works if the first operand contains embedded expressions' do
      expect_offense(<<~'RUBY')
        puts "#{x * 5} %d #{@test}" % 10
                                    ^ Favor `format` over `String#%`.
      RUBY

      expect_correction(<<~'RUBY')
        puts format("#{x * 5} %d #{@test}", 10)
      RUBY
    end

    it 'registers an offense for sprintf' do
      expect_offense(<<~RUBY)
        sprintf(something, a, b)
        ^^^^^^^ Favor `format` over `sprintf`.
      RUBY

      expect_correction(<<~RUBY)
        format(something, a, b)
      RUBY
    end

    it 'registers an offense for sprintf with 2 arguments' do
      expect_offense(<<~RUBY)
        sprintf('%020d', 123)
        ^^^^^^^ Favor `format` over `sprintf`.
      RUBY

      expect_correction(<<~RUBY)
        format('%020d', 123)
      RUBY
    end

    it 'does not autocorrect String#% with variable argument and assignment' do
      expect_offense(<<~RUBY)
        a = something()
        puts "%d" % a
                  ^ Favor `format` over `String#%`.
      RUBY

      expect_no_corrections
    end
  end

  context 'when enforced style is percent' do
    let(:cop_config) { { 'EnforcedStyle' => 'percent' } }

    it 'registers an offense for format' do
      expect_offense(<<~RUBY)
        format(something, a)
        ^^^^^^ Favor `String#%` over `format`.
      RUBY

      expect_correction(<<~RUBY)
        something % a
      RUBY
    end

    it 'registers an offense for format with 3 arguments' do
      expect_offense(<<~RUBY)
        format(something, a, b)
        ^^^^^^ Favor `String#%` over `format`.
      RUBY

      expect_correction(<<~RUBY)
        something % [a, b]
      RUBY
    end

    it 'registers an offense for format with a hash argument' do
      expect_offense(<<~RUBY)
        format(something, a: 10, b: 11)
        ^^^^^^ Favor `String#%` over `format`.
      RUBY

      expect_correction(<<~RUBY)
        something % { a: 10, b: 11 }
      RUBY
    end

    it 'registers an offense for sprintf' do
      expect_offense(<<~RUBY)
        sprintf(something, a)
        ^^^^^^^ Favor `String#%` over `sprintf`.
      RUBY

      expect_correction(<<~RUBY)
        something % a
      RUBY
    end

    it 'registers an offense and corrects when using sprintf with second argument that uses an operator' do
      expect_offense(<<~RUBY)
        format(something, a + 42)
        ^^^^^^ Favor `String#%` over `format`.
      RUBY

      expect_correction(<<~RUBY)
        something % (a + 42)
      RUBY
    end

    it 'registers an offense for sprintf with 3 arguments' do
      expect_offense(<<~RUBY)
        format("%d %04x", 123, 123)
        ^^^^^^ Favor `String#%` over `format`.
      RUBY

      expect_correction(<<~RUBY)
        "%d %04x" % [123, 123]
      RUBY
    end

    it 'registers an offense for sprintf with a hash argument' do
      expect_offense(<<~RUBY)
        sprintf(something, a: 10, b: 11)
        ^^^^^^^ Favor `String#%` over `sprintf`.
      RUBY

      expect_correction(<<~RUBY)
        something % { a: 10, b: 11 }
      RUBY
    end

    it 'accepts format with 1 argument' do
      expect_no_offenses('format :xml')
    end

    it 'accepts sprintf with 1 argument' do
      expect_no_offenses('sprintf :xml')
    end

    it 'accepts format without arguments' do
      expect_no_offenses('format')
    end

    it 'accepts sprintf without arguments' do
      expect_no_offenses('sprintf')
    end

    it 'accepts String#%' do
      expect_no_offenses('puts "%d" % 10')
    end
  end
end
