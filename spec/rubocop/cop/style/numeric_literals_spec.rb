# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::NumericLiterals, :config do
  let(:cop_config) { { 'MinDigits' => 5 } }

  it 'registers an offense for a long undelimited integer' do
    expect_offense(<<~RUBY)
      a = 12345
          ^^^^^ Use underscores(_) as thousands separator and separate every 3 digits with them.
    RUBY

    expect_correction(<<~RUBY)
      a = 12_345
    RUBY
  end

  it 'registers an offense for a float with a long undelimited integer part' do
    expect_offense(<<~RUBY)
      a = 123456.789
          ^^^^^^^^^^ Use underscores(_) as thousands separator and separate every 3 digits with them.
    RUBY

    expect_correction(<<~RUBY)
      a = 123_456.789
    RUBY
  end

  it 'accepts integers with less than three places at the end' do
    expect_no_offenses(<<~RUBY)
      a = 123_456_789_00
      b = 819_2
    RUBY
  end

  it 'registers an offense for an integer with misplaced underscore' do
    expect_offense(<<~RUBY)
      a = 123_456_78_90_00
          ^^^^^^^^^^^^^^^^ Use underscores(_) as thousands separator and separate every 3 digits with them.
      b = 1_8192
          ^^^^^^ Use underscores(_) as thousands separator and separate every 3 digits with them.
    RUBY
    expect(cop.config_to_allow_offenses).to eq('Enabled' => false)

    expect_correction(<<~RUBY)
      a = 123_456_789_000
      b = 18_192
    RUBY
  end

  it 'accepts long numbers with underscore' do
    expect_no_offenses(<<~RUBY)
      a = 123_456
      b = 123_456.55
    RUBY
  end

  it 'accepts a short integer without underscore' do
    expect_no_offenses('a = 123')
  end

  it 'does not count a leading minus sign as a digit' do
    expect_no_offenses('a = -1230')
  end

  it 'accepts short numbers without underscore' do
    expect_no_offenses(<<~RUBY)
      a = 123
      b = 123.456
    RUBY
  end

  it 'ignores non-decimal literals' do
    expect_no_offenses(<<~RUBY)
      a = 0b1010101010101
      b = 01717171717171
      c = 0xab11111111bb
    RUBY
  end

  it 'handles numeric literal with exponent' do
    expect_offense(<<~RUBY)
      a = 10e10
      b = 3e12345
      c = 12.345e3
      d = 12345e3
          ^^^^^^^ Use underscores(_) as thousands separator and separate every 3 digits with them.
    RUBY

    expect_correction(<<~RUBY)
      a = 10e10
      b = 3e12345
      c = 12.345e3
      d = 12_345e3
    RUBY
  end

  it 'autocorrects negative numbers' do
    expect_offense(<<~RUBY)
      a = -123456
          ^^^^^^^ Use underscores(_) as thousands separator and separate every 3 digits with them.
    RUBY

    expect_correction(<<~RUBY)
      a = -123_456
    RUBY
  end

  it 'autocorrects negative floating-point numbers' do
    expect_offense(<<~RUBY)
      a = -123456.78
          ^^^^^^^^^^ Use underscores(_) as thousands separator and separate every 3 digits with them.
    RUBY

    expect_correction(<<~RUBY)
      a = -123_456.78
    RUBY
  end

  it 'autocorrects numbers with spaces between leading minus and numbers' do
    expect_offense(<<~RUBY)
      a = -
          ^ Use underscores(_) as thousands separator and separate every 3 digits with them.
        12345
    RUBY

    expect_correction(<<~RUBY)
      a = -12_345
    RUBY
  end

  it 'autocorrects numeric literal with exponent and dot' do
    expect_offense(<<~RUBY)
      a = 12345.6e3
          ^^^^^^^^^ Use underscores(_) as thousands separator and separate every 3 digits with them.
    RUBY

    expect_correction(<<~RUBY)
      a = 12_345.6e3
    RUBY
  end

  it 'autocorrects numeric literal with exponent (large E) and dot' do
    expect_offense(<<~RUBY)
      a = 12345.6E3
          ^^^^^^^^^ Use underscores(_) as thousands separator and separate every 3 digits with them.
    RUBY

    expect_correction(<<~RUBY)
      a = 12_345.6E3
    RUBY
  end

  context 'strict' do
    let(:cop_config) do
      {
        'MinDigits' => 5,
        'Strict' => true
      }
    end

    it 'registers an offense for an integer with misplaced underscore' do
      expect_offense(<<~RUBY)
        a = 123_456_78_90_00
            ^^^^^^^^^^^^^^^^ Use underscores(_) as thousands separator and separate every 3 digits with them.
      RUBY

      expect_correction(<<~RUBY)
        a = 123_456_789_000
      RUBY
    end
  end
end
