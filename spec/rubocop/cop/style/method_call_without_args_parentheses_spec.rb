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

  context 'when AllowedMethods is enabled' do
    let(:cop_config) { { 'AllowedMethods' => %w[s] } }

    it 'ignores method listed in AllowedMethods' do
      expect_no_offenses('s()')
    end
  end

  context 'when AllowedPatterns is enabled' do
    let(:cop_config) { { 'AllowedPatterns' => ['test'] } }

    it 'ignores method listed in AllowedMethods' do
      expect_no_offenses('my_test()')
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
  end
end
