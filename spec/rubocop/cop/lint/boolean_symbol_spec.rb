# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::BooleanSymbol, :config do
  it 'registers an offense when using `:true`' do
    expect_offense(<<~RUBY)
      :true
      ^^^^^ Symbol with a boolean name - you probably meant to use `true`.
    RUBY

    expect_correction(<<~RUBY)
      true
    RUBY
  end

  it 'registers an offense when using `:false`' do
    expect_offense(<<~RUBY)
      :false
      ^^^^^^ Symbol with a boolean name - you probably meant to use `false`.
    RUBY

    expect_correction(<<~RUBY)
      false
    RUBY
  end

  context 'when using the new hash syntax' do
    it 'registers an offense when using `true:`' do
      expect_offense(<<~RUBY)
        { true: 'Foo' }
          ^^^^ Symbol with a boolean name - you probably meant to use `true`.
      RUBY

      expect_correction(<<~RUBY)
        { true => 'Foo' }
      RUBY
    end

    it 'registers an offense when using `false:`' do
      expect_offense(<<~RUBY)
        { false: :bar }
          ^^^^^ Symbol with a boolean name - you probably meant to use `false`.
      RUBY

      expect_correction(<<~RUBY)
        { false => :bar }
      RUBY
    end

    it 'registers an offense when using `key: :false`' do
      expect_offense(<<~RUBY)
        { false: :false }
                 ^^^^^^ Symbol with a boolean name - you probably meant to use `false`.
          ^^^^^ Symbol with a boolean name - you probably meant to use `false`.
      RUBY

      expect_correction(<<~RUBY)
        { false => false }
      RUBY
    end
  end

  it 'does not register an offense when using regular symbol' do
    expect_no_offenses(<<~RUBY)
      :something
    RUBY
  end

  it 'does not register an offense when using `true`' do
    expect_no_offenses(<<~RUBY)
      true
    RUBY
  end

  it 'does not register an offense when using `false`' do
    expect_no_offenses(<<~RUBY)
      false
    RUBY
  end

  it 'does not register an offense when used inside percent-literal symbol array' do
    expect_no_offenses(<<~RUBY)
      %i[foo false]
    RUBY
  end
end
