# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::DuplicateMatchPattern, :config, :ruby27 do
  it 'registers an offense for repeated `in` patterns' do
    expect_offense(<<~RUBY)
      case x
      in foo
        first_method
      in bar
        second_method
      in foo
         ^^^ Duplicate `in` pattern detected.
        third_method
      end
    RUBY
  end

  it 'registers an offense for subsequent repeated `in` patterns' do
    expect_offense(<<~RUBY)
      case x
      in foo
        first_method
      in foo
         ^^^ Duplicate `in` pattern detected.
        second_method
      end
    RUBY
  end

  it 'registers multiple offenses for multiple repeated `in` patterns' do
    expect_offense(<<~RUBY)
      case x
      in foo
        first_method
      in bar
        second_method
      in foo
         ^^^ Duplicate `in` pattern detected.
        third_method
      in bar
         ^^^ Duplicate `in` pattern detected.
        fourth_method
      end
    RUBY
  end

  it 'registers multiple offenses for repeated alternative patterns' do
    expect_offense(<<~RUBY)
      case x
      in foo | bar
        first_method
      in bar | foo
         ^^^^^^^^^ Duplicate `in` pattern detected.
        second_method
      end
    RUBY
  end

  it 'does not register for not equivalent alternative patterns' do
    expect_no_offenses(<<~RUBY)
      case x
      in foo | bar | baz
        first_method
      in foo | bar
        second_method
      end
    RUBY
  end

  it 'registers an offense for repeated array patterns with elements in the same order' do
    expect_offense(<<~RUBY)
      case x
      in [foo, bar]
        first_method
      in [foo, bar]
         ^^^^^^^^^^ Duplicate `in` pattern detected.
        second_method
      end
    RUBY
  end

  it 'does not register an offense for repeated array patterns with elements in different order' do
    expect_no_offenses(<<~RUBY)
      case x
      in [foo, bar]
        first_method
      in [bar, foo]
        second_method
      end
    RUBY
  end

  it 'does not register similar but not equivalent && array patterns' do
    expect_no_offenses(<<~RUBY)
      case x
      in [foo, bar]
        first_method
      in [foo, bar, baz]
        second_method
      end
    RUBY
  end

  it 'registers an offense for repeated hash patterns with elements in the same order' do
    expect_offense(<<~RUBY)
      case x
      in foo: a, bar: b
        first_method
      in foo: a, bar: b
         ^^^^^^^^^^^^^^ Duplicate `in` pattern detected.
        second_method
      end
    RUBY
  end

  it 'registers an offense for repeated hash patterns with elements in different order' do
    expect_offense(<<~RUBY)
      case x
      in foo: a, bar: b
        first_method
      in bar: b, foo: a
         ^^^^^^^^^^^^^^ Duplicate `in` pattern detected.
        second_method
      end
    RUBY
  end

  it 'does not register similar but not equivalent && hash patterns' do
    expect_no_offenses(<<~RUBY)
      case x
      in foo: a, bar: b
        first_method
      in foo: a, bar: b, baz: c
        second_method
      end
    RUBY
  end

  it 'does not register trivial `in` patterns' do
    expect_no_offenses(<<~RUBY)
      case x
      in false
        first_method
      end
    RUBY
  end

  it 'does not register non-redundant `in` patterns' do
    expect_no_offenses(<<~RUBY)
      case x
      in foo
        first_method
      in bar
        second_method
      end
    RUBY
  end

  it 'does not register non-redundant `in` patterns with an else clause' do
    expect_no_offenses(<<~RUBY)
      case x
      in foo
        method_name
      in bar
        second_method
      else
        third_method
      end
    RUBY
  end

  it 'register an offense for repeated `in` patterns and the same `if` guard is used' do
    expect_offense(<<~RUBY)
      case x
      in foo if condition
        first_method
      in foo if condition
         ^^^ Duplicate `in` pattern detected.
        third_method
      end
    RUBY
  end

  it 'register an offense for repeated `in` patterns and the same `unless` guard is used' do
    expect_offense(<<~RUBY)
      case x
      in foo unless condition
        first_method
      in foo unless condition
         ^^^ Duplicate `in` pattern detected.
        third_method
      end
    RUBY
  end

  it 'does not register an offense for repeated `in` patterns but different `if` guard is used' do
    expect_no_offenses(<<~RUBY)
      case x
      in foo if condition1
        first_method
      in foo if condition2
        third_method
      end
    RUBY
  end

  it 'does not register an offense for repeated `in` patterns but different `unless` guard is used' do
    expect_no_offenses(<<~RUBY)
      case x
      in foo unless condition1
        first_method
      in foo unless condition2
        third_method
      end
    RUBY
  end

  it 'does not crash when using hash pattern with `if` guard' do
    expect_no_offenses(<<~RUBY)
      case x
      in { key: value } if condition
      end
    RUBY
  end
end
