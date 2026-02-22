# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::MinimizeNegations, :config do
  it "doesn't register an offense when using mixed boolean operators" do
    expect_no_offenses('do_something unless !x && !y || !z')
  end

  it "doesn't register an offense when using a single condition" do
    expect_no_offenses('do_something unless !x')
  end

  it "doesn't register an offense without an `unless` by default" do
    expect_no_offenses('do_something if !x && !y')
  end

  it "doesn't register an offense for `elsif` conditions" do
    expect_no_offenses(<<~RUBY)
      if x
        do_something
      elsif !y && !z
        do_something_other
      end
    RUBY
  end

  it "doesn't register an offense for ternary conditions" do
    expect_no_offenses('result = !x && !y ? do_something : do_something_other')
  end

  it "doesn't register an offense for `unless` with no negations" do
    expect_no_offenses('do_something unless x || y')
  end

  it "doesn't register an offense for `unless` with equal negations" do
    expect_no_offenses('do_something unless x || !y')
  end

  it 'registers an offense when negations are in the majority' do
    expect_offense(<<~RUBY)
      do_something unless !x || y || !z
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid `unless` with many negations.
    RUBY

    expect_correction("do_something if x && !y && z\n")
  end

  it "doesn't register an offense for a neutral `unless`" do
    expect_no_offenses('do_something unless x && y')
  end

  it "doesn't register an offense for double negation" do
    expect_no_offenses('do_something unless !!x && !y')
  end

  it "doesn't register an offense for `not` keyword" do
    expect_no_offenses('do_something unless (not x) && (not y)')
  end

  it "doesn't register an offense for semantic negatives without `!`" do
    expect_no_offenses('do_something unless x.invalid? && y.missing?')
  end

  it 'registers an offense for negated predicate methods in `unless`' do
    expect_offense(<<~RUBY)
      do_something unless !x? && !y?
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid `unless` with many negations.
    RUBY

    expect_correction("do_something if x? || y?\n")
  end

  context 'with 2 negations' do
    it 'registers an offense when using `&&`' do
      expect_offense(<<~RUBY)
        do_something unless !x && !y
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid `unless` with many negations.
      RUBY

      expect_correction("do_something if x || y\n")
    end

    it 'registers an offense for negated calls with arguments' do
      expect_offense(<<~RUBY)
        do_something unless !x(y) && !y(z)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid `unless` with many negations.
      RUBY

      expect_correction("do_something if x(y) || y(z)\n")
    end

    it 'registers an offense for negated method chains' do
      expect_offense(<<~RUBY)
        do_something unless !a.b.c && !d.e.f
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid `unless` with many negations.
      RUBY

      expect_correction("do_something if a.b.c || d.e.f\n")
    end

    it 'registers an offense for negated safe navigation calls' do
      expect_offense(<<~RUBY)
        do_something unless !x&.foo && !y&.bar
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid `unless` with many negations.
      RUBY

      expect_correction("do_something if x&.foo || y&.bar\n")
    end

    it 'registers an offense for block-form `unless`' do
      expect_offense(<<~RUBY)
        unless !x && !y
        ^^^^^^^^^^^^^^^ Avoid `unless` with many negations.
          do_something
        end
      RUBY

      expect_correction(<<~RUBY)
        if x || y
          do_something
        end
      RUBY
    end

    it 'registers an offense when using `and`' do
      expect_offense(<<~RUBY)
        do_something unless !x and !y
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid `unless` with many negations.
      RUBY

      expect_correction("do_something if x or y\n")
    end

    it 'registers an offense when using `||`' do
      expect_offense(<<~RUBY)
        do_something unless !x || !y
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid `unless` with many negations.
      RUBY

      expect_correction("do_something if x && y\n")
    end

    it 'registers an offense when using `or`' do
      expect_offense(<<~RUBY)
        do_something unless !x or !y
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid `unless` with many negations.
      RUBY

      expect_correction("do_something if x and y\n")
    end
  end

  context 'with 1 negation and 1 positive' do
    it "doesn't register an offense when using `&&`" do
      expect_no_offenses('do_something unless !x && y')
    end

    it "doesn't register an offense when using `||`" do
      expect_no_offenses('do_something unless !x || y')
    end
  end

  context 'with 2 negations and 1 positive' do
    it 'registers an offense when using `&&`' do
      expect_offense(<<~RUBY)
        do_something unless !x && !y && z
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid `unless` with many negations.
      RUBY

      expect_correction("do_something if x || y || !z\n")
    end

    it 'registers an offense for inequality comparisons' do
      expect_offense(<<~RUBY)
        do_something unless x != 1 && y != 2
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid `unless` with many negations.
      RUBY

      expect_correction("do_something if x == 1 || y == 2\n")
    end

    it 'registers an offense for inequality comparisons with `or`' do
      expect_offense(<<~RUBY)
        do_something unless x != 1 or y != 2
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid `unless` with many negations.
      RUBY

      expect_correction("do_something if x == 1 and y == 2\n")
    end

    it 'registers an offense for inequality comparisons with `||`' do
      expect_offense(<<~RUBY)
        do_something unless x != 1 || y != 2
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid `unless` with many negations.
      RUBY

      expect_correction("do_something if x == 1 && y == 2\n")
    end

    it 'registers an offense when using `||`' do
      expect_offense(<<~RUBY)
        do_something unless !x || !y || z
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid `unless` with many negations.
      RUBY

      expect_correction("do_something if x && y && !z\n")
    end
  end

  context 'with 3 negations' do
    it 'registers an offense when all terms are negated with `&&`' do
      expect_offense(<<~RUBY)
        do_something unless !x && !y && !z
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid `unless` with many negations.
      RUBY

      expect_correction("do_something if x || y || z\n")
    end

    it 'registers an offense when all terms are negated with `||`' do
      expect_offense(<<~RUBY)
        do_something unless !x || !y || !z
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid `unless` with many negations.
      RUBY

      expect_correction("do_something if x && y && z\n")
    end
  end

  context 'with 3 negations and 1 positive' do
    it 'registers an offense and flips the single positive' do
      expect_offense(<<~RUBY)
        do_something unless !x && !y && !z && w
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid `unless` with many negations.
      RUBY

      expect_correction("do_something if x || y || z || !w\n")
    end

    it 'registers an offense when using `||`' do
      expect_offense(<<~RUBY)
        do_something unless !x || !y || !z || w
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid `unless` with many negations.
      RUBY

      expect_correction("do_something if x && y && z && !w\n")
    end
  end

  context 'with all negations using keywords' do
    it 'registers an offense when using `and`' do
      expect_offense(<<~RUBY)
        do_something unless !x and !y and !z
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid `unless` with many negations.
      RUBY

      expect_correction("do_something if x or y or z\n")
    end
  end

  context 'when condition contains a comparison' do
    RuboCop::AST::Node::COMPARISON_OPERATORS.each do |comparison_operator|
      it "registers an offense and corrects using brackets for negation `y #{comparison_operator} z`" do
        source = "do_something unless !x && y #{comparison_operator} z && !w"
        expect_offense(<<~RUBY)
          #{source}
          #{'^' * source.length} Avoid `unless` with many negations.
        RUBY

        expected_correction =
          if comparison_operator.to_s == '!='
            "do_something if x || y == z || w\n"
          else
            "do_something if x || !(y #{comparison_operator} z) || w\n"
          end
        expect_correction(expected_correction)
      end
    end

    it 'registers an offense and preserves parentheses around comparison' do
      expect_offense(<<~RUBY)
        do_something unless !x && (y > z) && !w
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid `unless` with many negations.
      RUBY

      expect_correction("do_something if x || !(y > z) || w\n")
    end
  end

  context 'when condition contains parentheses' do
    it 'registers an offense when using an empty condition' do
      expect_offense(<<~RUBY)
        do_something unless !x && !y && !()
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid `unless` with many negations.
        do_something unless !x && !y && ()
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid `unless` with many negations.
      RUBY

      expect_correction(<<~RUBY)
        do_something if x || y || ()
        do_something if x || y || !()
      RUBY
    end

    it 'ignores boolean operators inside the parentheses' do
      expect_offense(<<~RUBY)
        do_something unless !x && (y || z) && !w
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid `unless` with many negations.
        do_something unless !x && (y && z) && !w
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid `unless` with many negations.
      RUBY

      expect_correction(<<~RUBY)
        do_something if x || !(y || z) || w
        do_something if x || !(y && z) || w
      RUBY
    end

    it "doesn't register an offense when the whole condition is parenthesized" do
      expect_no_offenses('do_something unless (!x && !y)')
    end

    it "doesn't register an offense for negation wrapped in parentheses" do
      expect_no_offenses('do_something unless !x && (!y)')
    end

    it "doesn't register an offense for nested negation parentheses" do
      expect_no_offenses('do_something unless !x && !((!y))')
    end

    it "doesn't register an offense for nested `!=` parentheses" do
      expect_no_offenses('do_something unless !x && !((x != 1))')
    end

    it 'registers an offense for `!=` wrapped in parentheses' do
      expect_offense(<<~RUBY)
        do_something unless !(x != 1) && !(y != 2)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid `unless` with many negations.
      RUBY

      expect_correction("do_something if (x != 1) || (y != 2)\n")
    end
  end

  context 'when EnforcedStyle is set to if' do
    let(:cop_config) { { 'EnforcedStyle' => 'if' } }

    it "doesn't register an offense for `elsif` conditions" do
      expect_no_offenses(<<~RUBY)
        if x
          do_something
        elsif !y && !z
          do_something_other
        end
      RUBY
    end

    it "doesn't register an offense for ternary conditions" do
      expect_no_offenses('result = !x && !y ? do_something : do_something_other')
    end

    it 'registers an offense for `if`' do
      expect_offense(<<~RUBY)
        do_something if !x && !y
        ^^^^^^^^^^^^^^^^^^^^^^^^ Avoid `if` with many negations.
      RUBY

      expect_correction("do_something unless x || y\n")
    end

    it "doesn't register an offense for `unless`" do
      expect_no_offenses('do_something unless !x && !y')
    end

    it "doesn't register an offense for mixed boolean operators" do
      expect_no_offenses('do_something if !x && !y || !z')
    end

    it "doesn't register an offense when negations are not in the majority" do
      expect_no_offenses('do_something if !x && y')
    end

    it 'registers an offense for negated predicate methods with `&&`' do
      expect_offense(<<~RUBY)
        do_something if !x? && !y?
        ^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid `if` with many negations.
      RUBY

      expect_correction("do_something unless x? || y?\n")
    end

    it 'registers an offense for negated predicate methods with `||`' do
      expect_offense(<<~RUBY)
        do_something if !x? || !y?
        ^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid `if` with many negations.
      RUBY

      expect_correction("do_something unless x? && y?\n")
    end

    it 'registers an offense for negated calls with arguments' do
      expect_offense(<<~RUBY)
        do_something if !x(y) || !y(z)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid `if` with many negations.
      RUBY

      expect_correction("do_something unless x(y) && y(z)\n")
    end

    it 'registers an offense for negated method chains' do
      expect_offense(<<~RUBY)
        do_something if !a.b.c && !d.e.f
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid `if` with many negations.
      RUBY

      expect_correction("do_something unless a.b.c || d.e.f\n")
    end

    it 'registers an offense for negated safe navigation calls' do
      expect_offense(<<~RUBY)
        do_something if !x&.foo && !y&.bar
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid `if` with many negations.
      RUBY

      expect_correction("do_something unless x&.foo || y&.bar\n")
    end

    it 'registers an offense for inequality comparisons' do
      expect_offense(<<~RUBY)
        do_something if x != 1 && y != 2
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid `if` with many negations.
      RUBY

      expect_correction("do_something unless x == 1 || y == 2\n")
    end

    it 'registers an offense for block-form `if`' do
      expect_offense(<<~RUBY)
        if !x && !y
        ^^^^^^^^^^^ Avoid `if` with many negations.
          do_something
        end
      RUBY

      expect_correction(<<~RUBY)
        unless x || y
          do_something
        end
      RUBY
    end

    it 'registers an offense when using `and`' do
      expect_offense(<<~RUBY)
        do_something if !x and !y
        ^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid `if` with many negations.
      RUBY

      expect_correction("do_something unless x or y\n")
    end

    it 'registers an offense and corrects comparisons' do
      expect_offense(<<~RUBY)
        do_something if !x && y > z && !w
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid `if` with many negations.
      RUBY

      expect_correction("do_something unless x || !(y > z) || w\n")
    end
  end

  context 'when EnforcedStyle is set to both' do
    let(:cop_config) { { 'EnforcedStyle' => 'both' } }

    it "doesn't register an offense for `elsif` conditions" do
      expect_no_offenses(<<~RUBY)
        if x
          do_something
        elsif !y && !z
          do_something_other
        end
      RUBY
    end

    it "doesn't register an offense for ternary conditions" do
      expect_no_offenses('result = !x && !y ? do_something : do_something_other')
    end

    it 'registers an offense for `unless`' do
      expect_offense(<<~RUBY)
        do_something unless !x && !y
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid `unless` with many negations.
      RUBY

      expect_correction("do_something if x || y\n")
    end

    it 'registers an offense for `if`' do
      expect_offense(<<~RUBY)
        do_something if !x && !y
        ^^^^^^^^^^^^^^^^^^^^^^^^ Avoid `if` with many negations.
      RUBY

      expect_correction("do_something unless x || y\n")
    end

    it 'registers an offense for negated method chains' do
      expect_offense(<<~RUBY)
        do_something unless !a.b.c && !d.e.f
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid `unless` with many negations.
      RUBY

      expect_correction("do_something if a.b.c || d.e.f\n")
    end

    it 'registers an offense for negated safe navigation calls' do
      expect_offense(<<~RUBY)
        do_something if !x&.foo && !y&.bar
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid `if` with many negations.
      RUBY

      expect_correction("do_something unless x&.foo || y&.bar\n")
    end

    it "doesn't register an offense for mixed boolean operators in `if`" do
      expect_no_offenses('do_something if !x && !y || !z')
    end

    it "doesn't register an offense for mixed boolean operators in `unless`" do
      expect_no_offenses('do_something unless !x && !y || !z')
    end

    it "doesn't register an offense when negations are equal to positives" do
      expect_no_offenses('do_something unless !x && y')
    end
  end
end
