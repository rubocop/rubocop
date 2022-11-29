# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::DeprecatedConstants, :config do
  let(:cop_config) do
    {
      'DeprecatedConstants' => {
        'NIL' => { 'Alternative' => 'nil', 'DeprecatedVersion' => '2.4' },
        'TRUE' => { 'Alternative' => 'true', 'DeprecatedVersion' => '2.4' },
        'FALSE' => { 'Alternative' => 'false', 'DeprecatedVersion' => '2.4' },
        'Net::HTTPServerException' => {
          'Alternative' => 'Net::HTTPClientException', 'DeprecatedVersion' => '2.6'
        },
        'Random::DEFAULT' => { 'Alternative' => 'Random.new', 'DeprecatedVersion' => '3.0' },
        'Struct::Group' => { 'Alternative' => 'Etc::Group', 'DeprecatedVersion' => '3.0' },
        'Struct::Passwd' => { 'Alternative' => 'Etc::Passwd', 'DeprecatedVersion' => '3.0' },
        'Triple::Nested::Constant' => { 'Alternative' => 'Value', 'DeprecatedVersion' => '2.4' },
        'Have::No::Alternative' => { 'DeprecatedVersion' => '2.4' },
        'Have::No::DeprecatedVersion' => { 'Alternative' => 'Value' }
      }
    }
  end

  it 'registers and corrects an offense when using `NIL`' do
    expect_offense(<<~RUBY)
      NIL
      ^^^ Use `nil` instead of `NIL`, deprecated since Ruby 2.4.
    RUBY

    expect_correction(<<~RUBY)
      nil
    RUBY
  end

  it 'registers and corrects an offense when using `TRUE`' do
    expect_offense(<<~RUBY)
      TRUE
      ^^^^ Use `true` instead of `TRUE`, deprecated since Ruby 2.4.
    RUBY

    expect_correction(<<~RUBY)
      true
    RUBY
  end

  it 'registers and corrects an offense when using `FALSE`' do
    expect_offense(<<~RUBY)
      FALSE
      ^^^^^ Use `false` instead of `FALSE`, deprecated since Ruby 2.4.
    RUBY

    expect_correction(<<~RUBY)
      false
    RUBY
  end

  context 'Ruby <= 2.5', :ruby25 do
    it 'does not register an offense when using `Net::HTTPServerException`' do
      expect_no_offenses(<<~RUBY)
        Net::HTTPServerException
      RUBY
    end
  end

  context 'Ruby >= 2.6', :ruby26 do
    it 'registers and corrects an offense when using `Net::HTTPServerException`' do
      expect_offense(<<~RUBY)
        Net::HTTPServerException
        ^^^^^^^^^^^^^^^^^^^^^^^^ Use `Net::HTTPClientException` instead of `Net::HTTPServerException`, deprecated since Ruby 2.6.
      RUBY

      expect_correction(<<~RUBY)
        Net::HTTPClientException
      RUBY
    end
  end

  context 'Ruby <= 2.7', :ruby27 do
    it 'does not register an offense when using `Random::DEFAULT`' do
      expect_no_offenses(<<~RUBY)
        Random::DEFAULT
      RUBY
    end

    it 'does not register an offense when using `Struct::Group`' do
      expect_no_offenses(<<~RUBY)
        Struct::Group
      RUBY
    end

    it 'does not register an offense when using `Struct::Passwd`' do
      expect_no_offenses(<<~RUBY)
        Struct::Passwd
      RUBY
    end
  end

  context 'Ruby >= 3.0', :ruby30 do
    it 'registers and corrects an offense when using `Random::DEFAULT`' do
      expect_offense(<<~RUBY)
        Random::DEFAULT
        ^^^^^^^^^^^^^^^ Use `Random.new` instead of `Random::DEFAULT`, deprecated since Ruby 3.0.
      RUBY

      expect_correction(<<~RUBY)
        Random.new
      RUBY
    end

    it 'registers and corrects an offense when using `::Random::DEFAULT`' do
      expect_offense(<<~RUBY)
        ::Random::DEFAULT
        ^^^^^^^^^^^^^^^^^ Use `Random.new` instead of `::Random::DEFAULT`, deprecated since Ruby 3.0.
      RUBY

      expect_correction(<<~RUBY)
        Random.new
      RUBY
    end

    it 'registers and corrects an offense when using `Struct::Group`' do
      expect_offense(<<~RUBY)
        Struct::Group
        ^^^^^^^^^^^^^ Use `Etc::Group` instead of `Struct::Group`, deprecated since Ruby 3.0.
      RUBY

      expect_correction(<<~RUBY)
        Etc::Group
      RUBY
    end

    it 'registers and corrects an offense when using `Struct::Passwd`' do
      expect_offense(<<~RUBY)
        Struct::Passwd
        ^^^^^^^^^^^^^^ Use `Etc::Passwd` instead of `Struct::Passwd`, deprecated since Ruby 3.0.
      RUBY

      expect_correction(<<~RUBY)
        Etc::Passwd
      RUBY
    end
  end

  it 'registers and corrects an offense when using `::NIL`' do
    expect_offense(<<~RUBY)
      ::NIL
      ^^^^^ Use `nil` instead of `::NIL`, deprecated since Ruby 2.4.
    RUBY

    expect_correction(<<~RUBY)
      nil
    RUBY
  end

  it 'registers and corrects an offense when using `::TRUE`' do
    expect_offense(<<~RUBY)
      ::TRUE
      ^^^^^^ Use `true` instead of `::TRUE`, deprecated since Ruby 2.4.
    RUBY

    expect_correction(<<~RUBY)
      true
    RUBY
  end

  it 'registers and corrects an offense when using `::FALSE`' do
    expect_offense(<<~RUBY)
      ::FALSE
      ^^^^^^^ Use `false` instead of `::FALSE`, deprecated since Ruby 2.4.
    RUBY

    expect_correction(<<~RUBY)
      false
    RUBY
  end

  it 'registers and corrects an offense when using `::Triple::Nested::Constant`' do
    expect_offense(<<~RUBY)
      ::Triple::Nested::Constant
      ^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `Value` instead of `::Triple::Nested::Constant`, deprecated since Ruby 2.4.
    RUBY

    expect_correction(<<~RUBY)
      Value
    RUBY
  end

  it 'registers and corrects an offense when using deprecated methods that have no alternative' do
    expect_offense(<<~RUBY)
      Have::No::Alternative
      ^^^^^^^^^^^^^^^^^^^^^ Do not use `Have::No::Alternative`, deprecated since Ruby 2.4.
    RUBY

    expect_no_corrections
  end

  it 'registers and corrects an offense when using deprecated methods that have no deprecated version' do
    expect_offense(<<~RUBY)
      Have::No::DeprecatedVersion
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `Value` instead of `Have::No::DeprecatedVersion`.
    RUBY

    expect_correction(<<~RUBY)
      Value
    RUBY
  end

  it 'does not register an offense when not using deprecated constant' do
    expect_no_offenses(<<~RUBY)
      Foo::TRUE
    RUBY
  end

  it 'does not register an offense when using `__ENCODING__' do
    expect_no_offenses(<<~RUBY)
      __ENCODING__
    RUBY
  end
end
