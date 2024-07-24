# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::InvertibleUnlessCondition, :config do
  let(:cop_config) do
    {
      'InverseMethods' => {
        :!= => :==,
        :even? => :odd?,
        :odd? => :even?,
        :>= => :<,
        :< => :>=,
        :zero? => :nonzero?,
        # non-standard Rails extensions, but so we can test arguments
        :include? => :exclude?,
        :exclude? => :include?
      }
    }
  end

  context 'when invertible `unless`' do
    it 'registers an offense and corrects when using `!` negation' do
      expect_offense(<<~RUBY)
        foo unless !x
        ^^^^^^^^^^^^^ Prefer `if x` over `unless !x`.
        foo unless !!x
        ^^^^^^^^^^^^^^ Prefer `if !x` over `unless !!x`.
      RUBY

      expect_correction(<<~RUBY)
        foo if x
        foo if !x
      RUBY
    end

    it 'registers an offense and corrects when using simple operator condition' do
      expect_offense(<<~RUBY)
        foo unless x != y
        ^^^^^^^^^^^^^^^^^ Prefer `if x == y` over `unless x != y`.
      RUBY

      expect_correction(<<~RUBY)
        foo if x == y
      RUBY
    end

    it 'registers an offense and corrects when using simple method condition' do
      expect_offense(<<~RUBY)
        foo unless x.odd?
        ^^^^^^^^^^^^^^^^^ Prefer `if x.even?` over `unless x.odd?`.
      RUBY

      expect_correction(<<~RUBY)
        foo if x.even?
      RUBY
    end

    it 'registers an offense and corrects when using method condition with arguments' do
      expect_offense(<<~RUBY)
        foo unless array.include?(value)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `if array.exclude?(value)` over `unless array.include?(value)`.
        foo unless array.exclude? value # no parentheses
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `if array.include? value` over `unless array.exclude? value`.
      RUBY

      expect_correction(<<~RUBY)
        foo if array.exclude?(value)
        foo if array.include? value # no parentheses
      RUBY
    end

    it 'registers an offense and corrects when using simple bracketed condition' do
      expect_offense(<<~RUBY)
        foo unless ((x != y))
        ^^^^^^^^^^^^^^^^^^^^^ Prefer `if ((x == y))` over `unless ((x != y))`.
      RUBY

      expect_correction(<<~RUBY)
        foo if ((x == y))
      RUBY
    end

    it 'registers an offense and corrects when using complex condition' do
      expect_offense(<<~RUBY)
        foo unless x != y && (((x.odd?) || (((y >= 5)))) || z.zero?)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `if x == y || (((x.even?) && (((y < 5)))) && z.nonzero?)` over `unless x != y && (((x.odd?) || (((y >= 5)))) || z.zero?)`.
      RUBY

      expect_correction(<<~RUBY)
        foo if x == y || (((x.even?) && (((y < 5)))) && z.nonzero?)
      RUBY
    end
  end

  it 'registers an offense and corrects methods without arguments called with implicit receivers' do
    expect_offense(<<~RUBY)
      foo unless odd?
      ^^^^^^^^^^^^^^^ Prefer `if even?` over `unless odd?`.
    RUBY

    expect_correction(<<~RUBY)
      foo if even?
    RUBY
  end

  it 'registers an offense and corrects parenthesized methods with arguments called with implicit receivers' do
    expect_offense(<<~RUBY)
      foo unless include?(value)
      ^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `if exclude?(value)` over `unless include?(value)`.
    RUBY

    expect_correction(<<~RUBY)
      foo if exclude?(value)
    RUBY
  end

  it 'registers an offense and corrects unparenthesized methods with arguments called with implicit receivers' do
    expect_offense(<<~RUBY)
      foo unless include? value
      ^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `if exclude? value` over `unless include? value`.
    RUBY

    expect_correction(<<~RUBY)
      foo if exclude? value
    RUBY
  end

  it 'does not register an offense when using explicit begin condition' do
    expect_no_offenses(<<~RUBY)
      foo unless begin x != y end
    RUBY
  end

  it 'does not register an offense when using non invertible `unless`' do
    expect_no_offenses(<<~RUBY)
      foo unless x != y || x.awesome?
    RUBY
  end

  it 'does not register an offense when checking for inheritance' do
    expect_no_offenses(<<~RUBY)
      foo unless x < Foo
    RUBY
  end

  it 'does not register an offense when using invertible `if`' do
    expect_no_offenses(<<~RUBY)
      foo if !condition
    RUBY
  end

  it 'does not register an offense when using empty braces with `unless`' do
    expect_no_offenses(<<~RUBY)
      foo unless ()
    RUBY
  end

  it 'does not register an offense when using empty braces with inverted `if`' do
    expect_no_offenses(<<~RUBY)
      foo if !()
    RUBY
  end
end
