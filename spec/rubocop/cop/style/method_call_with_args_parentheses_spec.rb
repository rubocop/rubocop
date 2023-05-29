# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::MethodCallWithArgsParentheses, :config do
  shared_examples 'endless methods' do |omit: false|
    context 'endless methods', :ruby30 do
      context 'with arguments' do
        it 'requires method calls to have parens' do
          expect_no_offenses(<<~RUBY)
            def x() = foo("bar")
          RUBY
        end
      end

      context 'without arguments' do
        if omit
          it 'registers an offense when there are parens' do
            expect_offense(<<~RUBY)
              def x() = foo()
                           ^^ Omit parentheses for method calls with arguments.
            RUBY

            expect_correction(<<~RUBY)
              def x() = foo#{trailing_whitespace}
            RUBY
          end

          it 'registers an offense for `defs` when there are parens' do
            expect_offense(<<~RUBY)
              def self.x() = foo()
                                ^^ Omit parentheses for method calls with arguments.
            RUBY

            expect_correction(<<~RUBY)
              def self.x() = foo#{trailing_whitespace}
            RUBY
          end
        else
          it 'does not register an offense when there are parens' do
            expect_no_offenses(<<~RUBY)
              def x() = foo()
            RUBY
          end

          it 'does not register an offense for `defs` when there are parens' do
            expect_no_offenses(<<~RUBY)
              def self.x() = foo()
            RUBY
          end
        end

        it 'does not register an offense when there are no parens' do
          expect_no_offenses(<<~RUBY)
            def x() = foo
          RUBY
        end

        it 'does not register an offense when there are arguments' do
          expect_no_offenses(<<~RUBY)
            def x() = foo(y)
          RUBY
        end

        it 'does not register an offense for `defs` when there are arguments' do
          expect_no_offenses(<<~RUBY)
            def self.x() = foo(y)
          RUBY
        end
      end
    end
  end

  context 'when EnforcedStyle is require_parentheses (default)' do
    it_behaves_like 'endless methods'

    it 'accepts no parens in method call without args' do
      expect_no_offenses('top.test')
    end

    it 'accepts parens in method call with args' do
      expect_no_offenses('top.test(a, b)')
    end

    it 'accepts parens in method call with do-end blocks' do
      expect_no_offenses(<<~RUBY)
        foo(:arg) do
          bar
        end
      RUBY
    end

    it 'register an offense for method call without parens' do
      expect_offense(<<~RUBY)
        top.test a, b
        ^^^^^^^^^^^^^ Use parentheses for method calls with arguments.
      RUBY

      expect_correction(<<~RUBY)
        top.test(a, b)
      RUBY
    end

    context 'when using safe navigation operator' do
      it 'register an offense for method call without parens' do
        expect_offense(<<~RUBY)
          top&.test a, b
          ^^^^^^^^^^^^^^ Use parentheses for method calls with arguments.
        RUBY

        expect_correction(<<~RUBY)
          top&.test(a, b)
        RUBY
      end
    end

    it 'register an offense for non-receiver method call without parens' do
      expect_offense(<<~RUBY)
        def foo
          test a, b
          ^^^^^^^^^ Use parentheses for method calls with arguments.
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo
          test(a, b)
        end
      RUBY
    end

    it 'register an offense for methods starting with capital without parens' do
      expect_offense(<<~RUBY)
        def foo
          Test a, b
          ^^^^^^^^^ Use parentheses for method calls with arguments.
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo
          Test(a, b)
        end
      RUBY
    end

    it 'register an offense for superclass call without parens' do
      expect_offense(<<~RUBY)
        def foo
          super a
          ^^^^^^^ Use parentheses for method calls with arguments.
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo
          super(a)
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
      expect_offense(<<~RUBY)
        def foo
          yield a
          ^^^^^^^ Use parentheses for method calls with arguments.
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo
          yield(a)
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

    it 'autocorrects fully parenthesized args by removing space' do
      expect_offense(<<~RUBY)
        top.eq (1 + 2)
        ^^^^^^^^^^^^^^ Use parentheses for method calls with arguments.
      RUBY

      expect_correction(<<~RUBY)
        top.eq(1 + 2)
      RUBY
    end

    it 'autocorrects parenthesized args for local methods by removing space' do
      expect_offense(<<~RUBY)
        def foo
          eq (1 + 2)
          ^^^^^^^^^^ Use parentheses for method calls with arguments.
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo
          eq(1 + 2)
        end
      RUBY
    end

    it 'autocorrects call with multiple args by adding braces' do
      expect_offense(<<~RUBY)
        def foo
          eq 1, (2 + 3)
          ^^^^^^^^^^^^^ Use parentheses for method calls with arguments.
          eq 1, 2, 3
          ^^^^^^^^^^ Use parentheses for method calls with arguments.
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo
          eq(1, (2 + 3))
          eq(1, 2, 3)
        end
      RUBY
    end

    it 'autocorrects partially parenthesized args by adding needed braces' do
      expect_offense(<<~RUBY)
        top.eq (1 + 2) + 3
        ^^^^^^^^^^^^^^^^^^ Use parentheses for method calls with arguments.
      RUBY

      expect_correction(<<~RUBY)
        top.eq((1 + 2) + 3)
      RUBY
    end

    it 'autocorrects calls with multiple args by adding needed braces' do
      expect_offense(<<~RUBY)
        top.eq (1 + 2), 3
        ^^^^^^^^^^^^^^^^^ Use parentheses for method calls with arguments.
      RUBY

      expect_correction(<<~RUBY)
        top.eq((1 + 2), 3)
      RUBY
    end

    it 'autocorrects calls where arg is method call' do
      expect_offense(<<~RUBY)
        def my_method
          foo bar.baz(abc, xyz)
          ^^^^^^^^^^^^^^^^^^^^^ Use parentheses for method calls with arguments.
        end
      RUBY

      expect_correction(<<~RUBY)
        def my_method
          foo(bar.baz(abc, xyz))
        end
      RUBY
    end

    it 'autocorrects calls where multiple args are method calls' do
      expect_offense(<<~RUBY)
        def my_method
          foo bar.baz(abc, xyz), foo(baz)
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use parentheses for method calls with arguments.
        end
      RUBY

      expect_correction(<<~RUBY)
        def my_method
          foo(bar.baz(abc, xyz), foo(baz))
        end
      RUBY
    end

    it 'autocorrects calls where the argument node is a constant' do
      expect_offense(<<~RUBY)
        def my_method
          raise NotImplementedError
          ^^^^^^^^^^^^^^^^^^^^^^^^^ Use parentheses for method calls with arguments.
        end
      RUBY

      expect_correction(<<~RUBY)
        def my_method
          raise(NotImplementedError)
        end
      RUBY
    end

    it 'autocorrects calls where the argument node is a number' do
      expect_offense(<<~RUBY)
        def my_method
          sleep 1
          ^^^^^^^ Use parentheses for method calls with arguments.
        end
      RUBY

      expect_correction(<<~RUBY)
        def my_method
          sleep(1)
        end
      RUBY
    end

    context 'with AllowedMethods' do
      let(:cop_config) { { 'AllowedMethods' => %w[puts] } }

      it 'allow method listed in AllowedMethods' do
        expect_no_offenses('puts :test')
      end
    end

    context 'when inspecting macro methods' do
      let(:cop_config) { { 'IgnoreMacros' => 'true' } }

      context 'in a class body' do
        it 'does not register an offense' do
          expect_no_offenses(<<~RUBY)
            class Foo
              bar :baz
            end
          RUBY
        end
      end

      context 'in a module body' do
        it 'does not register an offense' do
          expect_no_offenses(<<~RUBY)
            module Foo
              bar :baz
            end
          RUBY
        end
      end
    end

    context 'AllowedPatterns' do
      let(:cop_config) { { 'AllowedPatterns' => %w[^assert ^refute] } }

      it 'ignored methods listed in AllowedPatterns' do
        expect_no_offenses('assert 2 == 2')
        expect_no_offenses('assert_equal 2, 2')
        expect_no_offenses('assert_match /^yes/i, result')

        expect_no_offenses('refute 2 == 3')
        expect_no_offenses('refute_equal 2, 3')
        expect_no_offenses('refute_match /^no/i, result')
      end
    end
  end

  context 'when EnforcedStyle is omit_parentheses' do
    let(:cop_config) { { 'EnforcedStyle' => 'omit_parentheses' } }

    it_behaves_like 'endless methods', omit: true

    context 'forwarded arguments in 2.7', :ruby27 do
      it 'accepts parens for forwarded arguments' do
        expect_no_offenses(<<~RUBY)
          def delegated_call(...)
            @proxy.call(...)
          end
        RUBY
      end
    end

    context 'forwarded arguments in 3.0', :ruby30 do
      it 'accepts parens for forwarded arguments' do
        expect_no_offenses(<<~RUBY)
          def method_missing(name, ...)
            @proxy.call(name, ...)
          end
        RUBY
      end
    end

    context 'numbered parameters in 2.7', :ruby27 do
      it 'accepts parens for braced numeric block calls' do
        expect_no_offenses(<<~RUBY)
          numblock.call(:arg) { _1 }
        RUBY
      end
    end

    context 'hash value omission in 3.1', :ruby31 do
      it 'registers an offense when last argument is a hash value omission' do
        expect_offense(<<~RUBY)
          foo(bar:, baz:)
             ^^^^^^^^^^^^ Omit parentheses for method calls with arguments.
        RUBY

        expect_correction(<<~RUBY)
          foo bar:, baz:
        RUBY
      end

      it 'does not register an offense when hash value omission with parentheses and using modifier form' do
        expect_no_offenses(<<~RUBY)
          do_something(value:) if condition
        RUBY
      end

      it 'registers and corrects an offense when explicit hash value with parentheses and using modifier form' do
        expect_offense(<<~RUBY)
          do_something(value: value) if condition
                      ^^^^^^^^^^^^^^ Omit parentheses for method calls with arguments.
        RUBY

        expect_correction(<<~RUBY)
          do_something value: value if condition
        RUBY
      end

      it 'does not register an offense when without parentheses call expr follows' do
        expect_no_offenses(<<~RUBY)
          foo value:
        RUBY
      end

      it 'registers an offense when with parentheses call expr follows' do
        # Require hash value omission be enclosed in parentheses to prevent the following issue:
        # https://bugs.ruby-lang.org/issues/18396.
        expect_offense(<<~RUBY)
          foo(value:)
          foo(arg)
             ^^^^^ Omit parentheses for method calls with arguments.
        RUBY

        expect_correction(<<~RUBY)
          foo(value:)
          foo arg
        RUBY
      end

      it 'registers an offense using assignment with parentheses call expr follows' do
        # Require hash value omission be enclosed in parentheses to prevent the following issue:
        # https://bugs.ruby-lang.org/issues/18396.
        expect_offense(<<~RUBY)
          var = foo(value:)
          foo(arg)
             ^^^^^ Omit parentheses for method calls with arguments.
        RUBY

        expect_correction(<<~RUBY)
          var = foo(value:)
          foo arg
        RUBY
      end

      it 'does not register an offense in conditionals' do
        expect_no_offenses(<<~RUBY)
          var =
            unless object.action(value:, other:)
              condition || other_condition
            end
        RUBY
      end
    end

    context 'anonymous rest arguments in 3.2', :ruby32 do
      it 'does not register an offense when method calls to have parens' do
        expect_no_offenses(<<~RUBY)
          def foo(*)
            foo(*)
            do_something
          end
        RUBY
      end
    end

    context 'anonymous keyword rest arguments in 3.2', :ruby32 do
      it 'does not register an offense when method calls to have parens' do
        expect_no_offenses(<<~RUBY)
          def foo(**)
            foo(**)
          end
        RUBY
      end
    end

    it 'register an offense for parens in method call without args' do
      trailing_whitespace = ' '

      expect_offense(<<~RUBY)
        top.test()
                ^^ Omit parentheses for method calls with arguments.
      RUBY

      expect_correction(<<~RUBY)
        top.test#{trailing_whitespace}
      RUBY
    end

    it 'register an offense for multi-line method calls' do
      expect_offense(<<~RUBY)
        test(
            ^ Omit parentheses for method calls with arguments.
          foo: bar
        )
      RUBY

      expect_correction(<<~RUBY)
        test \\
          foo: bar

      RUBY
    end

    it 'register an offense for superclass call with parens' do
      expect_offense(<<~RUBY)
        def foo
          super(a)
               ^^^ Omit parentheses for method calls with arguments.
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo
          super a
        end
      RUBY
    end

    it 'register an offense for yield call with parens' do
      expect_offense(<<~RUBY)
        def foo
          yield(a)
               ^^^ Omit parentheses for method calls with arguments.
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo
          yield a
        end
      RUBY
    end

    it 'register an offense for parens in the last chain' do
      expect_offense(<<~RUBY)
        foo().bar(3).wait(4)
                         ^^^ Omit parentheses for method calls with arguments.
      RUBY

      expect_correction(<<~RUBY)
        foo().bar(3).wait 4
      RUBY
    end

    it 'register an offense for parens in do-end blocks' do
      expect_offense(<<~RUBY)
        foo(:arg) do
           ^^^^^^ Omit parentheses for method calls with arguments.
          bar
        end
      RUBY

      expect_correction(<<~RUBY)
        foo :arg do
          bar
        end
      RUBY
    end

    it 'register an offense for hashes in keyword values' do
      expect_offense(<<~RUBY)
        method_call(hash: {foo: :bar})
                   ^^^^^^^^^^^^^^^^^^^ Omit parentheses for method calls with arguments.
      RUBY

      expect_correction(<<~RUBY)
        method_call hash: {foo: :bar}
      RUBY
    end

    it 'register an offense for %r regex literal as arguments' do
      expect_offense(<<~RUBY)
        method_call(%r{foo})
                   ^^^^^^^^^ Omit parentheses for method calls with arguments.
      RUBY

      expect_correction(<<~RUBY)
        method_call %r{foo}
      RUBY
    end

    it 'register an offense for parens in string interpolation' do
      expect_offense(<<~'RUBY')
        "#{t('no.parens')}"
            ^^^^^^^^^^^^^ Omit parentheses for method calls with arguments.
      RUBY

      expect_correction(<<~'RUBY')
        "#{t 'no.parens'}"
      RUBY
    end

    it 'register an offense in complex conditionals' do
      expect_offense(<<~RUBY)
        def foo
          if cond.present? && verify?(:something)
            h.do_with(kw: value)
                     ^^^^^^^^^^^ Omit parentheses for method calls with arguments.
          elsif cond.present? || verify?(:something_else)
            h.do_with(kw: value)
                     ^^^^^^^^^^^ Omit parentheses for method calls with arguments.
          elsif whatevs?
            h.do_with(kw: value)
                     ^^^^^^^^^^^ Omit parentheses for method calls with arguments.
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo
          if cond.present? && verify?(:something)
            h.do_with kw: value
          elsif cond.present? || verify?(:something_else)
            h.do_with kw: value
          elsif whatevs?
            h.do_with kw: value
          end
        end
      RUBY
    end

    it 'register an offense in assignments' do
      expect_offense(<<~RUBY)
        foo = A::B.new(c)
                      ^^^ Omit parentheses for method calls with arguments.
        bar.foo = A::B.new(c)
                          ^^^ Omit parentheses for method calls with arguments.
        bar.foo(42).quux = A::B.new(c)
                                   ^^^ Omit parentheses for method calls with arguments.

        bar.foo(42).quux &&= A::B.new(c)
                                     ^^^ Omit parentheses for method calls with arguments.

        bar.foo(42).quux += A::B.new(c)
                                    ^^^ Omit parentheses for method calls with arguments.
      RUBY

      expect_correction(<<~RUBY)
        foo = A::B.new c
        bar.foo = A::B.new c
        bar.foo(42).quux = A::B.new c

        bar.foo(42).quux &&= A::B.new c

        bar.foo(42).quux += A::B.new c
      RUBY
    end

    it 'register an offense for camel-case methods with arguments' do
      expect_offense(<<~RUBY)
        Array(:arg)
             ^^^^^^ Omit parentheses for method calls with arguments.
      RUBY

      expect_correction(<<~RUBY)
        Array :arg
      RUBY
    end

    it 'register an offense in multi-line inheritance' do
      expect_offense(<<~RUBY)
        class Point < Struct.new(:x, :y)
                                ^^^^^^^^ Omit parentheses for method calls with arguments.
        end
      RUBY

      expect_correction(<<~RUBY)
        class Point < Struct.new :x, :y
        end
      RUBY
    end

    it 'register an offense in calls inside braced blocks' do
      expect_offense(<<~RUBY)
        client.images(page: page) { |resource| Image.new(resource) }
                                                        ^^^^^^^^^^ Omit parentheses for method calls with arguments.
      RUBY

      expect_correction(<<~RUBY)
        client.images(page: page) { |resource| Image.new resource }
      RUBY
    end

    it 'register an offense in calls inside braced numblocks', :ruby27 do
      expect_offense(<<~RUBY)
        client.images(page: page) { Image.new(_1) }
                                             ^^^^ Omit parentheses for method calls with arguments.
      RUBY

      expect_correction(<<~RUBY)
        client.images(page: page) { Image.new _1 }
      RUBY
    end

    it 'accepts parens in single-line inheritance' do
      expect_no_offenses(<<-RUBY)
        class Point < Struct.new(:x, :y); end
      RUBY
    end

    it 'accepts no parens in method call without args' do
      expect_no_offenses('top.test')
    end

    it 'accepts no parens in method call with args' do
      expect_no_offenses('top.test 1, 2, foo: bar')
    end

    it 'accepts parens in default argument value calls' do
      expect_no_offenses(<<~RUBY)
        def regular(arg = default(42))
          nil
        end

        def seatle_style arg = default(42)
          nil
        end
      RUBY
    end

    it 'accepts parens in default keyword argument value calls' do
      expect_no_offenses(<<~RUBY)
        def regular(arg: default(42))
          nil
        end

        def seatle_style arg: default(42)
          nil
        end
      RUBY
    end

    it 'accepts parens in method args' do
      expect_no_offenses('top.test 1, 2, foo: bar(3)')
    end

    it 'accepts parens in nested method args' do
      expect_no_offenses('top.test 1, 2, foo: [bar(3)]')
    end

    it 'accepts parens in calls with hash as arg' do
      expect_no_offenses('top.test({foo: :bar})')
      expect_no_offenses('top.test({foo: :bar}.merge(baz: :maz))')
      expect_no_offenses('top.test(:first, {foo: :bar}.merge(baz: :maz))')
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

    it 'accepts parens in array literal calls' do
      expect_no_offenses(<<~RUBY)
        [
          foo.bar.quux(:args) do
            pass
          end,
        ]
      RUBY
    end

    it 'accepts parens in calls with logical operators' do
      expect_no_offenses('foo(a) && bar(b)')
      expect_no_offenses('foo(a) || bar(b)')
      expect_no_offenses(<<~RUBY)
        foo(a) || bar(b) do
          pass
        end
      RUBY
    end

    it 'accepts parens in calls with args with logical operators' do
      expect_no_offenses('foo(a, b || c)')
      expect_no_offenses('foo a, b || c')
      expect_no_offenses('foo a, b(1) || c(2, d(3))')
    end

    it 'accepts parens in literals with unary operators as first argument' do
      expect_no_offenses('foo(-1)')
      expect_no_offenses('foo(+1)')
      expect_no_offenses('foo(+"")')
      expect_no_offenses('foo(-"")')
    end

    it 'accepts parens in args splat' do
      expect_no_offenses('foo(*args)')
      expect_no_offenses('foo *args')
      expect_no_offenses('foo(**kwargs)')
      expect_no_offenses('foo **kwargs')
    end

    it 'accepts parens in slash regexp literal as argument' do
      expect_no_offenses('foo(/regexp/)')
    end

    it 'accepts parens in argument calls with braced blocks' do
      expect_no_offenses('foo(bar(:arg) { 42 })')
    end

    it 'accepts parens in implicit #to_proc' do
      expect_no_offenses('foo(&block)')
      expect_no_offenses('foo &block')
    end

    it 'accepts parens in yield argument method calls' do
      expect_no_offenses('yield File.basepath(path)')
      expect_no_offenses('yield path, File.basepath(path)')
    end

    it 'accepts parens in super without args' do
      expect_no_offenses('super()')
    end

    it 'accepts parens in super method calls as arguments' do
      expect_no_offenses('super foo(bar)')
    end

    it 'accepts parens in super calls with braced blocks' do
      expect_no_offenses('super(foo(bar)) { yield }')
    end

    it 'accepts parens in camel case method without args' do
      expect_no_offenses('Array()')
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

    it 'accepts parens in splat calls' do
      expect_no_offenses(<<-RUBY)
        foo(*bar(args))
        foo(**quux(args))
      RUBY
    end

    it 'accepts parens in block passing calls' do
      expect_no_offenses(<<-RUBY)
        foo(&method(:args))
      RUBY
    end

    it 'accepts parens in range literals' do
      expect_no_offenses(<<-RUBY)
        1..limit(n)
        1...limit(n)
      RUBY
    end

    it 'accepts parens in assignment in conditions' do
      expect_no_offenses(<<-RUBY)
        case response = get("server/list")
        when server = response.take(1)
          if @size ||= server.take(:size)
            pass
          elsif @@image &&= server.take(:image)
            pass
          end
        end
      RUBY
    end

    it 'autocorrects single-line calls' do
      expect_offense(<<~RUBY)
        top.test(1, 2, foo: bar(3))
                ^^^^^^^^^^^^^^^^^^^ Omit parentheses for method calls with arguments.
      RUBY

      expect_correction(<<~RUBY)
        top.test 1, 2, foo: bar(3)
      RUBY
    end

    it 'autocorrects multi-line calls with trailing whitespace' do
      trailing_whitespace = ' '

      expect_offense(<<~RUBY)
        foo(#{trailing_whitespace}
           ^^ Omit parentheses for method calls with arguments.
          bar: 3
        )
      RUBY

      expect_correction(<<~RUBY)
        foo \\#{trailing_whitespace}
          bar: 3

      RUBY
    end

    it 'autocorrects complex multi-line calls' do
      expect_offense(<<~RUBY)
        foo(arg,
           ^^^^^ Omit parentheses for method calls with arguments.
          option: true
        )
      RUBY

      expect_correction(<<~RUBY)
        foo arg,
          option: true

      RUBY
    end

    it 'accepts parens in chaining with safe operators' do
      expect_no_offenses('Something.find(criteria: given)&.field')
    end

    it 'accepts parens in operator method calls' do
      expect_no_offenses(<<~RUBY)
        data.[](value)
        data&.[](value)
        string.<<(even_more_string)
        ruby.==(good)
        ruby&.===(better)
      RUBY
    end

    context 'allowing parenthesis in chaining' do
      let(:cop_config) do
        {
          'EnforcedStyle' => 'omit_parentheses',
          'AllowParenthesesInChaining' => true
        }
      end

      it 'register offense for single-line chaining without previous parens' do
        expect_offense(<<~RUBY)
          Rails.convoluted.example.logger.error("something")
                                               ^^^^^^^^^^^^^ Omit parentheses for method calls with arguments.
        RUBY

        expect_correction(<<~RUBY)
          Rails.convoluted.example.logger.error "something"
        RUBY
      end

      it 'register offense for multi-line chaining without previous parens' do
        expect_offense(<<~RUBY)
          Rails
            .convoluted
            .example
            .logger
            .error("something")
                  ^^^^^^^^^^^^^ Omit parentheses for method calls with arguments.
        RUBY

        expect_correction(<<~RUBY)
          Rails
            .convoluted
            .example
            .logger
            .error "something"
        RUBY
      end

      it 'accepts no parens in the last call if previous calls with parens' do
        expect_no_offenses('foo().bar(3).wait 4')
      end

      it 'accepts parens in the last call if any previous calls with parentheses' do
        expect_no_offenses('foo().bar(3).quux.wait(4)')
      end

      it 'accepts parens in empty hashes for arguments calls' do
        expect_no_offenses(<<~RUBY)
          params.should eq({})
        RUBY
      end
    end

    context 'allowing parens in multi-line calls' do
      let(:cop_config) do
        {
          'EnforcedStyle' => 'omit_parentheses',
          'AllowParenthesesInMultilineCall' => true
        }
      end

      it 'accepts parens for multi-line calls' do
        expect_no_offenses(<<~RUBY)
          test(
            foo: bar
          )
        RUBY
      end
    end

    context 'allowing parens in camel-case methods' do
      let(:cop_config) do
        {
          'EnforcedStyle' => 'omit_parentheses',
          'AllowParenthesesInCamelCaseMethod' => true
        }
      end

      it 'accepts parens for camel-case method names' do
        expect_no_offenses('Array(nil)')
      end
    end
  end

  context 'allowing parens in string interpolation' do
    let(:cop_config) do
      {
        'EnforcedStyle' => 'omit_parentheses',
        'AllowParenthesesInStringInterpolation' => true
      }
    end

    it 'accepts parens for camel-case method names' do
      expect_no_offenses(<<~'RUBY')
        "#{t('this.is.good')}"
        "#{t 'this.is.also.good'}"
      RUBY
    end
  end

  context 'when inspecting macro methods with IncludedMacros' do
    let(:cop_config) { { 'IgnoreMacros' => 'true', 'IncludedMacros' => ['bar'] } }

    it_behaves_like 'endless methods'

    context 'in a class body' do
      it 'finds offense' do
        expect_offense(<<~RUBY)
          class Foo
            bar :abc
            ^^^^^^^^ Use parentheses for method calls with arguments.
          end
        RUBY

        expect_correction(<<~RUBY)
          class Foo
            bar(:abc)
          end
        RUBY
      end
    end

    context 'in a module body' do
      it 'finds offense' do
        expect_offense(<<~RUBY)
          module Foo
            bar :abc
            ^^^^^^^^ Use parentheses for method calls with arguments.
          end
        RUBY

        expect_correction(<<~RUBY)
          module Foo
            bar(:abc)
          end
        RUBY
      end
    end

    context 'for a macro not on the included list' do
      it 'allows' do
        expect_no_offenses(<<~RUBY)
          module Foo
            baz :abc
          end
        RUBY
      end
    end

    context 'for a macro in both IncludedMacros and AllowedMethods' do
      let(:cop_config) do
        {
          'IgnoreMacros' => 'true',
          'IncludedMacros' => ['bar'],
          'AllowedMethods' => ['bar']
        }
      end

      it 'allows' do
        expect_no_offenses(<<~RUBY)
          module Foo
            bar :abc
          end
        RUBY
      end
    end
  end
end
