# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::UselessRuby2Keywords, :config do
  context 'when `ruby2_keywords` is given a `def` node' do
    it 'registers an offense for a method without arguments' do
      expect_offense(<<~RUBY)
        ruby2_keywords def foo
        ^^^^^^^^^^^^^^ `ruby2_keywords` is unnecessary for method `foo`.
        end
      RUBY
    end

    it 'registers an offense for a method with only positional args' do
      expect_offense(<<~RUBY)
        ruby2_keywords def foo(arg)
        ^^^^^^^^^^^^^^ `ruby2_keywords` is unnecessary for method `foo`.
        end
      RUBY
    end

    it 'registers an offense for a method with only `kwrestarg`' do
      expect_offense(<<~RUBY)
        ruby2_keywords def foo(**kwargs)
        ^^^^^^^^^^^^^^ `ruby2_keywords` is unnecessary for method `foo`.
        end
      RUBY
    end

    it 'registers an offense for a method with only keyword args' do
      expect_offense(<<~RUBY)
        ruby2_keywords def foo(i:, j:)
        ^^^^^^^^^^^^^^ `ruby2_keywords` is unnecessary for method `foo`.
        end
      RUBY
    end

    it 'registers an offense for a method with a `restarg` and keyword args' do
      expect_offense(<<~RUBY)
        ruby2_keywords def foo(*args, i:, j:)
        ^^^^^^^^^^^^^^ `ruby2_keywords` is unnecessary for method `foo`.
        end
      RUBY
    end

    it 'registers an offense for a method with a `restarg` and `kwoptarg`' do
      expect_offense(<<~RUBY)
        ruby2_keywords def foo(*args, i: 1)
        ^^^^^^^^^^^^^^ `ruby2_keywords` is unnecessary for method `foo`.
        end
      RUBY
    end

    it 'registers an offense for a method with a `restarg` and `kwrestarg`' do
      expect_offense(<<~RUBY)
        ruby2_keywords def foo(*args, **kwargs)
        ^^^^^^^^^^^^^^ `ruby2_keywords` is unnecessary for method `foo`.
        end
      RUBY
    end

    it 'does not register an offense for a method with a `restarg` and no `kwrestarg`' do
      expect_no_offenses(<<~RUBY)
        ruby2_keywords def foo(*args)
        end
      RUBY
    end

    it 'does not register an offense for a method with a `restarg` other positional args' do
      expect_no_offenses(<<~RUBY)
        ruby2_keywords def foo(arg1, arg2, *rest)
        end
      RUBY
    end

    it 'does not register an offense for a method with a `restarg` other optional args' do
      expect_no_offenses(<<~RUBY)
        ruby2_keywords def foo(arg1 = 5, *rest)
        end
      RUBY
    end

    it 'does not register an offense for a method with a `restarg` and `blockarg`' do
      expect_no_offenses(<<~RUBY)
        ruby2_keywords def foo(*rest, &block)
        end
      RUBY
    end
  end

  context 'when `ruby2_keywords` is given a symbol' do
    it 'registers an offense for an unnecessary `ruby2_keywords`' do
      expect_offense(<<~RUBY)
        def foo(**kwargs)
        end
        ruby2_keywords :foo
        ^^^^^^^^^^^^^^^^^^^ `ruby2_keywords` is unnecessary for method `foo`.
      RUBY
    end

    it 'registers an offense for an unnecessary `ruby2_keywords` in a condition' do
      expect_offense(<<~RUBY)
        def foo(**kwargs)
        end
        ruby2_keywords :foo if respond_to?(:ruby2_keywords, true)
        ^^^^^^^^^^^^^^^^^^^ `ruby2_keywords` is unnecessary for method `foo`.
      RUBY
    end

    it 'does not register an offense for an allowed def' do
      expect_no_offenses(<<~RUBY)
        def foo(*args)
        end
        ruby2_keywords :foo
      RUBY
    end

    it 'does not register an offense when there is no `def`' do
      expect_no_offenses(<<~RUBY)
        ruby2_keywords :foo
      RUBY
    end

    it 'does not register an offense when the `def` is at a different depth' do
      expect_no_offenses(<<~RUBY)
        class C
          class D
            def foo(**kwargs)
            end
          end

          ruby2_keywords :foo
        end
      RUBY
    end
  end

  context 'with a dynamically defined method' do
    it 'registers an offense for an unnecessary `ruby2_keywords`' do
      expect_offense(<<~RUBY)
        define_method(:foo) { |**kwargs| }
        ruby2_keywords :foo
        ^^^^^^^^^^^^^^^^^^^ `ruby2_keywords` is unnecessary for method `foo`.
      RUBY
    end

    it 'does not register an offense for an allowed `ruby2_keywords`' do
      expect_no_offenses(<<~RUBY)
        define_method(:foo) { |*args| }
        ruby2_keywords :foo
      RUBY
    end

    it 'registers an offense when the method has a `shadowarg`' do
      expect_offense(<<~RUBY)
        define_method(:foo) { |x; y| }
        ruby2_keywords :foo
        ^^^^^^^^^^^^^^^^^^^ `ruby2_keywords` is unnecessary for method `foo`.
      RUBY
    end

    it 'does not register an offense when the method has a `restarg` and a `shadowarg`' do
      expect_no_offenses(<<~RUBY)
        define_method(:foo) { |*args; y| }
        ruby2_keywords :foo
      RUBY
    end

    it 'registers an offense for a numblock', :ruby27 do
      expect_offense(<<~RUBY)
        define_method(:foo) { _1 }
        ruby2_keywords :foo
        ^^^^^^^^^^^^^^^^^^^ `ruby2_keywords` is unnecessary for method `foo`.
      RUBY
    end

    it 'does not register an offense for `Proc#ruby2_keywords`' do
      expect_no_offenses(<<~RUBY)
        block = proc { |_, *args| klass.new(*args) }
        block.ruby2_keywords if block.respond_to?(:ruby2_keywords)
      RUBY
    end
  end
end
