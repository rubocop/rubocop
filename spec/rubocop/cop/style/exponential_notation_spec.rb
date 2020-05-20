# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::ExponentialNotation, :config do
  context 'EnforcedStyle is scientific' do
    let(:cop_config) { { 'EnforcedStyle' => 'scientific' } }

    it 'registers an offense for mantissa equal to 10' do
      expect_offense(<<~RUBY)
        10e6
        ^^^^ Use a mantissa in [1, 10[.
      RUBY
    end

    it 'registers an offense for mantissa greater than 10' do
      expect_offense(<<~RUBY)
        12.34e3
        ^^^^^^^ Use a mantissa in [1, 10[.
      RUBY
    end

    it 'registers an offense for mantissa smaller than 1' do
      expect_offense(<<~RUBY)
        0.314e1
        ^^^^^^^ Use a mantissa in [1, 10[.
      RUBY
    end

    it 'registers no offense for a regular float' do
      expect_no_offenses('120.03')
    end

    it 'registers no offense for a float smaller than 1' do
      expect_no_offenses('0.07390')
    end

    it 'registers no offense for a mantissa equal to 1' do
      expect_no_offenses('1e6')
    end

    it 'registers no offense for a mantissa between 1 and 10' do
      expect_no_offenses('3.1415e3')
    end

    it 'registers no offense for a negative mantissa' do
      expect_no_offenses('-9.999e3')
    end

    it 'registers no offense for a negative exponent' do
      expect_no_offenses('5.02e-3')
    end
  end

  context 'EnforcedStyle is engineering' do
    let(:cop_config) { { 'EnforcedStyle' => 'engineering' } }

    it 'registers an offense for exponent equal to 4' do
      expect_offense(<<~RUBY)
        10e4
        ^^^^ Use an exponent divisible by 3 and a mantissa in [0.1, 1000[.
      RUBY
    end

    it 'registers an offense for exponent equal to -2' do
      expect_offense(<<~RUBY)
        12.3e-2
        ^^^^^^^ Use an exponent divisible by 3 and a mantissa in [0.1, 1000[.
      RUBY
    end

    it 'registers an offense for mantissa smaller than 0.1' do
      expect_offense(<<~RUBY)
        0.09e9
        ^^^^^^ Use an exponent divisible by 3 and a mantissa in [0.1, 1000[.
      RUBY
    end

    it 'registers an offense for a mantissa greater than -0.1' do
      expect_offense(<<~RUBY)
        -0.09e3
        ^^^^^^^ Use an exponent divisible by 3 and a mantissa in [0.1, 1000[.
      RUBY
    end

    it 'registers an offense for mantissa smaller than -1000' do
      expect_offense(<<~RUBY)
        -1012.34e6
        ^^^^^^^^^^ Use an exponent divisible by 3 and a mantissa in [0.1, 1000[.
      RUBY
    end

    it 'registers no offense for a mantissa equal to 1' do
      expect_no_offenses('1e6')
    end

    it 'registers no offense for a regular float' do
      expect_no_offenses('120.03')
    end

    it 'registers no offense for a float smaller than 1' do
      expect_no_offenses('0.07390')
    end

    it 'registers no offense for a negative exponent' do
      expect_no_offenses('3.1415e-12')
    end

    it 'registers no offense for a negative mantissa' do
      expect_no_offenses('-999.9e3')
    end

    it 'registers no offense for a large mantissa' do
      expect_no_offenses('968.64982e12')
    end
  end

  context 'EnforcedStyle is integral' do
    let(:cop_config) { { 'EnforcedStyle' => 'integral' } }

    it 'registers an offense for decimal mantissa' do
      expect_offense(<<~RUBY)
        1.2e3
        ^^^^^ Use an integer as mantissa, without trailing zero.
      RUBY
    end

    it 'registers an offense for mantissa divisible by 10' do
      expect_offense(<<~RUBY)
        120e-4
        ^^^^^^ Use an integer as mantissa, without trailing zero.
      RUBY
    end

    it 'registers no offense for a regular float' do
      expect_no_offenses('120.03')
    end

    it 'registers no offense for a float smaller than 1' do
      expect_no_offenses('0.07390')
    end

    it 'registers no offense for an integral mantissa' do
      expect_no_offenses('7652e7')
    end

    it 'registers no offense for negative mantissa' do
      expect_no_offenses('-84e7')
    end

    it 'registers no offense for negative exponent' do
      expect_no_offenses('84e-7')
    end
  end
end
