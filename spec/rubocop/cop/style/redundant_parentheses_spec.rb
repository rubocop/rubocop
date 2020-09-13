# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::RedundantParentheses do
  subject(:cop) { described_class.new }

  shared_examples 'redundant' do |expr, correct, type|
    it "registers an offense for parentheses around #{type}" do
      expect_offense(<<~RUBY, expr: expr)
        %{expr}
        ^{expr} Don't use parentheses around #{type}.
      RUBY

      expect_correction(<<~RUBY)
        #{correct}
      RUBY
    end
  end

  shared_examples 'plausible' do |expr|
    it 'accepts parentheses when arguments are unparenthesized' do
      expect_no_offenses(expr)
    end
  end

  shared_examples 'keyword with return value' do |keyword|
    it_behaves_like 'redundant', "(#{keyword})", keyword, 'a keyword'
    it_behaves_like 'redundant', "(#{keyword}())", "#{keyword}()", 'a keyword'
    it_behaves_like 'redundant', "(#{keyword}(1))", "#{keyword}(1)", 'a keyword'
    it_behaves_like 'plausible', "(#{keyword} 1, 2)"
  end

  shared_examples 'keyword with arguments' do |keyword|
    it_behaves_like 'redundant', "(#{keyword})", keyword, 'a keyword'
    it_behaves_like 'redundant', "(#{keyword}())", "#{keyword}()", 'a keyword'
    it_behaves_like 'redundant', "(#{keyword}(1, 2))", "#{keyword}(1, 2)",
                    'a keyword'
    it_behaves_like 'plausible', "(#{keyword} 1, 2)"
  end

  it_behaves_like 'redundant', '("x")', '"x"', 'a literal'
  it_behaves_like 'redundant', '("#{x}")', '"#{x}"', 'a literal'
  it_behaves_like 'redundant', '(:x)', ':x', 'a literal'
  it_behaves_like 'redundant', '(:"#{x}")', ':"#{x}"', 'a literal'
  it_behaves_like 'redundant', '(1)', '1', 'a literal'
  it_behaves_like 'redundant', '(1.2)', '1.2', 'a literal'
  it_behaves_like 'redundant', '({})', '{}', 'a literal'
  it_behaves_like 'redundant', '([])', '[]', 'a literal'
  it_behaves_like 'redundant', '(nil)', 'nil', 'a literal'
  it_behaves_like 'redundant', '(true)', 'true', 'a literal'
  it_behaves_like 'redundant', '(false)', 'false', 'a literal'
  it_behaves_like 'redundant', '(/regexp/)', '/regexp/', 'a literal'
  it_behaves_like 'redundant', '("x"; "y")', '"x"; "y"', 'a literal'
  it_behaves_like 'redundant', '(1; 2)', '1; 2', 'a literal'
  it_behaves_like 'redundant', '(1i)', '1i', 'a literal'
  it_behaves_like 'redundant', '(1r)', '1r', 'a literal'
  it_behaves_like 'redundant', '(__FILE__)', '__FILE__', 'a keyword'
  it_behaves_like 'redundant', '(__LINE__)', '__LINE__', 'a keyword'
  it_behaves_like 'redundant', '(__ENCODING__)', '__ENCODING__', 'a keyword'
  it_behaves_like 'redundant', '(redo)', 'redo', 'a keyword'
  it_behaves_like 'redundant', '(retry)', 'retry', 'a keyword'
  it_behaves_like 'redundant', '(self)', 'self', 'a keyword'

  it 'registers an offense for parens around constant ternary condition' do
    expect_offense(<<~RUBY)
      (X) ? Y : N
      ^^^ Don't use parentheses around a constant.
      (X)? Y : N
      ^^^ Don't use parentheses around a constant.
    RUBY

    expect_correction(<<~RUBY)
      X ? Y : N
      X ? Y : N
    RUBY
  end

  it_behaves_like 'keyword with return value', 'break'
  it_behaves_like 'keyword with return value', 'next'
  it_behaves_like 'keyword with return value', 'return'

  it_behaves_like 'keyword with arguments', 'super'
  it_behaves_like 'keyword with arguments', 'yield'

  it_behaves_like 'redundant', '(defined?(:A))', 'defined?(:A)', 'a keyword'
  it_behaves_like 'plausible', '(defined? :A)'

  it_behaves_like 'plausible', '(alias a b)'
  it_behaves_like 'plausible', '(not 1)'
  it_behaves_like 'plausible', '(a until b)'
  it_behaves_like 'plausible', '(a while b)'

  it 'registers an offense for parens around a variable after semicolon' do
    expect_offense(<<~RUBY)
      x = 1; (x)
             ^^^ Don't use parentheses around a variable.
    RUBY

    expect_correction(<<~RUBY)
      x = 1; x
    RUBY
  end

  it_behaves_like 'redundant', '(@x)', '@x', 'a variable'
  it_behaves_like 'redundant', '(@@x)', '@@x', 'a variable'
  it_behaves_like 'redundant', '($x)', '$x', 'a variable'

  it_behaves_like 'redundant', '(X)', 'X', 'a constant'

  it_behaves_like 'redundant', '(x)', 'x', 'a method call'
  it_behaves_like 'redundant', '(x(1, 2))', 'x(1, 2)', 'a method call'
  it_behaves_like 'redundant', '("x".to_sym)', '"x".to_sym', 'a method call'
  it_behaves_like 'redundant', '("x"&.to_sym)', '"x"&.to_sym', 'a method call'
  it_behaves_like 'redundant', '(x[:y])', 'x[:y]', 'a method call'
  it_behaves_like 'redundant', '("foo"[0])', '"foo"[0]', 'a method call'
  it_behaves_like 'redundant', '(["foo"][0])', '["foo"][0]', 'a method call'
  it_behaves_like 'redundant', '({0 => :a}[0])', '{0 => :a}[0]', 'a method call'
  it_behaves_like 'redundant', '(x; y)', 'x; y', 'a method call'

  it_behaves_like 'redundant', '(!x)', '!x', 'an unary operation'
  it_behaves_like 'redundant', '(~x)', '~x', 'an unary operation'
  it_behaves_like 'redundant', '(-x)', '-x', 'an unary operation'
  it_behaves_like 'redundant', '(+x)', '+x', 'an unary operation'
  it_behaves_like 'plausible', '(!x.m arg)'
  it_behaves_like 'plausible', '(!x).y'
  it_behaves_like 'plausible', '-(1.foo)'
  it_behaves_like 'plausible', '+(1.foo)'
  it_behaves_like 'plausible', '-(1.foo.bar)'
  it_behaves_like 'plausible', '+(1.foo.bar)'
  it_behaves_like 'plausible', '()'

  it 'registers an offense for parens around a literal in array' do
    expect_offense(<<~RUBY)
      [(1)]
       ^^^ Don't use parentheses around a literal.
    RUBY

    expect_correction(<<~RUBY)
      [1]
    RUBY
  end

  it 'registers an offense for parens around a literal in array ' \
     'and following newline' do
    expect_offense(<<~RUBY)
      [(1
       ^^ Don't use parentheses around a literal.
      )]
    RUBY

    expect_correction(<<~RUBY)
      [1
      ]
    RUBY
  end

  it_behaves_like 'plausible', "[(1\n),]"

  it 'registers an offense for parens around a literal hash value' do
    expect_offense(<<~RUBY)
      {a: (1)}
          ^^^ Don't use parentheses around a literal.
    RUBY

    expect_correction(<<~RUBY)
      {a: 1}
    RUBY
  end

  it 'registers an offense for parens around a literal hash value ' \
     'and following newline' do
    expect_offense(<<~RUBY)
      {a: (1
          ^^ Don't use parentheses around a literal.
      )}
    RUBY

    expect_correction(<<~RUBY)
      {a: 1
      }
    RUBY
  end

  it_behaves_like 'plausible', "{a: (1\n),}"

  it 'registers an offense for parens around an integer exponentiation base' do
    expect_offense(<<~RUBY)
      (0)**2
      ^^^ Don't use parentheses around a literal.
      (2)**2
      ^^^ Don't use parentheses around a literal.
    RUBY

    expect_correction(<<~RUBY)
      0**2
      2**2
    RUBY
  end

  it 'registers an offense for parens around a float exponentiation base' do
    expect_offense(<<~RUBY)
      (2.1)**2
      ^^^^^ Don't use parentheses around a literal.
    RUBY

    expect_correction(<<~RUBY)
      2.1**2
    RUBY
  end

  it 'registers an offense for parens around a negative exponent' do
    expect_offense(<<~RUBY)
      2**(-2)
         ^^^^ Don't use parentheses around a literal.
    RUBY

    expect_correction(<<~RUBY)
      2**-2
    RUBY
  end

  it 'registers an offense for parens around a positive exponent' do
    expect_offense(<<~RUBY)
      2**(2)
         ^^^ Don't use parentheses around a literal.
    RUBY

    expect_correction(<<~RUBY)
      2**2
    RUBY
  end

  it_behaves_like 'plausible', '(-2)**2'
  it_behaves_like 'plausible', '(-2.1)**2'

  it_behaves_like 'plausible', 'x = (foo; bar)'
  it_behaves_like 'plausible', 'x += (foo; bar)'
  it_behaves_like 'plausible', 'x + (foo; bar)'
  it_behaves_like 'plausible', 'x((foo; bar))'

  it 'registers an offense for parens around method body' do
    expect_offense(<<~RUBY)
      def x
        (foo; bar)
        ^^^^^^^^^^ Don't use parentheses around a method call.
      end
    RUBY

    expect_correction(<<~RUBY)
      def x
        foo; bar
      end
    RUBY
  end

  it 'registers an offense for parens around last expressions in method body' do
    expect_offense(<<~RUBY)
      def x
        baz
        (foo; bar)
        ^^^^^^^^^^ Don't use parentheses around a method call.
      end
    RUBY

    expect_correction(<<~RUBY)
      def x
        baz
        foo; bar
      end
    RUBY
  end

  it 'registers an offense for parens around a block body' do
    expect_offense(<<~RUBY)
      x do
        (foo; bar)
        ^^^^^^^^^^ Don't use parentheses around a method call.
      end
    RUBY

    expect_correction(<<~RUBY)
      x do
        foo; bar
      end
    RUBY
  end

  it 'registers an offense for parens around last expressions in block body' do
    expect_offense(<<~RUBY)
      x do
        baz
        (foo; bar)
        ^^^^^^^^^^ Don't use parentheses around a method call.
      end
    RUBY

    expect_correction(<<~RUBY)
      x do
        baz
        foo; bar
      end
    RUBY
  end

  it 'accepts parentheses around a method call with unparenthesized ' \
     'arguments' do
    expect_no_offenses('(a 1, 2) && (1 + 1)')
  end

  it 'accepts parentheses inside an irange' do
    expect_no_offenses('(a)..(b)')
  end

  it 'accepts parentheses inside an erange' do
    expect_no_offenses('(a)...(b)')
  end

  it 'accepts parentheses around an irange' do
    expect_no_offenses('(a..b)')
  end

  it 'accepts parentheses around an erange' do
    expect_no_offenses('(a...b)')
  end

  it 'accepts parentheses around operator keywords' do
    expect_no_offenses('(1 and 2) and (3 or 4)')
  end

  it 'registers an offense when there is space around the parentheses' do
    expect_offense(<<~RUBY)
      if x; y else (1) end
                   ^^^ Don't use parentheses around a literal.
    RUBY
  end

  it 'accepts parentheses when enclosed in parentheses at `while-post`' do
    expect_no_offenses(<<~RUBY)
      begin
        do_something
      end while(bar)
    RUBY
  end

  it 'accepts parentheses when enclosed in parentheses at `until-post`' do
    expect_no_offenses(<<~RUBY)
      begin
        do_something
      end until(bar)
    RUBY
  end

  it 'accepts parentheses when they touch the preceding keyword' do
    expect_no_offenses('if x; y else(1) end')
  end

  it 'accepts parentheses when they touch the following keyword' do
    expect_no_offenses('if x; y else (1)end')
  end

  context 'when the first argument in a method call begins with a hash '\
          'literal' do
    it 'accepts parentheses if the argument list is not parenthesized ' do
      expect_no_offenses('x ({ y: 1 }), z')
      expect_no_offenses('x ({ y: 1 }.merge({ y: 2 })), z')
      expect_no_offenses('x ({ y: 1 }.merge({ y: 2 }).merge({ y: 3 })), z')
    end

    it 'registers an offense if the argument list is parenthesized ' do
      expect_offense(<<~RUBY)
        x(({ y: 1 }), z)
          ^^^^^^^^^^ Don't use parentheses around a literal.
      RUBY
    end
  end

  context 'when a hash literal is the second argument in a method call' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        x ({ y: 1 }), ({ y: 1 })
                      ^^^^^^^^^^ Don't use parentheses around a literal.
      RUBY
    end
  end

  context 'when a non-parenthesized call has an arg and a block' do
    it 'accepts parens around the arg' do
      expect_no_offenses('method (:arg) { blah }')
    end
  end

  context 'when parentheses are used like method argument parentheses' do
    it 'accepts parens around the arg' do
      expect_no_offenses('method (arg)')
    end
  end

  it 'accepts parentheses around the error passed to rescue' do
    expect_no_offenses(<<~RUBY)
      begin
        some_method
      rescue(StandardError)
      end
    RUBY
  end

  it 'accepts parentheses around a constant passed to when' do
    expect_no_offenses(<<~RUBY)
      case foo
      when(Const)
        bar
      end
    RUBY
  end

  it 'accepts parentheses in super call with hash' do
    expect_no_offenses(<<~RUBY)
      super ({
        foo: bar,
      })
    RUBY
  end

  it 'accepts parentheses in yield call with hash' do
    expect_no_offenses(<<~RUBY)
      yield ({
        foo: bar,
      })
    RUBY
  end
end
