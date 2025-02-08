# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::SuppressedExceptionInNumberConversion, :config, :ruby26 do
  it 'registers an offense when using `Integer(arg) rescue nil`' do
    expect_offense(<<~RUBY)
      Integer(arg) rescue nil
      ^^^^^^^^^^^^^^^^^^^^^^^ Use `Integer(arg, exception: false)` instead.
    RUBY

    expect_correction(<<~RUBY)
      Integer(arg, exception: false)
    RUBY
  end

  it 'registers an offense when using `Integer(arg, base) rescue nil`' do
    expect_offense(<<~RUBY)
      Integer(arg, base) rescue nil
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `Integer(arg, base, exception: false)` instead.
    RUBY

    expect_correction(<<~RUBY)
      Integer(arg, base, exception: false)
    RUBY
  end

  it 'registers an offense when using `Float(arg) rescue nil`' do
    expect_offense(<<~RUBY)
      Float(arg) rescue nil
      ^^^^^^^^^^^^^^^^^^^^^ Use `Float(arg, exception: false)` instead.
    RUBY

    expect_correction(<<~RUBY)
      Float(arg, exception: false)
    RUBY
  end

  it 'registers an offense when using `BigDecimal(s) rescue nil`' do
    expect_offense(<<~RUBY)
      BigDecimal(s) rescue nil
      ^^^^^^^^^^^^^^^^^^^^^^^^ Use `BigDecimal(s, exception: false)` instead.
    RUBY

    expect_correction(<<~RUBY)
      BigDecimal(s, exception: false)
    RUBY
  end

  it 'registers an offense when using `BigDecimal(s, n) rescue nil`' do
    expect_offense(<<~RUBY)
      BigDecimal(s, n) rescue nil
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `BigDecimal(s, n, exception: false)` instead.
    RUBY

    expect_correction(<<~RUBY)
      BigDecimal(s, n, exception: false)
    RUBY
  end

  it 'registers an offense when using `Complex(s) rescue nil`' do
    expect_offense(<<~RUBY)
      Complex(s) rescue nil
      ^^^^^^^^^^^^^^^^^^^^^ Use `Complex(s, exception: false)` instead.
    RUBY

    expect_correction(<<~RUBY)
      Complex(s, exception: false)
    RUBY
  end

  it 'registers an offense when using `Complex(r, i) rescue nil`' do
    expect_offense(<<~RUBY)
      Complex(r, i) rescue nil
      ^^^^^^^^^^^^^^^^^^^^^^^^ Use `Complex(r, i, exception: false)` instead.
    RUBY

    expect_correction(<<~RUBY)
      Complex(r, i, exception: false)
    RUBY
  end

  it 'registers an offense when using `Rational(x) rescue nil`' do
    expect_offense(<<~RUBY)
      Rational(x) rescue nil
      ^^^^^^^^^^^^^^^^^^^^^^ Use `Rational(x, exception: false)` instead.
    RUBY

    expect_correction(<<~RUBY)
      Rational(x, exception: false)
    RUBY
  end

  it 'registers an offense when using `Rational(x, y) rescue nil`' do
    expect_offense(<<~RUBY)
      Rational(x, y) rescue nil
      ^^^^^^^^^^^^^^^^^^^^^^^^^ Use `Rational(x, y, exception: false)` instead.
    RUBY

    expect_correction(<<~RUBY)
      Rational(x, y, exception: false)
    RUBY
  end

  it 'registers an offense when using `Integer(arg)` with `rescue nil` in `begin`' do
    expect_offense(<<~RUBY)
      begin
      ^^^^^ Use `Integer(arg, exception: false)` instead.
        Integer(arg)
      rescue
        nil
      end
    RUBY

    expect_correction(<<~RUBY)
      Integer(arg, exception: false)
    RUBY
  end

  it 'registers an offense when using `Integer(arg)` with `rescue ArgumentError` in `begin`' do
    expect_offense(<<~RUBY)
      begin
      ^^^^^ Use `Integer(arg, exception: false)` instead.
        Integer(arg)
      rescue ArgumentError
        nil
      end
    RUBY

    expect_correction(<<~RUBY)
      Integer(arg, exception: false)
    RUBY
  end

  it 'registers an offense when using `Integer(arg)` with `rescue ArgumentError, TypeError` in `begin`' do
    expect_offense(<<~RUBY)
      begin
      ^^^^^ Use `Integer(arg, exception: false)` instead.
        Integer(arg)
      rescue ArgumentError, TypeError
        nil
      end
    RUBY

    expect_correction(<<~RUBY)
      Integer(arg, exception: false)
    RUBY
  end

  it 'registers an offense when using `Integer(arg)` with `rescue ::ArgumentError, ::TypeError` in `begin`' do
    expect_offense(<<~RUBY)
      begin
      ^^^^^ Use `Integer(arg, exception: false)` instead.
        Integer(arg)
      rescue ::ArgumentError, ::TypeError
        nil
      end
    RUBY

    expect_correction(<<~RUBY)
      Integer(arg, exception: false)
    RUBY
  end

  it 'does not register an offense when using `Integer(arg)` with `rescue CustomError` in `begin`' do
    expect_no_offenses(<<~RUBY)
      begin
        Integer(arg)
      rescue CustomError
        nil
      end
    RUBY
  end

  it 'registers an offense when using `Integer(arg)` with `rescue` with implicit `nil` in `begin`' do
    expect_offense(<<~RUBY)
      begin
      ^^^^^ Use `Integer(arg, exception: false)` instead.
        Integer(arg)
      rescue
      end
    RUBY

    expect_correction(<<~RUBY)
      Integer(arg, exception: false)
    RUBY
  end

  it 'registers an offense when using `Kernel::Integer(arg) rescue nil`' do
    expect_offense(<<~RUBY)
      Kernel::Integer(arg) rescue nil
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `Kernel::Integer(arg, exception: false)` instead.
    RUBY

    expect_correction(<<~RUBY)
      Kernel::Integer(arg, exception: false)
    RUBY
  end

  it 'registers an offense when using `::Kernel::Integer(arg) rescue nil`' do
    expect_offense(<<~RUBY)
      ::Kernel::Integer(arg) rescue nil
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `::Kernel::Integer(arg, exception: false)` instead.
    RUBY

    expect_correction(<<~RUBY)
      ::Kernel::Integer(arg, exception: false)
    RUBY
  end

  it 'registers an offense when using `::Kernel&.Integer(arg) rescue nil`' do
    expect_offense(<<~RUBY)
      ::Kernel&.Integer(arg) rescue nil
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `::Kernel&.Integer(arg, exception: false)` instead.
    RUBY

    expect_correction(<<~RUBY)
      ::Kernel&.Integer(arg, exception: false)
    RUBY
  end

  it 'registers an offense when using `::Kernel&.Float(arg) rescue nil`' do
    expect_offense(<<~RUBY)
      ::Kernel&.Float(arg) rescue nil
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `::Kernel&.Float(arg, exception: false)` instead.
    RUBY

    expect_correction(<<~RUBY)
      ::Kernel&.Float(arg, exception: false)
    RUBY
  end

  it 'does not register an offense when using `Integer(42, exception: false)`' do
    expect_no_offenses(<<~RUBY)
      Integer(42, exception: false)
    RUBY
  end

  it 'does not register an offense when using `Integer(arg) rescue 42`' do
    expect_no_offenses(<<~RUBY)
      Integer(arg) rescue 42
    RUBY
  end

  it 'does not register an offense when using `Integer(arg)` with `rescue 42` in `begin`' do
    expect_no_offenses(<<~RUBY)
      begin
        Integer(arg)
      rescue
        42
      end
    RUBY
  end

  it 'does not register an offense when using `Integer(arg)` with `rescue nil else 42` in `begin`' do
    expect_no_offenses(<<~RUBY)
      begin
        Integer(arg)
      rescue
        nil
      else
        42
      end
    RUBY
  end

  it 'does not register an offense when using `Integer(arg)` and `do_something` with `rescue 42` in `begin`' do
    expect_no_offenses(<<~RUBY)
      begin
        Integer(arg)
        do_something
      rescue
        42
      end
    RUBY
  end

  it 'does not register an offense when using `Float(arg, unexpected_arg) rescue nil`' do
    expect_no_offenses(<<~RUBY)
      Float(arg, unexpected_arg) rescue nil
    RUBY
  end

  context '>= Ruby 2.5', :ruby25, unsupported_on: :prism do
    it 'does not register an offense when using `Integer(arg) rescue nil`' do
      expect_no_offenses(<<~RUBY)
        Integer(arg) rescue nil
      RUBY
    end
  end
end
