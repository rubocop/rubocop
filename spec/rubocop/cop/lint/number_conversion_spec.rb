# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::NumberConversion do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  context 'registers an offense' do
    it 'when using `#to_i`' do
      expect_offense(<<-RUBY.strip_indent)
        "10".to_i
        ^^^^^^^^^ Replace unsafe number conversion with number class parsing, instead of using "10".to_i, use stricter Integer("10").
      RUBY
    end

    it 'when using `#to_i` for integer' do
      expect_offense(<<-RUBY.strip_indent)
        10.to_i
        ^^^^^^^ Replace unsafe number conversion with number class parsing, instead of using 10.to_i, use stricter Integer(10).
      RUBY
    end

    it 'when using `#to_f`' do
      expect_offense(<<-RUBY.strip_indent)
        "10.2".to_f
        ^^^^^^^^^^^ Replace unsafe number conversion with number class parsing, instead of using "10.2".to_f, use stricter Float("10.2").
      RUBY
    end

    it 'when using `#to_c`' do
      expect_offense(<<-RUBY.strip_indent)
        "10".to_c
        ^^^^^^^^^ Replace unsafe number conversion with number class parsing, instead of using "10".to_c, use stricter Complex("10").
      RUBY
    end

    it 'when `#to_i` called on a variable' do
      expect_offense(<<-RUBY.strip_indent)
        string_value = '10'
        string_value.to_i
        ^^^^^^^^^^^^^^^^^ Replace unsafe number conversion with number class parsing, instead of using string_value.to_i, use stricter Integer(string_value).
      RUBY
    end

    it 'when `#to_i` called on a hash value' do
      expect_offense(<<-RUBY.strip_indent)
        params = { id: 10 }
        params[:id].to_i
        ^^^^^^^^^^^^^^^^ Replace unsafe number conversion with number class parsing, instead of using params[:id].to_i, use stricter Integer(params[:id]).
      RUBY
    end

    it 'when `#to_i` called on a variable on a array' do
      expect_offense(<<-RUBY.strip_indent)
        args = [1,2,3]
        args[0].to_i
        ^^^^^^^^^^^^ Replace unsafe number conversion with number class parsing, instead of using args[0].to_i, use stricter Integer(args[0]).
      RUBY
    end
  end

  context 'does not register an offense' do
    it 'when using Integer() with integer' do
      expect_no_offenses(<<-RUBY.strip_indent)
        Integer(10)
      RUBY
    end

    it 'when using Float()' do
      expect_no_offenses(<<-RUBY.strip_indent)
        Float('10')
      RUBY
    end

    it 'when using Complex()' do
      expect_no_offenses(<<-RUBY.strip_indent)
        Complex('10')
      RUBY
    end
  end
end
