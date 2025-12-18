# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::RedundantParentheses, :config do
  shared_examples 'redundant' do |expr, correct, type, options|
    it "registers an offense for parentheses around #{type}", *options do
      expect_offense(<<~RUBY, expr: expr)
        %{expr}
        ^{expr} Don't use parentheses around #{type}.
      RUBY

      expect_correction(<<~RUBY)
        #{correct}
      RUBY
    end
  end

  shared_examples 'plausible' do |expr, options|
    it 'accepts parentheses when arguments are unparenthesized', *options do
      expect_no_offenses(expr)
    end
  end

  shared_examples 'keyword with return value' do |keyword, options|
    it_behaves_like 'redundant', "(#{keyword})", keyword, 'a keyword', options
    it_behaves_like 'redundant', "(#{keyword}())", "#{keyword}()", 'a keyword', options
    it_behaves_like 'redundant', "(#{keyword}(1))", "#{keyword}(1)", 'a keyword', options
    it_behaves_like 'plausible', "(#{keyword} 1, 2)", options
  end

  shared_examples 'keyword with arguments' do |keyword|
    it_behaves_like 'redundant', "(#{keyword})", keyword, 'a keyword'
    it_behaves_like 'redundant', "(#{keyword}())", "#{keyword}()", 'a keyword'
    it_behaves_like 'redundant', "(#{keyword}(1, 2))", "#{keyword}(1, 2)", 'a keyword'
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
  it_behaves_like 'redundant', '((1..42))', '(1..42)', 'a literal'
  it_behaves_like 'redundant', '((1...42))', '(1...42)', 'a literal'
  it_behaves_like 'redundant', '((1..))', '(1..)', 'a literal'
  it_behaves_like 'redundant', '((..42))', '(..42)', 'a literal'
  it_behaves_like 'redundant', '(__FILE__)', '__FILE__', 'a keyword'
  it_behaves_like 'redundant', '(__LINE__)', '__LINE__', 'a keyword'
  it_behaves_like 'redundant', '(__ENCODING__)', '__ENCODING__', 'a keyword'
  it_behaves_like 'redundant', '(redo)', 'redo', 'a keyword', [:ruby32, { unsupported_on: :prism }]

  context 'Ruby <= 3.2', :ruby32, unsupported_on: :prism do
    it_behaves_like 'redundant', '(retry)', 'retry', 'a keyword'
  end

  it_behaves_like 'redundant', '(self)', 'self', 'a keyword'

  context 'ternaries' do
    let(:other_cops) do
      {
        'Style/TernaryParentheses' => {
          'Enabled' => ternary_parentheses_enabled,
          'EnforcedStyle' => ternary_parentheses_enforced_style
        }
      }
    end
    let(:ternary_parentheses_enabled) { true }
    let(:ternary_parentheses_enforced_style) { nil }

    context 'when Style/TernaryParentheses is not enabled' do
      let(:ternary_parentheses_enabled) { false }

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
    end

    context 'when Style/TernaryParentheses has EnforcedStyle: require_no_parentheses' do
      let(:ternary_parentheses_enforced_style) { 'require_no_parentheses' }

      it 'registers an offense for parens around ternary condition' do
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
    end

    context 'when Style/TernaryParentheses has EnforcedStyle: require_parentheses' do
      let(:ternary_parentheses_enforced_style) { 'require_parentheses' }

      it_behaves_like 'plausible', '(X) ? Y : N'
    end

    context 'when Style/TernaryParentheses has EnforcedStyle: require_parentheses_when_complex' do
      let(:ternary_parentheses_enforced_style) { 'require_parentheses_when_complex' }

      it_behaves_like 'plausible', '(X) ? Y : N'
    end
  end

  it_behaves_like 'keyword with return value', 'break', [:ruby32, { unsupported_on: :prism }]
  it_behaves_like 'keyword with return value', 'next', [:ruby32, { unsupported_on: :prism }]
  it_behaves_like 'keyword with arguments', 'yield'

  it_behaves_like 'keyword with return value', 'return'

  it_behaves_like 'keyword with arguments', 'super'

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

  it_behaves_like 'redundant', '(-> { x })', '-> { x }', 'an expression'
  it_behaves_like 'redundant', '(lambda { x })', 'lambda { x }', 'an expression'
  it_behaves_like 'redundant', '(proc { x })', 'proc { x }', 'an expression'

  it_behaves_like 'redundant', '(x)', 'x', 'a method call'
  it_behaves_like 'redundant', '(x y)', 'x y', 'a method call'
  it_behaves_like 'redundant', '(x(1, 2))', 'x(1, 2)', 'a method call'
  it_behaves_like 'redundant', '("x".to_sym)', '"x".to_sym', 'a method call'
  it_behaves_like 'redundant', '("x"&.to_sym)', '"x"&.to_sym', 'a method call'
  it_behaves_like 'redundant', '(x[:y])', 'x[:y]', 'a method call'
  it_behaves_like 'redundant', '(@x[:y])', '@x[:y]', 'a method call'
  it_behaves_like 'redundant', '(@@x[:y])', '@@x[:y]', 'a method call'
  it_behaves_like 'redundant', '($x[:y])', '$x[:y]', 'a method call'
  it_behaves_like 'redundant', '(X[:y])', 'X[:y]', 'a method call'
  it_behaves_like 'redundant', '("foo"[0])', '"foo"[0]', 'a method call'
  it_behaves_like 'redundant', '(foo[0][0])', 'foo[0][0]', 'a method call'
  it_behaves_like 'redundant', '(["foo"][0])', '["foo"][0]', 'a method call'
  it_behaves_like 'redundant', '({0 => :a}[0])', '{0 => :a}[0]', 'a method call'
  it_behaves_like 'redundant', '(x; y)', 'x; y', 'a method call'

  it_behaves_like 'redundant', '(x && y)', 'x && y', 'a logical expression'
  it_behaves_like 'redundant', '(x || y)', 'x || y', 'a logical expression'
  it_behaves_like 'redundant', '(x and y)', 'x and y', 'a logical expression'
  it_behaves_like 'redundant', '(x or y)', 'x or y', 'a logical expression'

  it_behaves_like 'redundant', '(x == y)', 'x == y', 'a comparison expression'
  it_behaves_like 'redundant', '(x === y)', 'x === y', 'a comparison expression'
  it_behaves_like 'redundant', '(x != y)', 'x != y', 'a comparison expression'
  it_behaves_like 'redundant', '(x > y)', 'x > y', 'a comparison expression'
  it_behaves_like 'redundant', '(x >= y)', 'x >= y', 'a comparison expression'
  it_behaves_like 'redundant', '(x < y)', 'x < y', 'a comparison expression'
  it_behaves_like 'redundant', '(x <= y)', 'x <= y', 'a comparison expression'

  it_behaves_like 'redundant', '(var = 42)', 'var = 42', 'an assignment'
  it_behaves_like 'redundant', '(@var = 42)', '@var = 42', 'an assignment'
  it_behaves_like 'redundant', '(@@var = 42)', '@@var = 42', 'an assignment'
  it_behaves_like 'redundant', '($var = 42)', '$var = 42', 'an assignment'
  it_behaves_like 'redundant', '(CONST = 42)', 'CONST = 42', 'an assignment'
  it_behaves_like 'plausible', 'if (var = 42); end'
  it_behaves_like 'plausible', 'unless (var = 42); end'
  it_behaves_like 'plausible', 'while (var = 42); end'
  it_behaves_like 'plausible', 'until (var = 42); end'
  it_behaves_like 'plausible', '(var + 42) > do_something'
  it_behaves_like 'plausible', 'foo((bar rescue baz))'

  it_behaves_like 'redundant', '(!x)', '!x', 'a unary operation'
  it_behaves_like 'redundant', '(~x)', '~x', 'a unary operation'
  it_behaves_like 'redundant', '(-x)', '-x', 'a unary operation'
  it_behaves_like 'redundant', '(+x)', '+x', 'a unary operation'

  # No problem removing the parens when it is the only expression.
  it_behaves_like 'redundant', '(!x arg)', '!x arg', 'a unary operation'
  it_behaves_like 'redundant', '(!x.m arg)', '!x.m arg', 'a unary operation'
  it_behaves_like 'redundant', '(!super arg)', '!super arg', 'a unary operation'
  it_behaves_like 'redundant', '(!yield arg)', '!yield arg', 'a unary operation'
  it_behaves_like 'redundant', '(!defined? arg)', '!defined? arg', 'a unary operation'

  # Removing the parens leads to semantic differences.
  it_behaves_like 'plausible', '(!x arg) && foo'
  it_behaves_like 'plausible', '(!x.m arg) && foo'
  it_behaves_like 'plausible', '(!super arg) && foo'
  it_behaves_like 'plausible', '(!yield arg) && foo'
  it_behaves_like 'plausible', '(!defined? arg) && foo'

  # Removing the parens leads to a syntax error.
  it_behaves_like 'plausible', 'foo && (!x arg)'
  it_behaves_like 'plausible', 'foo && (!x.m arg)'
  it_behaves_like 'plausible', 'foo && (!super arg)'
  it_behaves_like 'plausible', 'foo && (!yield arg)'
  it_behaves_like 'plausible', 'foo && (!defined? arg)'

  it_behaves_like 'plausible', '(!x).y'
  it_behaves_like 'plausible', '-(1.foo)'
  it_behaves_like 'plausible', '+(1.foo)'
  it_behaves_like 'plausible', '-(1.foo.bar)'
  it_behaves_like 'plausible', '+(1.foo.bar)'
  it_behaves_like 'plausible', 'foo(*(bar & baz))'
  it_behaves_like 'plausible', 'foo(*(bar + baz))'
  it_behaves_like 'plausible', 'foo(**(bar + baz))'
  it_behaves_like 'plausible', 'foo + (bar baz)'
  it_behaves_like 'plausible', '()'

  it 'registers an offense for parens around a receiver of a method call with an argument' do
    expect_offense(<<~RUBY)
      (x).y(z)
      ^^^ Don't use parentheses around a method call.
    RUBY

    expect_correction(<<~RUBY)
      x.y(z)
    RUBY
  end

  it 'registers an offense for parens around a method argument of a parenthesized method call' do
    expect_offense(<<~RUBY)
      x.y((z))
          ^^^ Don't use parentheses around a method argument.
    RUBY

    expect_correction(<<~RUBY)
      x.y(z)
    RUBY
  end

  it 'registers an offense for parens around a method argument of a parenthesized method call with safe navigation' do
    expect_offense(<<~RUBY)
      x&.y((z))
           ^^^ Don't use parentheses around a method argument.
    RUBY

    expect_correction(<<~RUBY)
      x&.y(z)
    RUBY
  end

  it 'registers an offense for parens around a second method argument of a parenthesized method call' do
    expect_offense(<<~RUBY)
      x.y(z, (w))
             ^^^ Don't use parentheses around a method argument.
    RUBY

    expect_correction(<<~RUBY)
      x.y(z, w)
    RUBY
  end

  it 'registers an offense for parens around a method call with argument and no parens around the argument' do
    expect_offense(<<~RUBY)
      (x y)
      ^^^^^ Don't use parentheses around a method call.
    RUBY

    expect_correction(<<~RUBY)
      x y
    RUBY
  end

  it 'does not register an offense for parens around `if` as the second argument of a parenthesized method call' do
    expect_no_offenses(<<~RUBY)
      x(1, (2 if y?))
    RUBY
  end

  it 'does not register an offense for parens around `unless` as the second argument of a parenthesized method call' do
    expect_no_offenses(<<~RUBY)
      x(1, (2 unless y?))
    RUBY
  end

  it 'does not register an offense for parens around `while` as the second argument of a parenthesized method call' do
    expect_no_offenses(<<~RUBY)
      x(1, (2 while y?))
    RUBY
  end

  it 'does not register an offense for parens around `until` as the second argument of a parenthesized method call' do
    expect_no_offenses(<<~RUBY)
      x(1, (2 until y?))
    RUBY
  end

  it 'does not register an offense for parens around unparenthesized method call as the second argument of a parenthesized method call' do
    expect_no_offenses(<<~RUBY)
      x(1, (y arg))
    RUBY
  end

  it 'does not register an offense for parens around unparenthesized safe navigation method call as the second argument of a parenthesized method call' do
    expect_no_offenses(<<~RUBY)
      x(1, (y&.z arg))
    RUBY
  end

  it 'does not register an offense for parens around unparenthesized operator dot method call as the second argument of a parenthesized method call' do
    expect_no_offenses(<<~RUBY)
      x(1, (y.+ arg))
    RUBY
  end

  it 'does not register an offense for parens around unparenthesized operator safe navigation method call as the second argument of a parenthesized method call' do
    expect_no_offenses(<<~RUBY)
      x(1, (y&.+ arg))
    RUBY
  end

  it 'registers an offense for parens around an expression method argument of a parenthesized method call' do
    expect_offense(<<~RUBY)
      x.y((z + w))
          ^^^^^^^ Don't use parentheses around a method argument.
    RUBY

    expect_correction(<<~RUBY)
      x.y(z + w)
    RUBY
  end

  it 'registers an offense for parens around a range method argument of a parenthesized method call' do
    expect_offense(<<~RUBY)
      x.y((a..b))
          ^^^^^^ Don't use parentheses around a method argument.
    RUBY

    expect_correction(<<~RUBY)
      x.y(a..b)
    RUBY
  end

  it 'registers an offense for parens around a multiline method argument of a parenthesized method call' do
    expect_offense(<<~RUBY)
      x.y((foo &&
          ^^^^^^^ Don't use parentheses around a method argument.
        bar
      ))
    RUBY

    expect_correction(<<~RUBY)
      x.y(foo &&
        bar)
    RUBY
  end

  it 'registers an offense for parens around method call chained to an `&&` expression' do
    # Style/MultipleComparison autocorrects:
    # (
    #   foo == 'a' ||
    #   foo == 'b' ||
    #   foo == 'c'
    # ) && bar
    # to the following:
    expect_offense(<<~RUBY)
      (
      ^ Don't use parentheses around a method call.
        ['a', 'b', 'c'].include?(foo)
      ) && bar
    RUBY

    expect_correction(<<~RUBY)
      ['a', 'b', 'c'].include?(foo) && bar
    RUBY
  end

  it 'does not register an offense for parens around an array destructuring argument in method definition' do
    expect_no_offenses('def foo((bar, baz)); end')
  end

  it 'registers an offense for parens around parenthesized conditional assignment' do
    expect_offense(<<~RUBY)
      if ((var = 42))
          ^^^^^^^^^^ Don't use parentheses around an assignment.
      end
    RUBY

    expect_correction(<<~RUBY)
      if (var = 42)
      end
    RUBY
  end

  it 'registers an offense for parens around an interpolated expression' do
    expect_offense(<<~RUBY)
      "\#{(foo)}"
         ^^^^^ Don't use parentheses around an interpolated expression.
    RUBY

    expect_correction(<<~RUBY)
      "\#{foo}"
    RUBY
  end

  it 'registers an offense for parens around a literal in array' do
    expect_offense(<<~RUBY)
      [(1)]
       ^^^ Don't use parentheses around a literal.
    RUBY

    expect_correction(<<~RUBY)
      [1]
    RUBY
  end

  it 'registers an offense for parens around a literal in array and following newline' do
    expect_offense(<<~RUBY)
      [(1
       ^^ Don't use parentheses around a literal.
      )]
    RUBY

    expect_correction(<<~RUBY)
      [1]
    RUBY
  end

  it 'registers an offense for parens around a binary operator in an array' do
    expect_offense(<<~RUBY)
      [(foo + bar)]
       ^^^^^^^^^^^ Don't use parentheses around a method call.
    RUBY

    expect_correction(<<~RUBY)
      [foo + bar]
    RUBY
  end

  context 'literals in an array' do
    context 'when there is a comma on the same line as the closing parentheses' do
      it 'registers an offense and corrects when there is no subsequent item' do
        expect_offense(<<~RUBY)
          [
            (
            ^ Don't use parentheses around a literal.
              1
            )
          ]
        RUBY

        expect_correction(<<~RUBY)
          [
            1
          ]
        RUBY
      end

      it 'registers an offense and corrects when there is a trailing comma' do
        expect_offense(<<~RUBY)
          [(1
           ^^ Don't use parentheses around a literal.
          ),]
        RUBY

        expect_correction(<<~RUBY)
          [1,]
        RUBY
      end

      it 'registers an offense and corrects when there is a subsequent item' do
        expect_offense(<<~RUBY)
          [
            (
            ^ Don't use parentheses around a literal.
              1
            ),
            2
          ]
        RUBY

        expect_correction(<<~RUBY)
          [
            1,
            2
          ]
        RUBY
      end

      it 'registers an offense and corrects when there is assignment' do
        expect_offense(<<~RUBY)
          [
            x = (
                ^ Don't use parentheses around a literal.
              1
            ),
            y = 2
          ]
        RUBY

        expect_correction(<<~RUBY)
          [
            x = 1,
            y = 2
          ]
        RUBY
      end
    end
  end

  it 'registers an offense for parens around a literal hash value' do
    expect_offense(<<~RUBY)
      {a: (1)}
          ^^^ Don't use parentheses around a literal.
    RUBY

    expect_correction(<<~RUBY)
      {a: 1}
    RUBY
  end

  it 'registers an offense for parens around a literal hash value and following newline' do
    expect_offense(<<~RUBY)
      {a: (1
          ^^ Don't use parentheses around a literal.
      )}
    RUBY

    expect_correction(<<~RUBY)
      {a: 1}
    RUBY
  end

  it 'registers an offense and corrects for a parenthesized item in a hash where ' \
     'the comma is on a line with the closing parens' do
    expect_offense(<<~RUBY)
      { a: (1
           ^^ Don't use parentheses around a literal.
      ),}
    RUBY

    expect_correction(<<~RUBY)
      { a: 1,}
    RUBY
  end

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

  it 'registers an offense for parens around `->` with `do`...`end` block' do
    expect_offense(<<~RUBY)
      scope :my_scope, (-> do
                       ^^^^^^ Don't use parentheses around an expression.
        where(column: :value)
      end)
    RUBY

    expect_correction(<<~RUBY)
      scope :my_scope, -> do
        where(column: :value)
      end
    RUBY
  end

  it 'registers an offense for parens around `lambda` with `{`...`}` block' do
    expect_offense(<<~RUBY)
      scope :my_scope, (lambda {
                       ^^^^^^^^^ Don't use parentheses around an expression.
        where(column: :value)
      })
    RUBY

    expect_correction(<<~RUBY)
      scope :my_scope, lambda {
        where(column: :value)
      }
    RUBY
  end

  it 'registers an offense for parens around `proc` with `{`...`}` block' do
    expect_offense(<<~RUBY)
      scope :my_scope, (proc {
                       ^^^^^^^ Don't use parentheses around an expression.
        where(column: :value)
      })
    RUBY

    expect_correction(<<~RUBY)
      scope :my_scope, proc {
        where(column: :value)
      }
    RUBY
  end

  it 'does not register an offense for parens around `lambda` with `do`...`end` block' do
    expect_no_offenses(<<~RUBY)
      scope :my_scope, (lambda do
        where(column: :value)
      end)
    RUBY
  end

  it 'does not register an offense for parens around `proc` with `do`...`end` block' do
    expect_no_offenses(<<~RUBY)
      scope :my_scope, (proc do
        where(column: :value)
      end)
    RUBY
  end

  it 'registers an offense for parentheses around a method chain with `{`...`}` block in keyword argument' do
    expect_offense(<<~RUBY)
      foo bar: (baz {
               ^^^^^^ Don't use parentheses around a method call.
      }.qux)
    RUBY
  end

  it 'registers an offense for parentheses around a method chain with `{`...`}` numblock in keyword argument' do
    expect_offense(<<~RUBY)
      foo bar: (baz {
               ^^^^^^ Don't use parentheses around a method call.
        do_something(_1)
      }.qux)
    RUBY
  end

  it 'does not register an offense for parentheses around a method chain with `do`...`end` block in keyword argument' do
    expect_no_offenses(<<~RUBY)
      foo bar: (baz do
      end.qux)
    RUBY
  end

  it 'does not register an offense for parentheses around method chains with `do`...`end` block in keyword argument' do
    expect_no_offenses(<<~RUBY)
      foo bar: (baz do
      end.qux.quux)
    RUBY
  end

  it 'does not register an offense for parentheses around a method chain with `do`...`end` numblock in keyword argument' do
    expect_no_offenses(<<~RUBY)
      foo bar: (baz do
        do_something(_1)
      end.qux)
    RUBY
  end

  it 'does not register an offense for parentheses around a method chain with `do`...`end` block in keyword argument for safe navigation call' do
    expect_no_offenses(<<~RUBY)
      obj&.foo bar: (baz do
      end.qux)
    RUBY
  end

  it 'does not register an offense for parentheses around a method chain with `do`...`end` numblock in keyword argument for safe navigation call' do
    expect_no_offenses(<<~RUBY)
      obj&.foo bar: (baz do
        do_something(_1)
      end.qux)
    RUBY
  end

  it 'registers an offense when braces block is wrapped in parentheses as a method argument' do
    expect_offense(<<~RUBY)
      foo (x.select { |item| item }).y
          ^^^^^^^^^^^^^^^^^^^^^^^^^^ Don't use parentheses around a method call.
    RUBY

    expect_correction(<<~RUBY)
      foo x.select { |item| item }.y
    RUBY
  end

  it 'does not register an offense when `do`...`end` block is wrapped in parentheses as a method argument' do
    expect_no_offenses(<<~RUBY)
      foo (x.select do |item| item end).y
    RUBY
  end

  it 'registers a multiline expression around block wrapped in parens with a chained method' do
    expect_offense(<<~RUBY)
      (
      ^ Don't use parentheses around a method call.
        x.select { |item| item.foo }
      ).map(&:bar)
    RUBY

    expect_correction(<<~RUBY)
      x.select { |item| item.foo }.map(&:bar)
    RUBY
  end

  it_behaves_like 'redundant', '(x.select { |item| item })', 'x.select { |item| item }', 'a method call'

  context 'when Ruby 2.7', :ruby27 do
    it_behaves_like 'redundant', '(x.select { _1 })', 'x.select { _1 }', 'a method call'
  end

  context 'when Ruby 3.4', :ruby34 do
    it_behaves_like 'redundant', '(x.select { it })', 'x.select { it }', 'a method call'
  end

  it_behaves_like 'plausible', '(-2)**2'
  it_behaves_like 'plausible', '(-2.1)**2'

  it_behaves_like 'plausible', 'x = (foo; bar)'
  it_behaves_like 'plausible', 'x += (foo; bar)'
  it_behaves_like 'plausible', 'x + (foo; bar)'
  it_behaves_like 'plausible', 'x((foo; bar))'

  it_behaves_like 'plausible', '(foo[key] & bar.baz).any?'

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

  it 'registers an offense for parens around singleton method body' do
    expect_offense(<<~RUBY)
      def self.x
        (foo; bar)
        ^^^^^^^^^^ Don't use parentheses around a method call.
      end
    RUBY

    expect_correction(<<~RUBY)
      def self.x
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

  it 'registers an offense for parens around a numblock body' do
    expect_offense(<<~RUBY)
      x do
        (_1; bar)
        ^^^^^^^^^ Don't use parentheses around a variable.
      end
    RUBY

    expect_correction(<<~RUBY)
      x do
        _1; bar
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

  it 'registers an offense when the use of parentheses around `&&` expressions in assignment' do
    expect_offense(<<~RUBY)
      var = (foo && bar)
            ^^^^^^^^^^^^ Don't use parentheses around a logical expression.
    RUBY

    expect_correction(<<~RUBY)
      var = foo && bar
    RUBY
  end

  it 'registers an offense when the use of parentheses around `||` expressions in assignment' do
    expect_offense(<<~RUBY)
      var = (foo || bar)
            ^^^^^^^^^^^^ Don't use parentheses around a logical expression.
    RUBY

    expect_correction(<<~RUBY)
      var = foo || bar
    RUBY
  end

  it 'accepts the use of parentheses around `or` expressions in assignment' do
    expect_no_offenses('var = (foo or bar)')
  end

  it 'accepts the use of parentheses around `and` expressions in assignment' do
    expect_no_offenses('var = (foo and bar)')
  end

  it 'accepts parentheses around a method call with unparenthesized arguments' do
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

  it 'accepts parentheses around an irange when a different expression precedes it' do
    expect_no_offenses(<<~RUBY)
      do_something
      (a..b)
    RUBY
  end

  it 'accepts parentheses around an erange when a different expression precedes it' do
    expect_no_offenses(<<~RUBY)
      do_something
      (a...b)
    RUBY
  end

  it 'accepts an irange starting is a parenthesized condition' do
    expect_no_offenses('(a || b)..c')
  end

  it 'accepts an erange starting is a parenthesized condition' do
    expect_no_offenses('(a || b)...c')
  end

  it 'accepts an irange ending is a parenthesized condition' do
    expect_no_offenses('a..(b || c)')
  end

  it 'accepts an erange ending is a parenthesized condition' do
    expect_no_offenses('a...(b || c)')
  end

  it 'accepts regexp literal attempts to match against a parenthesized condition' do
    expect_no_offenses('/regexp/ =~ (b || c)')
  end

  it 'accepts variable attempts to match against a parenthesized condition' do
    expect_no_offenses('regexp =~ (b || c)')
  end

  it 'registers parentheses around `||` logical operator keywords in method definition' do
    expect_offense(<<~RUBY)
      def foo
        (x || y)
        ^^^^^^^^ Don't use parentheses around a logical expression.
      end
    RUBY

    expect_correction(<<~RUBY)
      def foo
        x || y
      end
    RUBY
  end

  it 'registers parentheses around `&&` logical operator keywords in method definition' do
    expect_offense(<<~RUBY)
      def foo
        (x && y)
        ^^^^^^^^ Don't use parentheses around a logical expression.
      end
    RUBY

    expect_correction(<<~RUBY)
      def foo
        x && y
      end
    RUBY
  end

  it 'registers parentheses around `&&` followed by another `&&`' do
    expect_offense(<<~RUBY)
      (x && y) && z
      ^^^^^^^^ Don't use parentheses around a logical expression.
    RUBY

    expect_correction(<<~RUBY)
      x && y && z
    RUBY
  end

  it 'registers parentheses around `&&` preceded by another `&&`' do
    expect_offense(<<~RUBY)
      x && (y && z)
           ^^^^^^^^ Don't use parentheses around a logical expression.
    RUBY

    expect_correction(<<~RUBY)
      x && y && z
    RUBY
  end

  it 'registers parentheses around `&&` preceded and followed by another `&&`' do
    expect_offense(<<~RUBY)
      x && (y && z) && w
           ^^^^^^^^ Don't use parentheses around a logical expression.
    RUBY

    expect_correction(<<~RUBY)
      x && y && z && w
    RUBY
  end

  it 'registers parentheses around `&&` preceded by another `&&` and followed by `||`' do
    expect_offense(<<~RUBY)
      x && (y && z) || w
           ^^^^^^^^ Don't use parentheses around a logical expression.
    RUBY

    expect_correction(<<~RUBY)
      x && y && z || w
    RUBY
  end

  it 'registers parentheses around `&&` preceded by `||` and followed by another `&&`' do
    expect_offense(<<~RUBY)
      x || (y && z) && w
           ^^^^^^^^ Don't use parentheses around a logical expression.
    RUBY

    expect_correction(<<~RUBY)
      x || y && z && w
    RUBY
  end

  it 'accepts parentheses around `&&` followed by `||`' do
    expect_no_offenses(<<~RUBY)
      (x && y) || z
    RUBY
  end

  it 'accepts parentheses around `&&` preceded by `||`' do
    expect_no_offenses(<<~RUBY)
      x || (y && z)
    RUBY
  end

  it 'accepts parentheses around `&&` preceded and followed by `||`' do
    expect_no_offenses(<<~RUBY)
      x || (y && z) || w
    RUBY
  end

  it 'accepts parentheses around `||` followed by `&&`' do
    expect_no_offenses(<<~RUBY)
      (x || y) && z
    RUBY
  end

  it 'accepts parentheses around `||` preceded by `&&`' do
    expect_no_offenses(<<~RUBY)
      x && (y || z)
    RUBY
  end

  it 'accepts parentheses around `||` preceded and followed by `&&`' do
    expect_no_offenses(<<~RUBY)
      x && (y || z) && w
    RUBY
  end

  it 'accepts parentheses around arithmetic operator' do
    expect_no_offenses('x - (y || z)')
  end

  it 'accepts parentheses around logical operator keywords (`and`, `and`, `or`)' do
    expect_no_offenses('(1 and 2) and (3 or 4)')
  end

  it 'accepts parentheses around logical operator keywords (`or`, `or`, `and`)' do
    expect_no_offenses('(1 or 2) or (3 and 4)')
  end

  it 'accepts parentheses around comparison operator keywords' do
    # Parentheses are redundant, but respect user's intentions for readability.
    expect_no_offenses('x && (y == z)')
  end

  it 'accepts parentheses around logical operator in splat' do
    # Parentheses are redundant, but respect user's intentions for readability.
    expect_no_offenses('x = *(y || z)')
  end

  it 'accepts parentheses around `case` expression in splat' do
    # Parentheses are redundant, but respect user's intentions for readability.
    expect_no_offenses('x = *(case true when true then false end)')
  end

  it 'accepts parentheses around `case` expression without condition in splat' do
    # Parentheses are redundant, but respect user's intentions for readability.
    expect_no_offenses('x = *(case when rand > 0.5 then 1 end)')
  end

  it 'accepts parentheses around logical operator in double splat' do
    # Parentheses are redundant, but respect user's intentions for readability.
    expect_no_offenses('x(**(y || z))')
  end

  it 'accepts parentheses around logical operator in ternary operator' do
    # Parentheses are redundant, but respect user's intentions for readability.
    expect_no_offenses('cond ? x : (y || z)')
  end

  it 'registers parentheses around logical operator in `if`...`else`' do
    expect_offense(<<~RUBY)
      if cond
        x
      else
        (y || z)
        ^^^^^^^^ Don't use parentheses around a logical expression.
      end
    RUBY

    expect_correction(<<~RUBY)
      if cond
        x
      else
        y || z
      end
    RUBY
  end

  it 'accepts parentheses around a method call with parenthesized logical expression receiver' do
    expect_no_offenses('(x || y).z')
  end

  it 'accepts parentheses around a method call with parenthesized comparison expression receiver' do
    expect_no_offenses('(x == y).zero?')
  end

  it 'accepts parentheses around single argument separated by semicolon' do
    expect_no_offenses('x((prepare; perform))')
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

  context 'when a parenthesized literal is used in a comparison' do
    it 'registers an offense for `==`' do
      expect_offense(<<~RUBY)
        x == (42)
             ^^^^ Don't use parentheses around a literal.
      RUBY

      expect_correction(<<~RUBY)
        x == 42
      RUBY
    end

    it 'registers an offense for `>`' do
      expect_offense(<<~RUBY)
        x > (42)
            ^^^^ Don't use parentheses around a literal.
      RUBY

      expect_correction(<<~RUBY)
        x > 42
      RUBY
    end

    it 'registers an offense for `>=`' do
      expect_offense(<<~RUBY)
        x >= (42)
             ^^^^ Don't use parentheses around a literal.
      RUBY

      expect_correction(<<~RUBY)
        x >= 42
      RUBY
    end

    it 'registers an offense for `<`' do
      expect_offense(<<~RUBY)
        x < (42)
            ^^^^ Don't use parentheses around a literal.
      RUBY

      expect_correction(<<~RUBY)
        x < 42
      RUBY
    end

    it 'registers an offense for `<=`' do
      expect_offense(<<~RUBY)
        x <= (42)
             ^^^^ Don't use parentheses around a literal.
      RUBY

      expect_correction(<<~RUBY)
        x <= 42
      RUBY
    end
  end

  it 'registers an offense for a parenthesized literal in a `=~` comparison' do
    expect_offense(<<~RUBY)
      x =~ (/regexp/)
           ^^^^^^^^^^ Don't use parentheses around a literal.
    RUBY

    expect_correction(<<~RUBY)
      x =~ /regexp/
    RUBY
  end

  # Ruby 2.7's one-line `in` pattern node type is `match-pattern`.
  it 'registers parentheses when using one-line `in` pattern matching in a redundant parentheses', :ruby27 do
    expect_offense(<<~RUBY)
      (expression in pattern)
      ^^^^^^^^^^^^^^^^^^^^^^^ Don't use parentheses around a one-line pattern matching.
    RUBY

    expect_correction(<<~RUBY)
      expression in pattern
    RUBY
  end

  # Ruby 3.0's one-line `in` pattern node type is `match-pattern-p`.
  it 'registers parentheses when using one-line `in` pattern matching in a redundant parentheses', :ruby30 do
    expect_offense(<<~RUBY)
      (expression in pattern)
      ^^^^^^^^^^^^^^^^^^^^^^^ Don't use parentheses around a one-line pattern matching.
    RUBY

    expect_correction(<<~RUBY)
      expression in pattern
    RUBY
  end

  # Ruby 3.0's one-line `=>` pattern node type is `match-pattern`.
  it 'registers an offense when using one-line `=>` pattern matching in a redundant parentheses', :ruby30 do
    expect_offense(<<~RUBY)
      (expression => pattern)
      ^^^^^^^^^^^^^^^^^^^^^^^ Don't use parentheses around a one-line pattern matching.
    RUBY

    expect_correction(<<~RUBY)
      expression => pattern
    RUBY
  end

  # Ruby 2.7's one-line `in` pattern node type is `match-pattern`.
  it 'accepts parentheses when using one-line `in` pattern matching in a method argument', :ruby27 do
    expect_no_offenses(<<~RUBY)
      foo((bar in baz))
    RUBY
  end

  # Ruby 2.7's one-line `in` pattern node type is `match-pattern`.
  it 'accepts parentheses when using one-line `in` pattern matching in a method argument with safe navigation', :ruby27 do
    expect_no_offenses(<<~RUBY)
      obj&.foo((bar in baz))
    RUBY
  end

  # Ruby 3.0's one-line `in` pattern node type is `match-pattern-p`.
  it 'accepts parentheses when using one-line `in` pattern matching in a method argument', :ruby30 do
    expect_no_offenses(<<~RUBY)
      foo((bar in baz))
    RUBY
  end

  # Ruby 3.0's one-line `in` pattern node type is `match-pattern-p`.
  it 'accepts parentheses when using one-line `in` pattern matching in a method argument with safe navigation', :ruby30 do
    expect_no_offenses(<<~RUBY)
      obj&.foo((bar in baz))
    RUBY
  end

  it 'accepts parentheses when using one-line `in` pattern matching in `&&` operator', :ruby30 do
    expect_no_offenses(<<~RUBY)
      (foo in bar) && (baz in qux)
    RUBY
  end

  it 'accepts parentheses when using one-line `in` pattern matching in `||` operator', :ruby30 do
    expect_no_offenses(<<~RUBY)
      (foo in bar) || (baz in qux)
    RUBY
  end

  it 'accepts parentheses when assigning a parenthesized one-line `in` pattern matching', :ruby30 do
    expect_no_offenses(<<~RUBY)
      foo = (bar in baz)
    RUBY
  end

  it 'accepts parentheses when or-assigning a parenthesized one-line `in` pattern matching', :ruby30 do
    expect_no_offenses(<<~RUBY)
      foo ||= (bar in baz)
    RUBY
  end

  it 'accepts parentheses when using parenthesized one-line `in` pattern matching in endless method definition', :ruby30 do
    expect_no_offenses(<<~RUBY)
      def foo = (bar in 0 | 1)
    RUBY
  end

  it 'accepts parentheses when using parenthesized one-line `=>` pattern matching in endless method definition', :ruby30 do
    expect_no_offenses(<<~RUBY)
      def foo = (bar => 0 | 1)
    RUBY
  end

  it 'accepts parentheses when using parenthesized one-line `in` pattern matching in endless singleton method definition', :ruby30 do
    expect_no_offenses(<<~RUBY)
      def self.foo = (bar in 0 | 1)
    RUBY
  end

  it 'accepts parentheses when using parenthesized one-line `=>` pattern matching in endless singleton method definition', :ruby30 do
    expect_no_offenses(<<~RUBY)
      def self.foo = (bar => 0 | 1)
    RUBY
  end

  it 'registers parentheses when using parenthesized one-line `in` pattern matching in method definition', :ruby30 do
    expect_offense(<<~RUBY)
      def foo
        (bar in 0 | 1)
        ^^^^^^^^^^^^^^ Don't use parentheses around a one-line pattern matching.
      end
    RUBY

    expect_correction(<<~RUBY)
      def foo
        bar in 0 | 1
      end
    RUBY
  end

  it 'registers parentheses when using parenthesized one-line `=>` pattern matching in method definition', :ruby30 do
    expect_offense(<<~RUBY)
      def foo
        (bar => 0 | 1)
        ^^^^^^^^^^^^^^ Don't use parentheses around a one-line pattern matching.
      end
    RUBY

    expect_correction(<<~RUBY)
      def foo
        bar => 0 | 1
      end
    RUBY
  end

  it 'registers parentheses when using parenthesized one-line `in` pattern matching in singleton method definition', :ruby30 do
    expect_offense(<<~RUBY)
      def self.foo
        (bar in 0 | 1)
        ^^^^^^^^^^^^^^ Don't use parentheses around a one-line pattern matching.
      end
    RUBY

    expect_correction(<<~RUBY)
      def self.foo
        bar in 0 | 1
      end
    RUBY
  end

  it 'registers parentheses when using parenthesized one-line `=>` pattern matching in singleton method definition', :ruby30 do
    expect_offense(<<~RUBY)
      def self.foo
        (bar => 0 | 1)
        ^^^^^^^^^^^^^^ Don't use parentheses around a one-line pattern matching.
      end
    RUBY

    expect_correction(<<~RUBY)
      def self.foo
        bar => 0 | 1
      end
    RUBY
  end

  context 'when the first argument in a method call begins with a hash literal' do
    it 'accepts parentheses if the argument list is not parenthesized' do
      expect_no_offenses('x ({ y: 1 }), z')
      expect_no_offenses('x ({ y: 1 }).merge({ y: 2 }), z')
      expect_no_offenses('x ({ y: 1 }.merge({ y: 2 })), z')
      expect_no_offenses('x ({ y: 1 }.merge({ y: 2 }).merge({ y: 3 })), z')
    end

    it 'registers an offense if the argument list is parenthesized' do
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

  it 'registers an offense when parentheses around a `rescue` expression on a one-line' do
    expect_offense(<<~RUBY)
      (foo rescue bar)
      ^^^^^^^^^^^^^^^^ Don't use parentheses around a one-line rescue.
      (foo rescue bar)
      ^^^^^^^^^^^^^^^^ Don't use parentheses around a one-line rescue.
    RUBY

    expect_correction(<<~RUBY)
      foo rescue bar
      foo rescue bar
    RUBY
  end

  it 'does not register an offense when parentheses are used around a one-line `rescue` expression as a branch condition' do
    expect_no_offenses(<<~RUBY)
      if (foo rescue bar)
        do_something
      end
    RUBY
  end

  it 'does not register an offense when parentheses are used around a one-line `rescue` expression as a loop condition' do
    expect_no_offenses(<<~RUBY)
      while (foo rescue bar)
        do_something
      end
    RUBY
  end

  it 'does not register an offense when parentheses are used around a one-line `rescue` expression as a case condition' do
    expect_no_offenses(<<~RUBY)
      case (foo rescue bar)
      when foo
        do_something
      end
    RUBY
  end

  it 'does not register an offense when parentheses are used around a one-line `rescue` expression inside an array literal' do
    expect_no_offenses(<<~RUBY)
      [
        (foo rescue bar)
      ]
    RUBY
  end

  it 'does not register an offense when parentheses are used around a one-line `rescue` expression inside a hash literal' do
    expect_no_offenses(<<~RUBY)
      {
        key: (foo rescue bar)
      }
    RUBY
  end

  it 'registers an offense when parentheses are used around a one-line `rescue` expression inside an `if` expression' do
    expect_offense(<<~RUBY)
      if cond
        (foo rescue bar)
        ^^^^^^^^^^^^^^^^ Don't use parentheses around a one-line rescue.
      else
        42
      end
    RUBY

    expect_correction(<<~RUBY)
      if cond
        foo rescue bar
      else
        42
      end
    RUBY
  end

  it 'does not register an offense when parentheses are used around a one-line `rescue` expression inside a ternary operator' do
    expect_no_offenses(<<~RUBY)
      cond ? (foo rescue bar) : 42
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

  it 'accepts parentheses in super call with multiline style argument' do
    expect_no_offenses(<<~RUBY)
      super (
        42
      )
    RUBY
  end

  it 'accepts parentheses in yield call with multiline style argument' do
    expect_no_offenses(<<~RUBY)
      yield (
        42
      )
    RUBY
  end

  it 'accepts parentheses in `return` with multiline style argument' do
    expect_no_offenses(<<~RUBY)
      return (
        42
      )
    RUBY
  end

  it 'registers an offense when parentheses in `return` with single style argument' do
    expect_offense(<<~RUBY)
      return (42)
             ^^^^ Don't use parentheses around a literal.
    RUBY

    expect_correction(<<~RUBY)
      return 42
    RUBY
  end

  it 'registers an offense when parentheses in `return` with binary method call' do
    expect_offense(<<~RUBY)
      return (foo + bar)
             ^^^^^^^^^^^ Don't use parentheses around a method call.
    RUBY

    expect_correction(<<~RUBY)
      return foo + bar
    RUBY
  end

  it 'accepts parentheses in `next` with multiline style argument', :ruby32, unsupported_on: :prism do
    expect_no_offenses(<<~RUBY)
      next (
        42
      )
    RUBY
  end

  it 'registers an offense when parentheses in `next` with single style argument', :ruby32, unsupported_on: :prism do
    expect_offense(<<~RUBY)
      next (42)
           ^^^^ Don't use parentheses around a literal.
    RUBY

    expect_correction(<<~RUBY)
      next 42
    RUBY
  end

  it 'accepts parentheses in `break` with multiline style argument', :ruby32, unsupported_on: :prism do
    expect_no_offenses(<<~RUBY)
      break (
        42
      )
    RUBY
  end

  it 'registers an offense when parentheses in `break` with single style argument', :ruby32, unsupported_on: :prism do
    expect_offense(<<~RUBY)
      break (42)
            ^^^^ Don't use parentheses around a literal.
    RUBY

    expect_correction(<<~RUBY)
      break 42
    RUBY
  end

  it 'registers an offense and corrects when method arguments are unnecessarily parenthesized' do
    expect_offense(<<~RUBY)
      foo(
        (
        ^ Don't use parentheses around a literal.
          1
        ),
        2
      )
    RUBY

    expect_correction(<<~RUBY)
      foo(
        1,
        2
      )
    RUBY
  end

  it 'registers an offense and corrects an array of multiple heredocs' do
    expect_offense(<<~RUBY)
      [
        (
        ^ Don't use parentheses around a literal.
        <<-STRING
          foo
        STRING
        ) ,
        (
        ^ Don't use parentheses around a literal.
        <<-STRING
          bar
        STRING
        )
      ]
    RUBY

    expect_correction(<<~RUBY)
      [
        <<-STRING,
          foo
        STRING
        <<-STRING
          bar
        STRING
      ]
    RUBY
  end

  context 'pin operator', :ruby31 do
    shared_examples 'redundant parentheses' do |variable, description|
      it "registers an offense and corrects #{description}" do
        expect_offense(<<~RUBY, variable: variable)
          var = 0
          foo in { bar: ^(%{variable}) }
                         ^^{variable}^ Don't use parentheses around a variable.
        RUBY

        expect_correction(<<~RUBY)
          var = 0
          foo in { bar: ^#{variable} }
        RUBY
      end
    end

    it_behaves_like 'redundant parentheses', 'var', 'a local variable'
    it_behaves_like 'redundant parentheses', '@var', 'an instance variable'
    it_behaves_like 'redundant parentheses', '@@var', 'a class variable'
    it_behaves_like 'redundant parentheses', '$var', 'a global variable'

    shared_examples 'allowed parentheses' do |expression, description|
      it "accepts parentheses on #{description}" do
        expect_no_offenses(<<~RUBY)
          var = 0
          foo in { bar: ^(#{expression}) }
        RUBY
      end
    end

    it_behaves_like 'allowed parentheses', 'meth', 'a function call with no arguments'
    it_behaves_like 'allowed parentheses', 'meth(true)', 'a function call with arguments'
    it_behaves_like 'allowed parentheses', 'var.to_i', 'a method call on a local variable'
    it_behaves_like 'allowed parentheses', '@var.to_i', 'a method call on an instance variable'
    it_behaves_like 'allowed parentheses', '@@var.to_i', 'a method call on a class variable'
    it_behaves_like 'allowed parentheses', '$var.to_i', 'a method call on a global variable'
    it_behaves_like 'allowed parentheses', 'var + 1', 'an expression'
    it_behaves_like 'allowed parentheses', '[1, 2]', 'an array literal'
    it_behaves_like 'allowed parentheses', '{ baz: 2 }', 'a hash literal'
    it_behaves_like 'allowed parentheses', '1..2', 'a range literal'
    it_behaves_like 'allowed parentheses', '1', 'an int literal'
  end

  context 'when `AllowInMultilineConditions: true` of `Style/ParenthesesAroundCondition`' do
    let(:other_cops) do
      {
        'Style/ParenthesesAroundCondition' => {
          'Enabled' => enabled, 'AllowInMultilineConditions' => true
        }
      }
    end

    context 'when `Style/ParenthesesAroundCondition` is enabled' do
      let(:enabled) { true }

      context 'when single line conditions' do
        it_behaves_like 'redundant', '(x && y)', 'x && y', 'a logical expression'
        it_behaves_like 'redundant', '(x || y)', 'x || y', 'a logical expression'
        it_behaves_like 'redundant', '(x and y)', 'x and y', 'a logical expression'
        it_behaves_like 'redundant', '(x or y)', 'x or y', 'a logical expression'
      end

      context 'when multiline conditions' do
        it_behaves_like 'plausible', <<~RUBY
          (x &&
           y)
        RUBY
        it_behaves_like 'plausible', <<~RUBY
          (x ||
           y)
        RUBY
        it_behaves_like 'plausible', <<~RUBY
          (x and
           y)
        RUBY
        it_behaves_like 'plausible', <<~RUBY
          (x or
           y)
        RUBY
      end
    end

    context 'when `Style/ParenthesesAroundCondition` is disabled' do
      let(:enabled) { false }

      context 'when single line conditions' do
        it_behaves_like 'redundant', '(x && y)', 'x && y', 'a logical expression'
        it_behaves_like 'redundant', '(x || y)', 'x || y', 'a logical expression'
        it_behaves_like 'redundant', '(x and y)', 'x and y', 'a logical expression'
        it_behaves_like 'redundant', '(x or y)', 'x or y', 'a logical expression'
      end

      context 'when multiline conditions' do
        it 'registers an offense when using `&&`' do
          expect_offense(<<~RUBY)
            (x &&
            ^^^^^ Don't use parentheses around a logical expression.
             y)
          RUBY

          expect_correction(<<~RUBY)
            x &&
             y
          RUBY
        end

        it 'registers an offense when using `||`' do
          expect_offense(<<~RUBY)
            (x ||
            ^^^^^ Don't use parentheses around a logical expression.
             y)
          RUBY

          expect_correction(<<~RUBY)
            x ||
             y
          RUBY
        end

        it 'registers an offense when using `and`' do
          expect_offense(<<~RUBY)
            (x and
            ^^^^^^ Don't use parentheses around a logical expression.
             y)
          RUBY

          expect_correction(<<~RUBY)
            x and
             y
          RUBY
        end

        it 'registers an offense when using `or`' do
          expect_offense(<<~RUBY)
            (x or
            ^^^^^ Don't use parentheses around a logical expression.
             y)
          RUBY

          expect_correction(<<~RUBY)
            x or
             y
          RUBY
        end
      end
    end
  end
end
