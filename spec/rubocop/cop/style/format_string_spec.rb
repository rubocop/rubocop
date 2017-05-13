# frozen_string_literal: true

describe RuboCop::Cop::Style::FormatString, :config do
  subject(:cop) { described_class.new(config) }

  context 'when enforced style is sprintf' do
    let(:cop_config) { { 'EnforcedStyle' => 'sprintf' } }
    it 'registers an offense for a string followed by something' do
      expect_offense(<<-RUBY.strip_indent)
        puts "%d" % 10
                  ^ Favor `sprintf` over `String#%`.
      RUBY
    end

    it 'registers an offense for something followed by an array' do
      expect_offense(<<-RUBY.strip_indent)
        puts x % [10, 11]
               ^ Favor `sprintf` over `String#%`.
      RUBY
    end

    it 'does not register an offense for numbers' do
      expect_no_offenses('puts 10 % 4')
    end

    it 'does not register an offense for ambiguous cases' do
      expect_no_offenses('puts x % Y')
    end

    it 'works if the first operand contains embedded expressions' do
      expect_offense(<<-'RUBY'.strip_indent)
        puts "#{x * 5} %d #{@test}" % 10
                                    ^ Favor `sprintf` over `String#%`.
      RUBY
    end

    it 'registers an offense for format' do
      expect_offense(<<-RUBY.strip_indent)
        format(something, a, b)
        ^^^^^^ Favor `sprintf` over `format`.
      RUBY
    end

    it 'registers an offense for format with 2 arguments' do
      expect_offense(<<-RUBY.strip_indent)
        format("%X", 123)
        ^^^^^^ Favor `sprintf` over `format`.
      RUBY
    end
  end

  context 'when enforced style is format' do
    let(:cop_config) { { 'EnforcedStyle' => 'format' } }

    it 'registers an offense for a string followed by something' do
      expect_offense(<<-RUBY.strip_indent)
        puts "%d" % 10
                  ^ Favor `format` over `String#%`.
      RUBY
    end

    it 'registers an offense for something followed by an array' do
      expect_offense(<<-RUBY.strip_indent)
        puts x % [10, 11]
               ^ Favor `format` over `String#%`.
      RUBY
    end

    it 'registers an offense for something followed by a hash' do
      expect_offense(<<-RUBY.strip_indent)
        puts x % { a: 10, b: 11 }
               ^ Favor `format` over `String#%`.
      RUBY
    end

    it 'does not register an offense for numbers' do
      expect_no_offenses('puts 10 % 4')
    end

    it 'does not register an offense for ambiguous cases' do
      expect_no_offenses('puts x % Y')
    end

    it 'works if the first operand contains embedded expressions' do
      expect_offense(<<-'RUBY'.strip_indent)
        puts "#{x * 5} %d #{@test}" % 10
                                    ^ Favor `format` over `String#%`.
      RUBY
    end

    it 'registers an offense for sprintf' do
      expect_offense(<<-RUBY.strip_indent)
        sprintf(something, a, b)
        ^^^^^^^ Favor `format` over `sprintf`.
      RUBY
    end

    it 'registers an offense for sprintf with 2 arguments' do
      expect_offense(<<-RUBY.strip_indent)
        sprintf('%020d', 123)
        ^^^^^^^ Favor `format` over `sprintf`.
      RUBY
    end
  end

  context 'when enforced style is percent' do
    let(:cop_config) { { 'EnforcedStyle' => 'percent' } }

    it 'registers an offense for format' do
      expect_offense(<<-RUBY.strip_indent)
        format(something, a, b)
        ^^^^^^ Favor `String#%` over `format`.
      RUBY
    end

    it 'registers an offense for sprintf' do
      expect_offense(<<-RUBY.strip_indent)
        sprintf(something, a, b)
        ^^^^^^^ Favor `String#%` over `sprintf`.
      RUBY
    end

    it 'registers an offense for sprintf with 3 arguments' do
      expect_offense(<<-RUBY.strip_indent)
        format("%d %04x", 123, 123)
        ^^^^^^ Favor `String#%` over `format`.
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
