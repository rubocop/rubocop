# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::UnlessMinimizeNegations, :config do
  it "doesn't register an offense when using mixed boolean operators" do
    expect_no_offenses('a unless !x && !y || !z')
  end

  it "doesn't register an offense when using a single condition" do
    expect_no_offenses('a unless !x')
  end

  it "doesn't register an offense without an `unless`" do
    expect_no_offenses('a if !x && !y')
  end

  context 'with 2 negations' do
    it 'registers an offense when using `&&`' do
      expect_offense(<<~RUBY)
        a unless !x && !y
        ^^^^^^^^^^^^^^^^^ Avoid `unless` with many negations.
      RUBY

      expect_correction("a if x || y\n")
    end

    it 'registers an offense when using `and`' do
      expect_offense(<<~RUBY)
        a unless !x and !y
        ^^^^^^^^^^^^^^^^^^ Avoid `unless` with many negations.
      RUBY

      expect_correction("a if x or y\n")
    end

    it 'registers an offense when using `||`' do
      expect_offense(<<~RUBY)
        a unless !x || !y
        ^^^^^^^^^^^^^^^^^ Avoid `unless` with many negations.
      RUBY

      expect_correction("a if x && y\n")
    end

    it 'registers an offense when using `or`' do
      expect_offense(<<~RUBY)
        a unless !x or !y
        ^^^^^^^^^^^^^^^^^ Avoid `unless` with many negations.
      RUBY

      expect_correction("a if x and y\n")
    end
  end

  context 'with 1 negation and 1 positive' do
    it "doesn't register an offense when using `&&`" do
      expect_no_offenses('a unless !x && y')
    end

    it "doesn't register an offense when using `||`" do
      expect_no_offenses('a unless !x || y')
    end
  end

  context 'with 2 negations and 1 positive' do
    it 'registers an offense when using `&&`' do
      expect_offense(<<~RUBY)
        a unless !x && !y && z
        ^^^^^^^^^^^^^^^^^^^^^^ Avoid `unless` with many negations.
      RUBY

      expect_correction("a if x || y || !z\n")
    end

    it 'registers an offense when using `||`' do
      expect_offense(<<~RUBY)
        a unless !x || !y || z
        ^^^^^^^^^^^^^^^^^^^^^^ Avoid `unless` with many negations.
      RUBY

      expect_correction("a if x && y && !z\n")
    end
  end

  context 'when condition contains a comparison' do
    RuboCop::AST::Node::COMPARISON_OPERATORS.each do |comparison_operator|
      it "registers an offense and corrects using brackets for negation `k #{comparison_operator} m`" do
        expect_offense(<<~RUBY)
          a unless !x && k #{comparison_operator} m && !z
          ^^^^^^^^^^^^^^^^^^^^^^^^^#{'^' * comparison_operator.length} Avoid `unless` with many negations.
        RUBY

        expect_correction("a if x || !(k #{comparison_operator} m) || z\n")
      end
    end
  end

  context 'when condition contains parentheses' do
    it 'registers an offense when using an empty condition' do
      expect_offense(<<~RUBY)
        a unless !x && !y && !()
        ^^^^^^^^^^^^^^^^^^^^^^^^ Avoid `unless` with many negations.
        a unless !x && !y && ()
        ^^^^^^^^^^^^^^^^^^^^^^^ Avoid `unless` with many negations.
      RUBY

      expect_correction(<<~RUBY)
        a if x || y || ()
        a if x || y || !()
      RUBY
    end

    it 'ignores content inside the parentheses' do
      expect_offense(<<~RUBY)
        a unless !x && !y && (!z)
        ^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid `unless` with many negations.
        a unless !x && !y && !(!z)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid `unless` with many negations.
        a unless !x && (!y) && (!z)
      RUBY

      expect_correction(<<~RUBY)
        a if x || y || !(!z)
        a if x || y || (!z)
        a unless !x && (!y) && (!z)
      RUBY
    end

    it 'ignores boolean operators inside the parentheses' do
      expect_offense(<<~RUBY)
        a unless !x && (k || l) && !z
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid `unless` with many negations.
        a unless !x && (k && l) && !z
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid `unless` with many negations.
      RUBY

      expect_correction(<<~RUBY)
        a if x || !(k || l) || z
        a if x || !(k && l) || z
      RUBY
    end
  end
end
