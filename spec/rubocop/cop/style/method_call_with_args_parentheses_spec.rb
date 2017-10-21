# frozen_string_literal: true

describe RuboCop::Cop::Style::MethodCallWithArgsParentheses, :config do
  subject(:cop) { described_class.new(config) }

  let(:cop_config) do
    { 'IgnoredMethods' => %w[puts] }
  end

  it 'accepts no parens in method call without args' do
    expect_no_offenses('top.test')
  end

  it 'accepts parens in method call with args' do
    expect_no_offenses('top.test(a, b)')
  end

  it 'register an offense for method call without parens' do
    expect_offense(<<-RUBY.strip_indent)
      top.test a, b
      ^^^^^^^^^^^^^ Use parentheses for method calls with arguments.
    RUBY
  end

  it 'register an offense for non-reciever method call without parens' do
    expect_offense(<<-RUBY.strip_indent)
      def foo
        test a, b
        ^^^^^^^^^ Use parentheses for method calls with arguments.
      end
    RUBY
  end

  it 'register an offense for methods starting with a capital without parens' do
    expect_offense(<<-RUBY.strip_indent)
      def foo
        Test a, b
        ^^^^^^^^^ Use parentheses for method calls with arguments.
      end
    RUBY
  end

  it 'register an offense for superclass call without parens' do
    expect_offense(<<-RUBY.strip_indent)
      def foo
        super a
        ^^^^^^^ Use parentheses for method calls with arguments.
      end
    RUBY
  end

  it 'register no offense for superclass call without args' do
    expect_no_offenses('super')
  end

  it 'register no offense for yield without args' do
    expect_no_offenses('yield')
  end

  it 'register no offense for superclass call with parens' do
    expect_no_offenses('super(a)')
  end

  it 'register an offense for yield without parens' do
    expect_offense(<<-RUBY.strip_indent)
      def foo
        yield a
        ^^^^^^^ Use parentheses for method calls with arguments.
      end
    RUBY
  end

  it 'accepts no parens for operators' do
    expect_no_offenses('top.test + a')
  end

  it 'accepts no parens for setter methods' do
    expect_no_offenses('top.test = a')
  end

  it 'accepts no parens for unary operators' do
    expect_no_offenses('!test')
  end

  it 'auto-corrects call by adding needed braces' do
    new_source = autocorrect_source('top.test a')
    expect(new_source).to eq('top.test(a)')
  end

  it 'auto-corrects superclass call by adding needed braces' do
    new_source = autocorrect_source(<<-RUBY.strip_indent)
      def foo
        super a
      end
    RUBY

    expect(new_source).to eq(<<-RUBY.strip_indent)
      def foo
        super(a)
      end
    RUBY
  end

  it 'auto-corrects yield by adding needed braces' do
    new_source = autocorrect_source(<<-RUBY.strip_indent)
      def foo
        yield a
      end
    RUBY

    expect(new_source).to eq(<<-RUBY.strip_indent)
      def foo
        yield(a)
      end
    RUBY
  end

  it 'ignores method listed in IgnoredMethods' do
    expect_no_offenses('puts :test')
  end

  context 'when inspecting macro methods' do
    let(:cop_config) do
      { 'IgnoreMacros' => 'true' }
    end

    context 'in a class body' do
      it 'does not register an offense' do
        expect_no_offenses(<<-RUBY.strip_indent)
          class Foo
            bar :baz
          end
        RUBY
      end
    end

    context 'in a module body' do
      it 'does not register an offense' do
        expect_no_offenses(<<-RUBY.strip_indent)
          module Foo
            bar :baz
          end
        RUBY
      end
    end
  end
end
