# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::FileNull, :config do
  it 'does not register an offense for an empty string' do
    expect_no_offenses(<<~RUBY)
      ""
    RUBY
  end

  it 'does not register an offense when there is an invalid byte sequence error' do
    expect_no_offenses(<<~'RUBY')
      "\xa4"
    RUBY
  end

  it 'registers an offense and corrects when the entire string is `/dev/null`' do
    expect_offense(<<~RUBY)
      path = '/dev/null'
             ^^^^^^^^^^^ Use `File::NULL` instead of `/dev/null`.
    RUBY

    expect_correction(<<~RUBY)
      path = File::NULL
    RUBY
  end

  it "registers an offense and corrects when the entire string is `NUL` or '/dev/null'" do
    expect_offense(<<~RUBY)
      CONST = '/dev/null'
              ^^^^^^^^^^^ Use `File::NULL` instead of `/dev/null`.
      path = 'NUL'
             ^^^^^ Use `File::NULL` instead of `NUL`.
    RUBY

    expect_correction(<<~RUBY)
      CONST = File::NULL
      path = File::NULL
    RUBY
  end

  it "does not register an offense when the entire string is `NUL` without '/dev/null'" do
    expect_no_offenses(<<~RUBY)
      path = 'NUL'
    RUBY
  end

  it "registers an offense and corrects when the entire string is `NUL:` or '/dev/null'" do
    expect_offense(<<~RUBY)
      path = cond ? '/dev/null' : 'NUL:'
                    ^^^^^^^^^^^ Use `File::NULL` instead of `/dev/null`.
                                  ^^^^^^ Use `File::NULL` instead of `NUL:`.
    RUBY

    # Different cops will detect duplication of the branch bodies.
    expect_correction(<<~RUBY)
      path = cond ? File::NULL : File::NULL
    RUBY
  end

  it "registers an offense when the entire string is `NUL:` without '/dev/null'" do
    expect_offense(<<~RUBY)
      path = 'NUL:'
             ^^^^^^ Use `File::NULL` instead of `NUL:`.
    RUBY

    expect_correction(<<~RUBY)
      path = File::NULL
    RUBY
  end

  it 'is case insensitive' do
    expect_offense(<<~RUBY)
      file = "nul"
             ^^^^^ Use `File::NULL` instead of `nul`.
      path = "/DEV/NULL"
             ^^^^^^^^^^^ Use `File::NULL` instead of `/DEV/NULL`.
    RUBY

    expect_correction(<<~RUBY)
      file = File::NULL
      path = File::NULL
    RUBY
  end

  it 'does not register an offense for a substring' do
    expect_no_offenses(<<~RUBY)
      'the null devices are /dev/null on Unix and NUL on Windows'
    RUBY
  end

  it 'does not register an offense for a string within an array' do
    expect_no_offenses(<<~RUBY)
      ['/dev/null', 'NUL']
    RUBY
  end

  it 'does not register an offense for a string within %w[]' do
    expect_no_offenses(<<~RUBY)
      %w[/dev/null NUL]
    RUBY
  end

  it 'does not register an offense for a hash key' do
    expect_no_offenses(<<~RUBY)
      { "/dev/null" => true, "nul" => false }
    RUBY
  end

  it 'does not register an offense for a hash value' do
    expect_no_offenses(<<~RUBY)
      { unix: "/dev/null", windows: "nul" }
    RUBY
  end
end
