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
        :zero? => :nonzero?
      }
    }
  end

  context 'when invertible `unless`' do
    it 'registers an offense and corrects when using `!` negation' do
      expect_offense(<<~RUBY)
        foo unless !x
        ^^^^^^^^^^^^^ Favor `if` with inverted condition over `unless`.
        foo unless !!x
        ^^^^^^^^^^^^^^ Favor `if` with inverted condition over `unless`.
      RUBY

      expect_correction(<<~RUBY)
        foo if x
        foo if !x
      RUBY
    end

    it 'registers an offense and corrects when using simple operator condition' do
      expect_offense(<<~RUBY)
        foo unless x != y
        ^^^^^^^^^^^^^^^^^ Favor `if` with inverted condition over `unless`.
      RUBY

      expect_correction(<<~RUBY)
        foo if x == y
      RUBY
    end

    it 'registers an offense and corrects when using simple method condition' do
      expect_offense(<<~RUBY)
        foo unless x.odd?
        ^^^^^^^^^^^^^^^^^ Favor `if` with inverted condition over `unless`.
      RUBY

      expect_correction(<<~RUBY)
        foo if x.even?
      RUBY
    end

    it 'registers an offense and corrects when using simple bracketed condition' do
      expect_offense(<<~RUBY)
        foo unless ((x != y))
        ^^^^^^^^^^^^^^^^^^^^^ Favor `if` with inverted condition over `unless`.
      RUBY

      expect_correction(<<~RUBY)
        foo if ((x == y))
      RUBY
    end

    it 'registers an offense and corrects when using complex condition' do
      expect_offense(<<~RUBY)
        foo unless x != y && (((x.odd?) || (((y >= 5)))) || z.zero?)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Favor `if` with inverted condition over `unless`.
      RUBY

      expect_correction(<<~RUBY)
        foo if x == y || (((x.even?) && (((y < 5)))) && z.nonzero?)
      RUBY
    end
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
end
