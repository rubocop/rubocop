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

    it 'auto-corrects format' do
      corrected = autocorrect_source('format(something, a, b)')
      expect(corrected).to eq 'sprintf(something, a, b)'
    end

    it 'auto-corrects String#%' do
      corrected = autocorrect_source('puts "%d" % 10')
      expect(corrected).to eq 'puts sprintf("%d", 10)'
    end

    it 'auto-corrects String#% with an array argument' do
      corrected = autocorrect_source('puts x % [10, 11]')
      expect(corrected).to eq 'puts sprintf(x, 10, 11)'
    end

    it 'auto-corrects String#% with a hash argument' do
      corrected = autocorrect_source('puts x % { a: 10, b: 11 }')
      expect(corrected).to eq 'puts sprintf(x, a: 10, b: 11)'
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

    it 'auto-corrects sprintf' do
      corrected = autocorrect_source('sprintf(something, a, b)')
      expect(corrected).to eq 'format(something, a, b)'
    end

    it 'auto-corrects String#%' do
      corrected = autocorrect_source('puts "%d" % 10')
      expect(corrected).to eq 'puts format("%d", 10)'
    end

    it 'auto-corrects String#% with an array argument' do
      corrected = autocorrect_source('puts x % [10, 11]')
      expect(corrected).to eq 'puts format(x, 10, 11)'
    end

    it 'auto-corrects String#% with a hash argument' do
      corrected = autocorrect_source('puts x % { a: 10, b: 11 }')
      expect(corrected).to eq 'puts format(x, a: 10, b: 11)'
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

    it 'auto-corrects format with 2 arguments' do
      corrected = autocorrect_source('format(something, a)')
      expect(corrected).to eq 'something % a'
    end

    it 'auto-corrects format with 3 arguments' do
      corrected = autocorrect_source('format(something, a, b)')
      expect(corrected).to eq 'something % [a, b]'
    end

    it 'auto-corrects format with a hash argument' do
      corrected = autocorrect_source('format(something, a: 10, b: 11)')
      expect(corrected).to eq 'something % { a: 10, b: 11 }'
    end

    it 'auto-corrects sprintf with 2 arguments' do
      corrected = autocorrect_source('sprintf(something, a)')
      expect(corrected).to eq 'something % a'
    end

    it 'auto-corrects sprintf with 3 arguments' do
      corrected = autocorrect_source('sprintf(something, a, b)')
      expect(corrected).to eq 'something % [a, b]'
    end

    it 'auto-corrects sprintf with a hash argument' do
      corrected = autocorrect_source('sprintf(something, a: 10, b: 11)')
      expect(corrected).to eq 'something % { a: 10, b: 11 }'
    end
  end
end
