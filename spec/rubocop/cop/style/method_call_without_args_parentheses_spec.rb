# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::MethodCallWithoutArgsParentheses, :config do
  it 'registers an offense for parens in method call without args' do
    expect_offense(<<~RUBY)
      top.test()
              ^^ Do not use parentheses for method calls with no arguments.
    RUBY

    expect_correction(<<~RUBY)
      top.test
    RUBY
  end

  it 'accepts parentheses for methods starting with an upcase letter' do
    expect_no_offenses('Test()')
  end

  it 'accepts parens in method call with args' do
    expect_no_offenses('top.test(a)')
  end

  it 'accepts special lambda call syntax' do
    # Style/LambdaCall checks for this syntax
    expect_no_offenses('thing.()')
  end

  it 'accepts parens after not' do
    expect_no_offenses('not(something)')
  end

  it 'does not register an offense when using `it()` in a single line block' do
    # `Lint/ItWithoutArgumentsInBlock` respects for this syntax.
    expect_no_offenses(<<~RUBY)
      0.times { it() }
    RUBY
  end

  it 'registers an offense when using `foo.it()` in a single line block' do
    # `Lint/ItWithoutArgumentsInBlock` respects for this syntax.
    expect_offense(<<~RUBY)
      0.times { foo.it() }
                      ^^ Do not use parentheses for method calls with no arguments.
    RUBY

    expect_correction(<<~RUBY)
      0.times { foo.it }
    RUBY
  end

  it 'registers an offense when using `foo&.it()` in a single line block' do
    # `Lint/ItWithoutArgumentsInBlock` respects for this syntax.
    expect_offense(<<~RUBY)
      0.times { foo&.it() }
                       ^^ Do not use parentheses for method calls with no arguments.
    RUBY

    expect_correction(<<~RUBY)
      0.times { foo&.it }
    RUBY
  end

  it 'does not register an offense when using `it()` in a multiline block' do
    # `Lint/ItWithoutArgumentsInBlock` respects for this syntax.
    expect_no_offenses(<<~RUBY)
      0.times do
        it()
        it = 1
        it
      end
    RUBY
  end

  it 'registers an offense when using `it` without arguments in `def` body' do
    expect_offense(<<~RUBY)
      def foo
        it()
          ^^ Do not use parentheses for method calls with no arguments.
      end
    RUBY

    expect_correction(<<~RUBY)
      def foo
        it
      end
    RUBY
  end

  it 'registers an offense when using `it` without arguments in the block with empty block parameter' do
    expect_offense(<<~RUBY)
      0.times { ||
        it()
          ^^ Do not use parentheses for method calls with no arguments.
      }
    RUBY

    expect_correction(<<~RUBY)
      0.times { ||
        it
      }
    RUBY
  end

  it 'registers an offense when using `it` without arguments in the block with useless block parameter' do
    expect_offense(<<~RUBY)
      0.times { |_n|
        it()
          ^^ Do not use parentheses for method calls with no arguments.
      }
    RUBY

    expect_correction(<<~RUBY)
      0.times { |_n|
        it
      }
    RUBY
  end

  context 'when AllowedMethods is enabled' do
    let(:cop_config) { { 'AllowedMethods' => %w[s] } }

    it 'allows a listed method' do
      expect_no_offenses('s()')
    end

    it 'allows a listed method used with safe navigation' do
      expect_no_offenses('foo&.s()')
    end
  end

  context 'when AllowedPatterns is enabled' do
    let(:cop_config) { { 'AllowedPatterns' => ['test'] } }

    it 'allows a method that matches' do
      expect_no_offenses('my_test()')
    end

    it 'allows a method that matches with safe navigation' do
      expect_no_offenses('foo&.my_test()')
    end
  end

  context 'assignment to a variable with the same name' do
    it 'accepts parens in local variable assignment' do
      expect_no_offenses('test = test()')
    end

    it 'registers an offense when calling method on a receiver' do
      expect_offense(<<~RUBY)
        test = x.test()
                     ^^ Do not use parentheses for method calls with no arguments.
      RUBY

      expect_correction(<<~RUBY)
        test = x.test
      RUBY
    end

    it 'registers an offense when calling method on a receiver with safe navigation' do
      expect_offense(<<~RUBY)
        test = x&.test()
                      ^^ Do not use parentheses for method calls with no arguments.
      RUBY

      expect_correction(<<~RUBY)
        test = x&.test
      RUBY
    end

    it 'accepts parens in default argument assignment' do
      expect_no_offenses(<<~RUBY)
        def foo(test = test())
        end
      RUBY
    end

    it 'accepts parens in shorthand assignment' do
      expect_no_offenses('test ||= test()')
    end

    it 'accepts parens in parallel assignment' do
      expect_no_offenses('one, test = 1, test()')
    end

    it 'accepts parens in complex assignment' do
      expect_no_offenses(<<~RUBY)
        test = begin
          case a
          when b
            c = test() if d
          end
        end
      RUBY
    end

    it 'registers an empty parens offense for array mass assignment with same name' do
      expect_offense(<<~RUBY)
        A = [1, 2]
        def c; A; end

        c[2], x = c()
                   ^^ Do not use parentheses for method calls with no arguments.
      RUBY

      expect_correction(<<~RUBY)
        A = [1, 2]
        def c; A; end

        c[2], x = c
      RUBY
    end
  end

  it 'registers an offense for `obj.method ||= func()`' do
    expect_offense(<<~RUBY)
      obj.method ||= func()
                         ^^ Do not use parentheses for method calls with no arguments.
    RUBY

    expect_correction(<<~RUBY)
      obj.method ||= func
    RUBY
  end

  it 'registers an offense for `obj.method &&= func()`' do
    expect_offense(<<~RUBY)
      obj.method &&= func()
                         ^^ Do not use parentheses for method calls with no arguments.
    RUBY

    expect_correction(<<~RUBY)
      obj.method &&= func
    RUBY
  end

  it 'registers an offense for `obj.method += func()`' do
    expect_offense(<<~RUBY)
      obj.method += func()
                        ^^ Do not use parentheses for method calls with no arguments.
    RUBY

    expect_correction(<<~RUBY)
      obj.method += func
    RUBY
  end

  # These will be offenses for the EmptyLiteral cop. The autocorrect loop will
  # handle that.
  it 'autocorrects calls that could be empty literals' do
    expect_offense(<<~RUBY)
      Hash.new()
              ^^ Do not use parentheses for method calls with no arguments.
      Array.new()
               ^^ Do not use parentheses for method calls with no arguments.
      String.new()
                ^^ Do not use parentheses for method calls with no arguments.
    RUBY

    expect_correction(<<~RUBY)
      Hash.new
      Array.new
      String.new
    RUBY
  end

  context 'method call as argument' do
    it 'accepts without parens' do
      expect_no_offenses('_a = c(d.e)')
    end

    it 'registers an offense with empty parens' do
      expect_offense(<<~RUBY)
        _a = c(d())
                ^^ Do not use parentheses for method calls with no arguments.
      RUBY

      expect_correction(<<~RUBY)
        _a = c(d)
      RUBY
    end

    it 'registers an empty parens offense for multiple assignment' do
      expect_offense(<<~RUBY)
        _a, _b, _c = d(e())
                        ^^ Do not use parentheses for method calls with no arguments.
      RUBY

      expect_correction(<<~RUBY)
        _a, _b, _c = d(e)
      RUBY
    end

    it 'registers an empty parens offense for multiple assignment with safe navigation' do
      expect_offense(<<~RUBY)
        _a, _b, _c = d&.e()
                         ^^ Do not use parentheses for method calls with no arguments.
      RUBY

      expect_correction(<<~RUBY)
        _a, _b, _c = d&.e
      RUBY
    end
  end

  it 'registers an empty parens offense for hash mass assignment' do
    expect_offense(<<~RUBY)
      h = {}
      h[:a], h[:b] = c()
                      ^^ Do not use parentheses for method calls with no arguments.
    RUBY

    expect_correction(<<~RUBY)
      h = {}
      h[:a], h[:b] = c
    RUBY
  end

  it 'registers an empty parens offense for array mass assignment' do
    expect_offense(<<~RUBY)
      a = []
      a[0], a[10] = c()
                     ^^ Do not use parentheses for method calls with no arguments.
    RUBY

    expect_correction(<<~RUBY)
      a = []
      a[0], a[10] = c
    RUBY
  end
end
