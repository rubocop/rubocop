# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::RedundantStructKeywordInit, :config do
  it 'registers an offense when using `keyword_init: true` in Struct' do
    expect_offense(<<~RUBY)
      foo = Struct.new(:bar, keyword_init: true)
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Redundant use of keyword_init: true in Struct.new.
    RUBY

    expect_correction(<<~RUBY)
      foo = Struct.new(:bar)
    RUBY
  end

  it 'registers an offense when using `keyword_init: true` with multiple arguments in Struct' do
    expect_offense(<<~RUBY)
      foo = Struct.new(:bar, :baz, :qux, keyword_init: true)
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Redundant use of keyword_init: true in Struct.new.
    RUBY

    expect_correction(<<~RUBY)
      foo = Struct.new(:bar, :baz, :qux)
    RUBY
  end

  it 'registers an offense when using `keyword_init: true` with multiline struct definitions' do
    expect_offense(<<~RUBY)
      foo = Struct.new(
            ^^^^^^^^^^^ Redundant use of keyword_init: true in Struct.new.
        :bar,
        :baz,
        keyword_init: true
      )
    RUBY

    expect_correction(<<~RUBY)
      foo = Struct.new(
        :bar,
        :baz
      )
    RUBY
  end

  it 'accepts when not using keyword_init' do
    expect_no_offenses(<<~RUBY)
      foo = Struct.new(:bar)
    RUBY
  end

  it 'accepts when keyword_init is false' do
    expect_no_offenses(<<~RUBY)
      foo = Struct.new(:bar, keyword_init: false)
    RUBY
  end

  it 'accepts other keyword arguments' do
    expect_no_offenses(<<~RUBY)
      foo = Struct.new(:bar, name: 'MyStruct')
    RUBY
  end
end
