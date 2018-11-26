# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::MethodCallWithArgsParentheses, :config do
  subject(:cop) { described_class.new(config) }

  context 'when EnforcedStyle is require_parentheses (default)' do
    let(:cop_config) do
      { 'IgnoredMethods' => %w[puts] }
    end

    it 'accepts no parens in method call without args' do
      expect_no_offenses('top.test')
    end

    it 'accepts parens in method call with args' do
      expect_no_offenses('top.test(a, b)')
    end

    it 'accepts parens in method call with do-end blocks' do
      expect_no_offenses(<<-RUBY.strip_indent)
        foo(:arg) do
          bar
        end
      RUBY
    end

    it 'register an offense for method call without parens' do
      expect_offense(<<-RUBY.strip_indent)
        top.test a, b
        ^^^^^^^^^^^^^ Use parentheses for method calls with arguments.
      RUBY
    end

    it 'register an offense for non-receiver method call without parens' do
      expect_offense(<<-RUBY.strip_indent)
        def foo
          test a, b
          ^^^^^^^^^ Use parentheses for method calls with arguments.
        end
      RUBY
    end

    it 'register an offense for methods starting with capital without parens' do
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

    it 'auto-corrects fully parenthesized args by removing space' do
      new_source = autocorrect_source(<<-RUBY.strip_indent)
        top.eq (1 + 2)
      RUBY

      expect(new_source).to eq(<<-RUBY.strip_indent)
        top.eq(1 + 2)
      RUBY
    end

    it 'auto-corrects parenthesized args for local methods by removing space' do
      new_source = autocorrect_source(<<-RUBY.strip_indent)
        def foo
          eq (1 + 2)
        end
      RUBY

      expect(new_source).to eq(<<-RUBY.strip_indent)
        def foo
          eq(1 + 2)
        end
      RUBY
    end

    it 'auto-corrects call with multiple args by adding braces' do
      new_source = autocorrect_source(<<-RUBY.strip_indent)
        def foo
          eq 1, (2 + 3)
          eq 1, 2, 3
        end
      RUBY

      expect(new_source).to eq(<<-RUBY.strip_indent)
        def foo
          eq(1, (2 + 3))
          eq(1, 2, 3)
        end
      RUBY
    end

    it 'auto-corrects partially parenthesized args by adding needed braces' do
      new_source = autocorrect_source(<<-RUBY.strip_indent)
        top.eq (1 + 2) + 3
      RUBY

      expect(new_source).to eq(<<-RUBY.strip_indent)
        top.eq((1 + 2) + 3)
      RUBY
    end

    it 'auto-corrects calls with multiple args by adding needed braces' do
      new_source = autocorrect_source(<<-RUBY.strip_indent)
        top.eq (1 + 2), 3
      RUBY

      expect(new_source).to eq(<<-RUBY.strip_indent)
        top.eq((1 + 2), 3)
      RUBY
    end

    it 'auto-corrects calls where arg is method call' do
      new_source = autocorrect_source(<<-RUBY.strip_indent)
        def my_method
          foo bar.baz(abc, xyz)
        end
      RUBY

      expect(new_source).to eq(<<-RUBY.strip_indent)
        def my_method
          foo(bar.baz(abc, xyz))
        end
      RUBY
    end

    it 'auto-corrects calls where multiple args are method calls' do
      new_source = autocorrect_source(<<-RUBY.strip_indent)
        def my_method
          foo bar.baz(abc, xyz), foo(baz)
        end
      RUBY

      expect(new_source).to eq(<<-RUBY.strip_indent)
        def my_method
          foo(bar.baz(abc, xyz), foo(baz))
        end
      RUBY
    end

    it 'auto-corrects calls where the argument node is a constant' do
      new_source = autocorrect_source(<<-RUBY.strip_indent)
        def my_method
          raise NotImplementedError
        end
      RUBY

      expect(new_source).to eq(<<-RUBY.strip_indent)
        def my_method
          raise(NotImplementedError)
        end
      RUBY
    end

    it 'auto-corrects calls where the argument node is a number' do
      new_source = autocorrect_source(<<-RUBY.strip_indent)
        def my_method
          sleep 1
        end
      RUBY

      expect(new_source).to eq(<<-RUBY.strip_indent)
        def my_method
          sleep(1)
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

  context 'when EnforcedStyle is omit_parentheses' do
    let(:cop_config) do
      { 'EnforcedStyle' => 'omit_parentheses' }
    end

    it 'register an offense for parens in method call without args' do
      expect_offense(<<-RUBY.strip_indent)
        top.test()
                ^^ Omit parentheses for method calls with arguments.
      RUBY
    end

    it 'register an offense for methods starting with capital letter' do
      expect_offense(<<-RUBY.strip_indent)
        Test()
            ^^ Omit parentheses for method calls with arguments.
      RUBY
    end

    it 'register an offense for multi-line method calls' do
      expect_offense(<<-RUBY.strip_indent)
        test(
            ^ Omit parentheses for method calls with arguments.
          foo: bar
        )
      RUBY
    end

    it 'register an offense for superclass call with parens' do
      expect_offense(<<-RUBY.strip_indent)
        def foo
          super(a)
               ^^^ Omit parentheses for method calls with arguments.
        end
      RUBY
    end

    it 'register an offense for yield call with parens' do
      expect_offense(<<-RUBY.strip_indent)
        def foo
          yield(a)
               ^^^ Omit parentheses for method calls with arguments.
        end
      RUBY
    end

    it 'register an offense for parens in the last chain' do
      expect_offense(<<-RUBY.strip_indent)
        foo().bar(3).wait(4)
                         ^^^ Omit parentheses for method calls with arguments.
      RUBY
    end

    it 'register an offense accepts parens in do-end blocks' do
      expect_offense(<<-RUBY.strip_indent)
        foo(:arg) do
           ^^^^^^ Omit parentheses for method calls with arguments.
          bar
        end
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

    it 'accepts parens in blocks with braces' do
      expect_no_offenses('foo(1) { 2 }')
    end

    it 'accepts parens in calls with logical operators' do
      expect_no_offenses('foo(a) && bar(b)')
      expect_no_offenses('foo(a) || bar(b)')
    end

    it 'accepts parens in calls with args with logical operators' do
      expect_no_offenses('foo(a, b || c)')
      expect_no_offenses('foo a, b || c')
      expect_no_offenses('foo a, b(1) || c(2, d(3))')
    end

    it 'accepts parens in args splat' do
      expect_no_offenses('foo(*args)')
      expect_no_offenses('foo *args')
      expect_no_offenses('foo(**kwargs)')
      expect_no_offenses('foo **kwargs')
    end

    it 'accepts parens in implicit #to_proc' do
      expect_no_offenses('foo(&block)')
      expect_no_offenses('foo &block')
    end

    it 'accepts parens in super without args' do
      expect_no_offenses('super()')
    end

    it 'accepts parens in ternary condition calls' do
      expect_no_offenses(<<-RUBY)
        foo.include?(bar) ? bar : quux
      RUBY
    end

    it 'accepts parens in args with ternary conditions' do
      expect_no_offenses(<<-RUBY)
        foo.include?(bar ? baz : quux)
      RUBY
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
        {
          'EnforcedStyle' => 'omit_parentheses',
          'AllowParenthesesInChaining' => true
        }
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
        {
          'EnforcedStyle' => 'omit_parentheses',
          'AllowParenthesesInMultilineCall' => true
        }
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
end
