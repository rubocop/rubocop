# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::ComplexUnless, :config do
  it 'registers an offense for `unless` with `||`' do
    expect_offense(<<~RUBY)
      do_something unless x || y
                   ^^^^^^ Prefer `if` over complex `unless` for better readability.
    RUBY

    expect_correction(<<~RUBY)
      do_something if !x && !y
    RUBY
  end

  it 'registers an offense for prefix `unless` with `||`' do
    expect_offense(<<~RUBY)
      unless x || y
      ^^^^^^ Prefer `if` over complex `unless` for better readability.
        do_something
      end
    RUBY

    expect_correction(<<~RUBY)
      if !x && !y
        do_something
      end
    RUBY
  end

  it 'autocorrects `unless` with else without swapping branches' do
    expect_offense(<<~RUBY)
      unless x || y
      ^^^^^^ Prefer `if` over complex `unless` for better readability.
        do_something
      else
        do_other
      end
    RUBY

    expect_correction(<<~RUBY)
      if !x && !y
        do_something
      else
        do_other
      end
    RUBY
  end

  it 'registers an offense for `unless` with multiple `||` conditions' do
    expect_offense(<<~RUBY)
      do_something unless x || y || z
                   ^^^^^^ Prefer `if` over complex `unless` for better readability.
    RUBY

    expect_correction(<<~RUBY)
      do_something if !x && !y && !z
    RUBY
  end

  it 'registers an offense for `unless` with `or`' do
    expect_offense(<<~RUBY)
      do_something unless x or y
                   ^^^^^^ Prefer `if` over complex `unless` for better readability.
    RUBY

    expect_correction(<<~RUBY)
      do_something if !x and !y
    RUBY
  end

  it 'autocorrects modifier form with return' do
    expect_offense(<<~RUBY)
      return unless x || y
             ^^^^^^ Prefer `if` over complex `unless` for better readability.
    RUBY

    expect_correction(<<~RUBY)
      return if !x && !y
    RUBY
  end

  it 'autocorrects modifier form with next' do
    expect_offense(<<~RUBY)
      next unless x || y
           ^^^^^^ Prefer `if` over complex `unless` for better readability.
    RUBY

    expect_correction(<<~RUBY)
      next if !x && !y
    RUBY
  end

  it 'autocorrects modifier form with break' do
    expect_offense(<<~RUBY)
      break unless x || y
            ^^^^^^ Prefer `if` over complex `unless` for better readability.
    RUBY

    expect_correction(<<~RUBY)
      break if !x && !y
    RUBY
  end

  it 'autocorrects modifier form with raise' do
    expect_offense(<<~RUBY)
      raise unless x || y
            ^^^^^^ Prefer `if` over complex `unless` for better readability.
    RUBY

    expect_correction(<<~RUBY)
      raise if !x && !y
    RUBY
  end

  it 'autocorrects a ternary modifier' do
    expect_offense(<<~RUBY)
      value = x? ? y : z unless w || v
                         ^^^^^^ Prefer `if` over complex `unless` for better readability.
    RUBY

    expect_correction(<<~RUBY)
      value = x? ? y : z if !w && !v
    RUBY
  end

  it 'registers an offense for `unless` with negation and `&&`' do
    expect_offense(<<~RUBY)
      do_something unless x && !y
                   ^^^^^^ Prefer `if` over complex `unless` for better readability.
    RUBY

    expect_correction(<<~RUBY)
      do_something if !x || y
    RUBY
  end

  it 'registers an offense for `unless` with mixed negations and `||`' do
    expect_offense(<<~RUBY)
      do_something unless !x || y || z
                   ^^^^^^ Prefer `if` over complex `unless` for better readability.
    RUBY

    expect_correction(<<~RUBY)
      do_something if x && !y && !z
    RUBY
  end

  it 'autocorrects multiple negations combined with `&&`' do
    expect_offense(<<~RUBY)
      do_something unless x && !y && !z
                   ^^^^^^ Prefer `if` over complex `unless` for better readability.
    RUBY

    expect_correction(<<~RUBY)
      do_something if !x || y || z
    RUBY
  end

  it 'autocorrects assignment inside a condition' do
    expect_offense(<<~RUBY)
      do_something unless (x = y) || z
                   ^^^^^^ Prefer `if` over complex `unless` for better readability.
    RUBY

    expect_correction(<<~RUBY)
      do_something if !(x = y) && !z
    RUBY
  end

  it 'autocorrects a rescue expression inside a condition' do
    expect_offense(<<~RUBY)
      do_something unless (x rescue y) || z
                   ^^^^^^ Prefer `if` over complex `unless` for better readability.
    RUBY

    expect_correction(<<~RUBY)
      do_something if !(x rescue y) && !z
    RUBY
  end

  it 'autocorrects `||` with nested `&&`' do
    expect_offense(<<~RUBY)
      do_something unless x || (y && z)
                   ^^^^^^ Prefer `if` over complex `unless` for better readability.
    RUBY

    expect_correction(<<~RUBY)
      do_something if !x && (!y || !z)
    RUBY
  end

  it 'autocorrects mixed `||`/`&&` with trailing disjunction' do
    expect_offense(<<~RUBY)
      do_something unless x || (y && z) || w
                   ^^^^^^ Prefer `if` over complex `unless` for better readability.
    RUBY

    expect_correction(<<~RUBY)
      do_something if !x && (!y || !z) && !w
    RUBY
  end

  it 'autocorrects nested conjunctions with negation' do
    expect_offense(<<~RUBY)
      do_something unless x && (y && !z)
                   ^^^^^^ Prefer `if` over complex `unless` for better readability.
    RUBY

    expect_correction(<<~RUBY)
      do_something if !x || !y || z
    RUBY
  end

  it 'autocorrects nested disjunction groups' do
    expect_offense(<<~RUBY)
      do_something unless (x || y) || (z || w)
                   ^^^^^^ Prefer `if` over complex `unless` for better readability.
    RUBY

    expect_correction(<<~RUBY)
      do_something if !x && !y && !z && !w
    RUBY
  end

  it 'autocorrects nested `||` groups combined with `&&`' do
    expect_offense(<<~RUBY)
      do_something unless (x || y) && (z || w)
                   ^^^^^^ Prefer `if` over complex `unless` for better readability.
    RUBY

    expect_correction(<<~RUBY)
      do_something if (!x && !y) || (!z && !w)
    RUBY
  end

  it 'wraps comparisons when autocorrecting disjunctions' do
    expect_offense(<<~RUBY)
      do_something unless x > y || z == w
                   ^^^^^^ Prefer `if` over complex `unless` for better readability.
    RUBY

    expect_correction(<<~RUBY)
      do_something if !(x > y) && !(z == w)
    RUBY
  end

  it 'autocorrects a begin/end condition' do
    expect_offense(<<~RUBY)
      unless begin
      ^^^^^^ Prefer `if` over complex `unless` for better readability.
        x || y
      end
        do_something
      end
    RUBY

    expect_correction(<<~RUBY)
      if !x && !y
        do_something
      end
    RUBY
  end

  it 'autocorrects a begin/end condition with multiple statements' do
    expect_offense(<<~RUBY)
      unless begin
      ^^^^^^ Prefer `if` over complex `unless` for better readability.
        x
        y || z
      end
        do_something
      end
    RUBY

    expect_correction(<<~RUBY)
      if !(begin
        x
        y || z
      end)
        do_something
      end
    RUBY
  end

  it 'autocorrects `and` with negation' do
    expect_offense(<<~RUBY)
      do_something unless x and !y
                   ^^^^^^ Prefer `if` over complex `unless` for better readability.
    RUBY

    expect_correction(<<~RUBY)
      do_something if !x or y
    RUBY
  end

  it 'wraps comparison methods in negation during autocorrection' do
    expect_offense(<<~RUBY)
      do_something unless x == y || z
                   ^^^^^^ Prefer `if` over complex `unless` for better readability.
    RUBY

    expect_correction(<<~RUBY)
      do_something if !(x == y) && !z
    RUBY
  end

  it 'wraps negated comparison operators in `||`' do
    expect_offense(<<~RUBY)
      do_something unless x != y || z !~ /pattern/
                   ^^^^^^ Prefer `if` over complex `unless` for better readability.
    RUBY

    expect_correction(<<~RUBY)
      do_something if !(x != y) && !(z !~ /pattern/)
    RUBY
  end

  it 'registers an offense when negations are the majority' do
    expect_offense(<<~RUBY)
      do_something unless !x || !y || z
                   ^^^^^^ Prefer `if` over complex `unless` for better readability.
    RUBY

    expect_correction(<<~RUBY)
      do_something if x && y && !z
    RUBY
  end

  it 'registers an offense when all `or` conditions are negated' do
    expect_offense(<<~RUBY)
      do_something unless !x or !y
                   ^^^^^^ Prefer `if` over complex `unless` for better readability.
    RUBY

    expect_correction(<<~RUBY)
      do_something if x and y
    RUBY
  end

  it 'registers an offense when all conditions are negated' do
    expect_offense(<<~RUBY)
      do_something unless !x && !y && !z
                   ^^^^^^ Prefer `if` over complex `unless` for better readability.
    RUBY

    expect_correction(<<~RUBY)
      do_something if x || y || z
    RUBY
  end

  it 'registers an offense and autocorrects mixed operators' do
    expect_offense(<<~RUBY)
      do_something unless x || y && z
                   ^^^^^^ Prefer `if` over complex `unless` for better readability.
    RUBY

    expect_correction(<<~RUBY)
      do_something if !x && (!y || !z)
    RUBY
  end

  it 'registers an offense and autocorrects mixed `or` with `&&`' do
    expect_offense(<<~RUBY)
      do_something unless x or y && z
                   ^^^^^^ Prefer `if` over complex `unless` for better readability.
    RUBY

    expect_correction(<<~RUBY)
      do_something if !x and (!y || !z)
    RUBY
  end

  it 'registers an offense and autocorrects mixed `and` with `||`' do
    expect_offense(<<~RUBY)
      do_something unless x && y or z
                   ^^^^^^ Prefer `if` over complex `unless` for better readability.
    RUBY

    expect_correction(<<~RUBY)
      do_something if (!x || !y) and !z
    RUBY
  end

  it 'registers an offense and autocorrects when wrapped in parentheses' do
    expect_offense(<<~RUBY)
      do_something unless (x || y)
                   ^^^^^^ Prefer `if` over complex `unless` for better readability.
    RUBY

    expect_correction(<<~RUBY)
      do_something if !x && !y
    RUBY
  end

  it 'registers an offense and autocorrects when negated as a whole' do
    expect_offense(<<~RUBY)
      do_something unless !(x || y)
                   ^^^^^^ Prefer `if` over complex `unless` for better readability.
    RUBY

    expect_correction(<<~RUBY)
      do_something if x || y
    RUBY
  end

  it 'autocorrects a negated conjunction' do
    expect_offense(<<~RUBY)
      do_something unless !(x && y)
                   ^^^^^^ Prefer `if` over complex `unless` for better readability.
    RUBY

    expect_correction(<<~RUBY)
      do_something if x && y
    RUBY
  end

  it 'registers an offense and autocorrects with parentheses' do
    expect_offense(<<~RUBY)
      do_something unless x && (y || z)
                   ^^^^^^ Prefer `if` over complex `unless` for better readability.
    RUBY

    expect_correction(<<~RUBY)
      do_something if !x || (!y && !z)
    RUBY
  end

  it 'does not register an offense for `unless` with `&&` and no negations' do
    expect_no_offenses(<<~RUBY)
      do_something unless x && y
    RUBY
  end

  it 'does not register an offense for `unless` with a single condition' do
    expect_no_offenses(<<~RUBY)
      do_something unless x
    RUBY
  end

  it 'does not register an offense for `unless` with parentheses and `&&`' do
    expect_no_offenses(<<~RUBY)
      do_something unless (x && y)
    RUBY
  end

  it 'does not register an offense for `unless` with literal condition' do
    expect_no_offenses(<<~RUBY)
      do_something unless true
    RUBY
  end

  it 'does not register an offense for a single negated condition' do
    expect_no_offenses(<<~RUBY)
      do_something unless !x
    RUBY
  end

  it 'does not register an offense for a bang method name' do
    expect_no_offenses(<<~RUBY)
      do_something unless x!
    RUBY
  end

  it 'simplifies double negation when autocorrecting' do
    expect_offense(<<~RUBY)
      do_something unless !!x
                   ^^^^^^ Prefer `if` over complex `unless` for better readability.
    RUBY

    expect_correction(<<~RUBY)
      do_something if !x
    RUBY
  end

  it 'simplifies odd negation chains when autocorrecting' do
    expect_offense(<<~RUBY)
      do_something unless !!!x
                   ^^^^^^ Prefer `if` over complex `unless` for better readability.
    RUBY

    expect_correction(<<~RUBY)
      do_something if x
    RUBY
  end

  it 'does not register an offense for a single negated condition in parentheses' do
    expect_no_offenses(<<~RUBY)
      do_something unless (!x)
    RUBY
  end

  it 'registers an offense for `unless` with `||` and one negated term' do
    expect_offense(<<~RUBY)
      do_something unless x || !y
                   ^^^^^^ Prefer `if` over complex `unless` for better readability.
    RUBY

    expect_correction(<<~RUBY)
      do_something if !x && y
    RUBY
  end

  it 'autocorrects double negation wrapping a conjunction inside `||`' do
    expect_offense(<<~RUBY)
      do_something unless !!(x && y) || z
                   ^^^^^^ Prefer `if` over complex `unless` for better readability.
    RUBY

    expect_correction(<<~RUBY)
      do_something if !(x && y) && !z
    RUBY
  end

  it 'registers an offense for `unless` with double negation inside `||`' do
    expect_offense(<<~RUBY)
      do_something unless !!x || y
                   ^^^^^^ Prefer `if` over complex `unless` for better readability.
    RUBY

    expect_correction(<<~RUBY)
      do_something if !x && !y
    RUBY
  end

  it 'registers an offense for `unless` with negated group and `&&`' do
    expect_offense(<<~RUBY)
      do_something unless !(x || y) && z
                   ^^^^^^ Prefer `if` over complex `unless` for better readability.
    RUBY

    expect_correction(<<~RUBY)
      do_something if x || y || !z
    RUBY
  end

  it 'does not register an offense for `unless` with pure conjunction of three terms' do
    expect_no_offenses(<<~RUBY)
      do_something unless x && y && z
    RUBY
  end

  it 'registers an offense for `unless` with safe navigation and `||`' do
    expect_offense(<<~RUBY)
      do_something unless x&.foo || z
                   ^^^^^^ Prefer `if` over complex `unless` for better readability.
    RUBY

    expect_correction(<<~RUBY)
      do_something if !x&.foo && !z
    RUBY
  end

  it 'registers an offense for `unless` with two safe navigation calls and `||`' do
    expect_offense(<<~RUBY)
      do_something unless x&.foo || y&.bar
                   ^^^^^^ Prefer `if` over complex `unless` for better readability.
    RUBY

    expect_correction(<<~RUBY)
      do_something if !x&.foo && !y&.bar
    RUBY
  end

  it 'registers an offense for `unless` with calls with arguments and `||`' do
    expect_offense(<<~RUBY)
      do_something unless x(y) || y(z)
                   ^^^^^^ Prefer `if` over complex `unless` for better readability.
    RUBY

    expect_correction(<<~RUBY)
      do_something if !x(y) && !y(z)
    RUBY
  end

  it 'registers an offense for `unless` with predicate methods and `||`' do
    expect_offense(<<~RUBY)
      do_something unless x? || y?
                   ^^^^^^ Prefer `if` over complex `unless` for better readability.
    RUBY

    expect_correction(<<~RUBY)
      do_something if !x? && !y?
    RUBY
  end

  it 'registers an offense for `unless` with regex match operator and `||`' do
    expect_offense(<<~RUBY)
      do_something unless x =~ /pattern/ || y
                   ^^^^^^ Prefer `if` over complex `unless` for better readability.
    RUBY

    expect_correction(<<~RUBY)
      do_something if !(x =~ /pattern/) && !y
    RUBY
  end

  it 'registers an offense for `unless` with `defined?` and `||`' do
    expect_offense(<<~RUBY)
      do_something unless defined?(Foo) || y
                   ^^^^^^ Prefer `if` over complex `unless` for better readability.
    RUBY

    expect_correction(<<~RUBY)
      do_something if !defined?(Foo) && !y
    RUBY
  end

  it 'registers an offense for multiline modifier `unless` with `||`' do
    expect_offense(<<~RUBY)
      do_something unless x ||
                   ^^^^^^ Prefer `if` over complex `unless` for better readability.
                            y
    RUBY

    expect_correction(<<~RUBY)
      do_something if !x && !y
    RUBY
  end

  it 'registers an offense for prefix `unless` with `&&` and negation' do
    expect_offense(<<~RUBY)
      unless x && !y
      ^^^^^^ Prefer `if` over complex `unless` for better readability.
        do_something
      end
    RUBY

    expect_correction(<<~RUBY)
      if !x || y
        do_something
      end
    RUBY
  end

  it 'registers an offense for `unless` with all negated `&&` (two terms)' do
    expect_offense(<<~RUBY)
      do_something unless !x && !y
                   ^^^^^^ Prefer `if` over complex `unless` for better readability.
    RUBY

    expect_correction(<<~RUBY)
      do_something if x || y
    RUBY
  end

  it 'registers an offense for `unless` with method chain and `||`' do
    expect_offense(<<~RUBY)
      do_something unless a.b.c || d.e.f
                   ^^^^^^ Prefer `if` over complex `unless` for better readability.
    RUBY

    expect_correction(<<~RUBY)
      do_something if !a.b.c && !d.e.f
    RUBY
  end

  it 'autocorrects `unless` with literal in `||`' do
    expect_offense(<<~RUBY)
      do_something unless x || true
                   ^^^^^^ Prefer `if` over complex `unless` for better readability.
    RUBY

    expect_correction(<<~RUBY)
      do_something if !x && !true
    RUBY
  end

  it 'does not register an offense for `if`' do
    expect_no_offenses(<<~RUBY)
      do_something if x || y
    RUBY
  end

  it 'does not register an offense for a ternary' do
    expect_no_offenses(<<~RUBY)
      x || y ? z : w
    RUBY
  end

  it 'autocorrects `unless` with ternary inside condition' do
    expect_offense(<<~RUBY)
      do_something unless (a ? b : c) || d
                   ^^^^^^ Prefer `if` over complex `unless` for better readability.
    RUBY

    expect_correction(<<~RUBY)
      do_something if !(a ? b : c) && !d
    RUBY
  end

  it 'autocorrects comparison with `&&` and negation' do
    expect_offense(<<~RUBY)
      do_something unless x > 5 && !y
                   ^^^^^^ Prefer `if` over complex `unless` for better readability.
    RUBY

    expect_correction(<<~RUBY)
      do_something if !(x > 5) || y
    RUBY
  end

  it 'autocorrects mixed `or` and `&&` with explicit parens' do
    expect_offense(<<~RUBY)
      do_something unless (a or b) && c
                   ^^^^^^ Prefer `if` over complex `unless` for better readability.
    RUBY

    expect_correction(<<~RUBY)
      do_something if (!a and !b) || !c
    RUBY
  end

  it 'does not register an offense for single assignment condition' do
    expect_no_offenses(<<~RUBY)
      do_something unless (x = y)
    RUBY
  end

  it 'does not register an offense when `||` is inside a block' do
    expect_no_offenses(<<~RUBY)
      return :unknown unless vals.all? { |val| val.nil? || val.int_type? }
    RUBY
  end

  it 'does not register an offense when `||` is inside a nested block' do
    expect_no_offenses(<<~RUBY)
      do_something unless x.any? { |val| val.nil? || val.int_type? } && y
    RUBY
  end

  it 'does not register an offense when `||` is inside a numblock' do
    expect_no_offenses(<<~RUBY)
      do_something unless x.any? { _1.nil? || _1.int_type? } && y
    RUBY
  end

  it 'does not register an offense when `||` is inside an itblock', :ruby34 do
    expect_no_offenses(<<~RUBY)
      do_something unless x.any? { it.nil? || it.int_type? } && y
    RUBY
  end

  it 'does not register an offense for multi-assignment with `||` in RHS' do
    expect_no_offenses(<<~RUBY)
      unless (x, y = foo || bar)
        do_something
      end
    RUBY
  end

  context 'when MinOperatorCount is 2' do
    let(:cop_config) { { 'MinOperatorCount' => 2 } }

    it 'does not register an offense for a single operator' do
      expect_no_offenses(<<~RUBY)
        do_something unless x || y
      RUBY
    end

    it 'does not register an offense for a single negation' do
      expect_no_offenses(<<~RUBY)
        do_something unless !x
      RUBY
    end

    it 'registers an offense for multiple negations' do
      expect_offense(<<~RUBY)
        do_something unless !!x
                     ^^^^^^ Prefer `if` over complex `unless` for better readability.
      RUBY

      expect_correction(<<~RUBY)
        do_something if !x
      RUBY
    end

    it 'registers an offense when operator count meets the threshold' do
      expect_offense(<<~RUBY)
        do_something unless x || y || z
                     ^^^^^^ Prefer `if` over complex `unless` for better readability.
      RUBY

      expect_correction(<<~RUBY)
        do_something if !x && !y && !z
      RUBY
    end

    it 'registers an offense for nested `&&` inside `||` meeting the threshold' do
      expect_offense(<<~RUBY)
        do_something unless x && y || z
                     ^^^^^^ Prefer `if` over complex `unless` for better readability.
      RUBY

      expect_correction(<<~RUBY)
        do_something if (!x || !y) && !z
      RUBY
    end

    it 'registers an offense for `&&` with negation meeting the threshold' do
      expect_offense(<<~RUBY)
        do_something unless x && !y
                     ^^^^^^ Prefer `if` over complex `unless` for better readability.
      RUBY

      expect_correction(<<~RUBY)
        do_something if !x || y
      RUBY
    end
  end

  context 'when MinOperatorCount is 3' do
    let(:cop_config) { { 'MinOperatorCount' => 3 } }

    it 'does not register an offense when operator count is below threshold' do
      expect_no_offenses(<<~RUBY)
        do_something unless x || y
      RUBY
    end

    it 'does not register an offense for negation with operator below threshold' do
      expect_no_offenses(<<~RUBY)
        do_something unless x && !y
      RUBY
    end

    it 'registers an offense when operator count meets the threshold' do
      expect_offense(<<~RUBY)
        do_something unless x || y || z || w
                     ^^^^^^ Prefer `if` over complex `unless` for better readability.
      RUBY

      expect_correction(<<~RUBY)
        do_something if !x && !y && !z && !w
      RUBY
    end

    it 'registers an offense when negation + operator count meets the threshold' do
      expect_offense(<<~RUBY)
        do_something unless !x && y && !z
                     ^^^^^^ Prefer `if` over complex `unless` for better readability.
      RUBY

      expect_correction(<<~RUBY)
        do_something if x || !y || z
      RUBY
    end
  end
end
