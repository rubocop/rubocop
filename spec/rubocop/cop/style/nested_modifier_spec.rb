# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::NestedModifier, :config do
  shared_examples 'not correctable' do |keyword|
    it "does not autocorrect when #{keyword} is the outer modifier" do
      expect_offense(<<~RUBY, keyword: keyword)
        something if a %{keyword} b
                  ^^ Avoid using nested modifiers.
      RUBY

      expect_no_corrections
    end

    it "does not autocorrect when #{keyword} is the inner modifier" do
      expect_offense(<<~RUBY, keyword: keyword)
        something %{keyword} a if b
                  ^{keyword} Avoid using nested modifiers.
      RUBY

      expect_no_corrections
    end
  end

  it 'autocorrects if + if' do
    expect_offense(<<~RUBY)
      something if a if b
                ^^ Avoid using nested modifiers.
    RUBY

    expect_correction(<<~RUBY)
      something if b && a
    RUBY
  end

  it 'autocorrects unless + unless' do
    expect_offense(<<~RUBY)
      something unless a unless b
                ^^^^^^ Avoid using nested modifiers.
    RUBY

    expect_correction(<<~RUBY)
      something unless b || a
    RUBY
  end

  it 'autocorrects if + unless' do
    expect_offense(<<~RUBY)
      something if a unless b
                ^^ Avoid using nested modifiers.
    RUBY

    expect_correction(<<~RUBY)
      something unless b || !a
    RUBY
  end

  it 'autocorrects unless with a comparison operator + if' do
    expect_offense(<<~RUBY)
      something unless b > 1 if true
                ^^^^^^ Avoid using nested modifiers.
    RUBY

    expect_correction(<<~RUBY)
      something if true && !(b > 1)
    RUBY
  end

  it 'autocorrects unless + if' do
    expect_offense(<<~RUBY)
      something unless a if b
                ^^^^^^ Avoid using nested modifiers.
    RUBY

    expect_correction(<<~RUBY)
      something if b && !a
    RUBY
  end

  it 'adds parentheses when needed in autocorrection' do
    expect_offense(<<~RUBY)
      something if a || b if c || d
                ^^ Avoid using nested modifiers.
    RUBY

    expect_correction(<<~RUBY)
      something if (c || d) && (a || b)
    RUBY
  end

  it 'adds parentheses to method arguments when needed in autocorrection' do
    expect_offense(<<~RUBY)
      a unless [1, 2].include? a if a
        ^^^^^^ Avoid using nested modifiers.
    RUBY

    expect_correction(<<~RUBY)
      a if a && ![1, 2].include?(a)
    RUBY
  end

  it 'does not add redundant parentheses in autocorrection' do
    expect_offense(<<~RUBY)
      something if a unless c || d
                ^^ Avoid using nested modifiers.
    RUBY

    expect_correction(<<~RUBY)
      something unless c || d || !a
    RUBY
  end

  context 'while' do
    it_behaves_like 'not correctable', 'while'
  end

  context 'until' do
    it_behaves_like 'not correctable', 'until'
  end

  it 'registers one offense for more than two modifiers' do
    expect_offense(<<~RUBY)
      something until a while b unless c if d
                                ^^^^^^ Avoid using nested modifiers.
    RUBY

    expect_correction(<<~RUBY)
      something until a while b if d && !c
    RUBY
  end
end
