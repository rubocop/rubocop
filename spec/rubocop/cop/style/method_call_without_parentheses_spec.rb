# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::Style::MethodCallWithoutParentheses, :config do
  subject(:cop) { described_class.new(config) }

  it 'registers an offense for parens in method call without args' do
    expect_offense(<<-RUBY.strip_indent)
      top.test()
              ^^ Do not use parentheses for method calls.
    RUBY
  end

  it 'registers an offense for methods starting with an upcase letter' do
    expect_offense(<<-RUBY.strip_indent)
      Test()
          ^^ Do not use parentheses for method calls.
    RUBY
  end

  it 'registers an offense for multi-line method calls' do
    expect_offense(<<-RUBY.strip_indent)
      test(
          ^ Do not use parentheses for method calls.
        foo: bar
      )
    RUBY
  end

  it 'registers an offense for parens in the last chain' do
    expect_offense(<<-RUBY.strip_indent)
      foo().bar(3).wait(4)
                       ^^^ Do not use parentheses for method calls.
    RUBY
  end

  it 'accepts no parens in method call without args' do
    expect_no_offenses('top.test')
  end

  it 'accepts no parens in method call with args' do
    expect_no_offenses('top.test 1, 2, foo: bar')
  end

  it 'accepts parens in method args' do
    expect_no_offenses('top.test 1, 2, foo: bar(3)')
  end

  it 'accepts parens in nested method args' do
    expect_no_offenses('top.test 1, 2, foo: [bar(3)]')
  end

  it 'accepts special lambda call syntax' do
    expect_no_offenses('thing.()')
  end

  it 'accepts parens in chained method calls' do
    expect_no_offenses('foo().bar(3).wait(4).it')
  end

  it 'accepts parens in chaining with operators' do
    expect_no_offenses('foo().bar(3).wait(4) + 4')
  end

  it 'auto-corrects single-line calls' do
    original = <<-RUBY.strip_indent
      top.test(1, 2, foo: bar(3))
    RUBY

    expect(autocorrect_source(original)).to eq(<<-RUBY.strip_indent)
      top.test 1, 2, foo: bar(3)
    RUBY
  end

  it 'auto-corrects multi-line calls' do
    original = <<-RUBY.strip_indent
      foo(
        bar: 3
      )
    RUBY

    expect(autocorrect_source(original)).to eq(<<-RUBY.strip_indent)
      foo \\
        bar: 3

    RUBY
  end

  it 'auto-corrects multi-line calls with trailing whitespace' do
    original = <<-RUBY.strip_indent
      foo( 
        bar: 3
      )
    RUBY

    expect(autocorrect_source(original)).to eq(<<-RUBY.strip_indent)
      foo \\ 
        bar: 3

    RUBY
  end

  it 'auto-corrects complex multi-line calls' do
    original = <<-RUBY.strip_indent
      foo(arg,
        option: true
      )
    RUBY

    expect(autocorrect_source(original)).to eq(<<-RUBY.strip_indent)
      foo arg,
        option: true

    RUBY
  end

  it 'auto-corrects chained calls' do
    original = <<-RUBY.strip_indent
      foo().bar(3).wait(4)
    RUBY

    expect(autocorrect_source(original)).to eq(<<-RUBY.strip_indent)
      foo().bar(3).wait 4
    RUBY
  end

  context 'allowing parenthesis in chaining' do
    let(:cop_config) do
      { 'AllowParenthesesInChaining' => true }
    end

    it 'accepts parens in the last chain' do
      expect_no_offenses('foo().bar(3).wait 4')
    end

    it 'does not auto-correct' do
      original = <<-RUBY.strip_indent
        foo().bar(3).wait(4)
      RUBY

      expect(autocorrect_source(original)).to eq(original)
    end
  end

  context 'allowing parens in multi-line calls' do
    let(:cop_config) do
      { 'AllowParenthesesInMultilineCall' => true }
    end

    it 'accepts parens for multi-line calls ' do
      expect_no_offenses(<<-RUBY.strip_indent)
        test(
          foo: bar
        )
      RUBY
    end

    it 'does not auto-correct' do
      original = <<-RUBY.strip_indent
        foo(
          bar: 3
        )
      RUBY

      expect(autocorrect_source(original)).to eq(original)
    end
  end
end
