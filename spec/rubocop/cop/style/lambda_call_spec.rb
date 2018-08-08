# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::LambdaCall, :config do
  subject(:cop) { described_class.new(config) }

  context 'when style is set to call' do
    let(:cop_config) { { 'EnforcedStyle' => 'call' } }

    it 'registers an offense for x.()' do
      expect_offense(<<-RUBY.strip_indent)
        x.(a, b)
        ^^^^^^^^ Prefer the use of `lambda.call(...)` over `lambda.(...)`.
      RUBY
    end

    it 'registers an offense for correct + opposite' do
      expect_offense(<<-RUBY.strip_indent)
        x.call(a, b)
        x.(a, b)
        ^^^^^^^^ Prefer the use of `lambda.call(...)` over `lambda.(...)`.
      RUBY
    end

    it 'accepts x.call()' do
      expect_no_offenses('x.call(a, b)')
    end

    it 'auto-corrects x.() to x.call()' do
      new_source = autocorrect_source('a.(x)')
      expect(new_source).to eq('a.call(x)')
    end
  end

  context 'when style is set to braces' do
    let(:cop_config) { { 'EnforcedStyle' => 'braces' } }

    it 'registers an offense for x.call()' do
      expect_offense(<<-RUBY.strip_indent)
        x.call(a, b)
        ^^^^^^^^^^^^ Prefer the use of `lambda.(...)` over `lambda.call(...)`.
      RUBY
    end

    it 'registers an offense for opposite + correct' do
      expect_offense(<<-RUBY.strip_indent)
        x.call(a, b)
        ^^^^^^^^^^^^ Prefer the use of `lambda.(...)` over `lambda.call(...)`.
        x.(a, b)
      RUBY
    end

    it 'accepts x.()' do
      expect_no_offenses('x.(a, b)')
    end

    it 'accepts a call without receiver' do
      expect_no_offenses('call(a, b)')
    end

    it 'auto-corrects x.call() to x.()' do
      new_source = autocorrect_source('a.call(x)')
      expect(new_source).to eq('a.(x)')
    end

    it 'auto-corrects x.call to x.()' do
      new_source = autocorrect_source('a.call')
      expect(new_source).to eq('a.()')
    end

    it 'auto-corrects x.call asdf, x123 to x.(asdf, x123)' do
      new_source = autocorrect_source('a.call asdf, x123')
      expect(new_source).to eq('a.(asdf, x123)')
    end
  end
end
