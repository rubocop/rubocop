# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::NumberConversion, :config do
  context 'registers an offense' do
    it 'when using `#to_i`' do
      expect_offense(<<~RUBY)
        "10".to_i
        ^^^^^^^^^ Replace unsafe number conversion with number class parsing, instead of using `"10".to_i`, use stricter `Integer("10", 10)`.
      RUBY

      expect_correction(<<~RUBY)
        Integer("10", 10)
      RUBY
    end

    it 'when using `#to_f`' do
      expect_offense(<<~RUBY)
        "10.2".to_f
        ^^^^^^^^^^^ Replace unsafe number conversion with number class parsing, instead of using `"10.2".to_f`, use stricter `Float("10.2")`.
      RUBY

      expect_correction(<<~RUBY)
        Float("10.2")
      RUBY
    end

    it 'when using `#to_c`' do
      expect_offense(<<~RUBY)
        "10".to_c
        ^^^^^^^^^ Replace unsafe number conversion with number class parsing, instead of using `"10".to_c`, use stricter `Complex("10")`.
      RUBY

      expect_correction(<<~RUBY)
        Complex("10")
      RUBY
    end

    it 'when using `#to_r`' do
      expect_offense(<<~RUBY)
        "1/3".to_r
        ^^^^^^^^^^ Replace unsafe number conversion with number class parsing, instead of using `"1/3".to_r`, use stricter `Rational("1/3")`.
      RUBY

      expect_correction(<<~RUBY)
        Rational("1/3")
      RUBY
    end

    it 'when using `#to_i` for number literals' do
      expect_no_offenses(<<~RUBY)
        42.to_i
        42.0.to_i
      RUBY
    end

    it 'when using `#to_f` for number literals' do
      expect_no_offenses(<<~RUBY)
        42.to_f
        42.0.to_f
      RUBY
    end

    it 'when using `#to_c` for number literals' do
      expect_no_offenses(<<~RUBY)
        42.to_c
        42.0.to_c
      RUBY
    end

    it 'when using `#to_r` for number literals' do
      expect_no_offenses(<<~RUBY)
        42.to_r
        42.0.to_r
      RUBY
    end

    it 'when `#to_i` called on a variable' do
      expect_offense(<<~RUBY)
        string_value = '10'
        string_value.to_i
        ^^^^^^^^^^^^^^^^^ Replace unsafe number conversion with number class parsing, instead of using `string_value.to_i`, use stricter `Integer(string_value, 10)`.
      RUBY

      expect_correction(<<~RUBY)
        string_value = '10'
        Integer(string_value, 10)
      RUBY
    end

    it 'when `#to_i` called on a hash value' do
      expect_offense(<<~RUBY)
        params = { id: 10 }
        params[:id].to_i
        ^^^^^^^^^^^^^^^^ Replace unsafe number conversion with number class parsing, instead of using `params[:id].to_i`, use stricter `Integer(params[:id], 10)`.
      RUBY

      expect_correction(<<~RUBY)
        params = { id: 10 }
        Integer(params[:id], 10)
      RUBY
    end

    it 'when `#to_i` called on a variable on a array' do
      expect_offense(<<~RUBY)
        args = [1,2,3]
        args[0].to_i
        ^^^^^^^^^^^^ Replace unsafe number conversion with number class parsing, instead of using `args[0].to_i`, use stricter `Integer(args[0], 10)`.
      RUBY

      expect_correction(<<~RUBY)
        args = [1,2,3]
        Integer(args[0], 10)
      RUBY
    end

    it 'when `#to_i` called on a variable on a hash' do
      expect_offense(<<~RUBY)
        params[:field].to_i
        ^^^^^^^^^^^^^^^^^^^ Replace unsafe number conversion with number class parsing, instead of using `params[:field].to_i`, use stricter `Integer(params[:field], 10)`.
      RUBY

      expect_correction(<<~RUBY)
        Integer(params[:field], 10)
      RUBY
    end
  end

  context 'does not register an offense' do
    it 'when using Integer() with integer' do
      expect_no_offenses(<<~RUBY)
        Integer(10)
      RUBY
    end

    it 'when using Float()' do
      expect_no_offenses(<<~RUBY)
        Float('10')
      RUBY
    end

    it 'when using Complex()' do
      expect_no_offenses(<<~RUBY)
        Complex('10')
      RUBY
    end

    it 'when `#to_i` called without a receiver' do
      expect_no_offenses(<<~RUBY)
        to_i
      RUBY
    end

    it 'when `:to_f` is one of multiple method arguments' do
      expect_no_offenses(<<~RUBY)
        delegate :to_f, to: :description, allow_nil: true
      RUBY
    end
  end

  context 'to_method in symbol form' do
    it 'registers offense and autocorrects' do
      expect_offense(<<~RUBY)
        "1,2,3,foo,5,6,7,8".split(',').map(&:to_i)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Replace unsafe number conversion with number class parsing, instead of using `&:to_i`, use stricter `{ |i| Integer(i, 10) }`.
      RUBY

      expect_correction(<<~RUBY)
        "1,2,3,foo,5,6,7,8".split(',').map { |i| Integer(i, 10) }
      RUBY
    end

    it 'registers offense and autocorrects without parentheses' do
      expect_offense(<<~RUBY)
        "1,2,3,foo,5,6,7,8".split(',').map &:to_i
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Replace unsafe number conversion with number class parsing, instead of using `&:to_i`, use stricter `{ |i| Integer(i, 10) }`.
      RUBY

      expect_correction(<<~RUBY)
        "1,2,3,foo,5,6,7,8".split(',').map { |i| Integer(i, 10) }
      RUBY
    end

    it 'registers offense with try' do
      expect_offense(<<~RUBY)
        "foo".try(:to_f)
        ^^^^^^^^^^^^^^^^ Replace unsafe number conversion with number class parsing, instead of using `:to_f`, use stricter `{ |i| Float(i) }`.
      RUBY

      expect_correction(<<~RUBY)
        "foo".try { |i| Float(i) }
      RUBY
    end

    it 'registers an offense when using nested number conversion methods' do
      expect_offense(<<~RUBY)
        var.to_i.to_f
        ^^^^^^^^ Replace unsafe number conversion with number class parsing, instead of using `var.to_i`, use stricter `Integer(var, 10)`.
      RUBY

      expect_correction(<<~RUBY)
        Integer(var, 10).to_f
      RUBY
    end

    it 'does not register an offense when using `Integer` constructor' do
      expect_no_offenses(<<~RUBY)
        Integer(var, 10).to_f
      RUBY
    end

    it 'does not register an offense when using `Float` constructor' do
      expect_no_offenses(<<~RUBY)
        Float(var).to_i
      RUBY
    end

    it 'does not register an offense when using `Complex` constructor' do
      expect_no_offenses(<<~RUBY)
        Complex(var).to_f
      RUBY
    end

    it 'registers offense with send' do
      expect_offense(<<~RUBY)
        "foo".send(:to_c)
        ^^^^^^^^^^^^^^^^^ Replace unsafe number conversion with number class parsing, instead of using `:to_c`, use stricter `{ |i| Complex(i) }`.
      RUBY

      expect_correction(<<~RUBY)
        "foo".send { |i| Complex(i) }
      RUBY
    end
  end

  context 'IgnoredClasses' do
    let(:cop_config) { { 'IgnoredClasses' => %w[Time DateTime] } }

    it 'when using Time' do
      expect_no_offenses(<<~RUBY)
        Time.now.to_i
        Time.now.to_f
        Time.strptime("2000-10-31", "%Y-%m-%d").to_i
        Time.httpdate("Thu, 06 Oct 2011 02:26:12 GMT").to_f
        Time.now.to_datetime.to_i
      RUBY
    end

    it 'when using DateTime' do
      expect_no_offenses(<<~RUBY)
        DateTime.new(2012, 8, 29, 22, 35, 0).to_i
        DateTime.new(2012, 8, 29, 22, 35, 0).to_f
      RUBY
    end

    it 'when using Time/DateTime with multiple method calls' do
      expect_no_offenses(<<~RUBY)
        Time.now.to_datetime.to_i
        DateTime.civil(2005, 2, 21, 10, 11, 12, Rational(-6, 24)).utc.to_f
        Time.zone.now.to_datetime.to_f
        DateTime.new(2012, 8, 29, 22, 35, 0)
                .change(day: 1)
                .change(month: 1)
                .change(year: 2020)
                .to_i
      RUBY
    end
  end

  context 'AllowedMethods' do
    let(:cop_config) { { 'AllowedMethods' => %w[minutes] } }

    it 'does not register an offense for an allowed method' do
      expect_no_offenses(<<~RUBY)
        10.minutes.to_i
      RUBY
    end

    it 'registers an offense for other methods' do
      expect_offense(<<~RUBY)
        10.hours.to_i
        ^^^^^^^^^^^^^ Replace unsafe number conversion with number class parsing, instead of using `10.hours.to_i`, use stricter `Integer(10.hours, 10)`.
      RUBY
    end
  end

  context 'AllowedPatterns' do
    let(:cop_config) { { 'AllowedPatterns' => [/min/] } }

    it 'does not register an offense for an allowed method' do
      expect_no_offenses(<<~RUBY)
        10.minutes.to_i
      RUBY
    end

    it 'registers an offense for other methods' do
      expect_offense(<<~RUBY)
        10.hours.to_i
        ^^^^^^^^^^^^^ Replace unsafe number conversion with number class parsing, instead of using `10.hours.to_i`, use stricter `Integer(10.hours, 10)`.
      RUBY
    end
  end
end
