# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::NumberConversion do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  context 'registers an offense' do
    it 'when using `#to_i`' do
      expect_offense(<<~RUBY)
        "10".to_i
        ^^^^^^^^^ Replace unsafe number conversion with number class parsing, instead of using "10".to_i, use stricter Integer("10", 10).
      RUBY

      expect_correction(<<~RUBY)
        Integer("10", 10)
      RUBY
    end

    it 'when using `#to_i` for integer' do
      expect_offense(<<~RUBY)
        10.to_i
        ^^^^^^^ Replace unsafe number conversion with number class parsing, instead of using 10.to_i, use stricter Integer(10, 10).
      RUBY

      expect_correction(<<~RUBY)
        Integer(10, 10)
      RUBY
    end

    it 'when using `#to_f`' do
      expect_offense(<<~RUBY)
        "10.2".to_f
        ^^^^^^^^^^^ Replace unsafe number conversion with number class parsing, instead of using "10.2".to_f, use stricter Float("10.2").
      RUBY

      expect_correction(<<~RUBY)
        Float("10.2")
      RUBY
    end

    it 'when using `#to_c`' do
      expect_offense(<<~RUBY)
        "10".to_c
        ^^^^^^^^^ Replace unsafe number conversion with number class parsing, instead of using "10".to_c, use stricter Complex("10").
      RUBY

      expect_correction(<<~RUBY)
        Complex("10")
      RUBY
    end

    it 'when `#to_i` called on a variable' do
      expect_offense(<<~RUBY)
        string_value = '10'
        string_value.to_i
        ^^^^^^^^^^^^^^^^^ Replace unsafe number conversion with number class parsing, instead of using string_value.to_i, use stricter Integer(string_value, 10).
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
        ^^^^^^^^^^^^^^^^ Replace unsafe number conversion with number class parsing, instead of using params[:id].to_i, use stricter Integer(params[:id], 10).
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
        ^^^^^^^^^^^^ Replace unsafe number conversion with number class parsing, instead of using args[0].to_i, use stricter Integer(args[0], 10).
      RUBY

      expect_correction(<<~RUBY)
        args = [1,2,3]
        Integer(args[0], 10)
      RUBY
    end

    it 'when `#to_i` called on a variable on a hash' do
      expect_offense(<<~RUBY)
        params[:field].to_i
        ^^^^^^^^^^^^^^^^^^^ Replace unsafe number conversion with number class parsing, instead of using params[:field].to_i, use stricter Integer(params[:field], 10).
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

    it 'when `#to_i` called without a receiver' do
      expect_no_offenses(<<~RUBY)
        to_i
      RUBY
    end
  end
end
