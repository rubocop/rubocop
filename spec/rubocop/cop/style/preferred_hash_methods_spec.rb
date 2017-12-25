# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::PreferredHashMethods, :config do
  subject(:cop) { described_class.new(config) }

  context 'with enforced `short` style' do
    let(:cop_config) { { 'EnforcedStyle' => 'short' } }

    it 'registers an offense for has_key? with one arg' do
      expect_offense(<<-RUBY.strip_indent)
        o.has_key?(o)
          ^^^^^^^^ Use `Hash#key?` instead of `Hash#has_key?`.
      RUBY
    end

    it 'accepts has_key? with no args' do
      expect_no_offenses('o.has_key?')
    end

    it 'registers an offense for has_value? with one arg' do
      expect_offense(<<-RUBY.strip_indent)
        o.has_value?(o)
          ^^^^^^^^^^ Use `Hash#value?` instead of `Hash#has_value?`.
      RUBY
    end

    it 'accepts has_value? with no args' do
      expect_no_offenses('o.has_value?')
    end

    it 'auto-corrects has_key? with key?' do
      new_source = autocorrect_source('hash.has_key?(:test)')
      expect(new_source).to eq('hash.key?(:test)')
    end

    it 'auto-corrects has_value? with value?' do
      new_source = autocorrect_source('hash.has_value?(value)')
      expect(new_source).to eq('hash.value?(value)')
    end
  end

  context 'with enforced `verbose` style' do
    let(:cop_config) { { 'EnforcedStyle' => 'verbose' } }

    it 'registers an offense for key? with one arg' do
      expect_offense(<<-RUBY.strip_indent)
        o.key?(o)
          ^^^^ Use `Hash#has_key?` instead of `Hash#key?`.
      RUBY
    end

    it 'accepts key? with no args' do
      expect_no_offenses('o.key?')
    end

    it 'registers an offense for value? with one arg' do
      expect_offense(<<-RUBY.strip_indent)
        o.value?(o)
          ^^^^^^ Use `Hash#has_value?` instead of `Hash#value?`.
      RUBY
    end

    it 'accepts value? with no args' do
      expect_no_offenses('o.value?')
    end

    it 'auto-corrects key? with has_key?' do
      new_source = autocorrect_source('hash.key?(:test)')
      expect(new_source).to eq('hash.has_key?(:test)')
    end

    it 'auto-corrects value? with has_value?' do
      new_source = autocorrect_source('hash.value?(value)')
      expect(new_source).to eq('hash.has_value?(value)')
    end
  end
end
