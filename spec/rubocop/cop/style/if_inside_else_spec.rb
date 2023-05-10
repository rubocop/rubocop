# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::IfInsideElse, :config do
  let(:cop_config) { { 'AllowIfModifier' => false } }

  it 'catches an if node nested inside an else' do
    expect_offense(<<~RUBY)
      if a
        blah
      else
        if b
        ^^ Convert `if` nested inside `else` to `elsif`.
          foo
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      if a
        blah
      elsif b
        foo
      end
    RUBY
  end

  it 'catches an if..else nested inside an else' do
    expect_offense(<<~RUBY)
      if a
        blah
      else
        if b
        ^^ Convert `if` nested inside `else` to `elsif`.
          foo
        else # This is expected to be autocorrected by `Layout/IndentationWidth`.
          bar
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      if a
        blah
      elsif b
        foo
        else # This is expected to be autocorrected by `Layout/IndentationWidth`.
          bar
      end
    RUBY
  end

  it 'catches an `if..else` nested inside an `else` and nested inside `if` branch code is empty' do
    expect_offense(<<~RUBY)
      if a
        foo
      else
        if b
        ^^ Convert `if` nested inside `else` to `elsif`.
          # TODO: comment.
        else
          bar
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      if a
        foo
      elsif b
          # TODO: comment.
        else
          bar
      end
    RUBY
  end

  it 'catches an if..elsif..else nested inside an else' do
    expect_offense(<<~RUBY)
      if a
        blah
      else
        if b
        ^^ Convert `if` nested inside `else` to `elsif`.
          foo
        elsif c # This is expected to be autocorrected by `Layout/IndentationWidth`.
            bar
        elsif d
          baz
        else
          qux
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      if a
        blah
      elsif b
        foo
        elsif c # This is expected to be autocorrected by `Layout/IndentationWidth`.
            bar
        elsif d
          baz
        else
          qux
      end
    RUBY
  end

  it 'catches a modifier if nested inside an else after elsif' do
    expect_offense(<<~RUBY)
      if a
        blah
      elsif b
        foo
      else
        bar if condition
            ^^ Convert `if` nested inside `else` to `elsif`.
      end
    RUBY

    expect_correction(<<~RUBY)
      if a
        blah
      elsif b
        foo
      elsif condition
        bar
      end
    RUBY
  end

  it 'handles a nested `if...then...end`' do
    expect_offense(<<~RUBY)
      if x
        'x'
      else
        if y then 'y' end
        ^^ Convert `if` nested inside `else` to `elsif`.
      end
    RUBY

    expect_correction(<<~RUBY)
      if x
        'x'
      else
        if y
        'y'
      end
      end
    RUBY
  end

  it 'handles a nested `if...then...else...end`' do
    expect_offense(<<~RUBY)
      if x
        'x'
      else
        if y then 'y' else 'z' end
        ^^ Convert `if` nested inside `else` to `elsif`.
      end
    RUBY

    expect_correction(<<~RUBY)
      if x
        'x'
      elsif y
        'y'
        else
        'z'
      end
    RUBY
  end

  it 'handles a nested `if...then...elsif...end`' do
    expect_offense(<<~RUBY)
      if x
        'x'
      else
        if y then 'y' elsif z then 'z' end
        ^^ Convert `if` nested inside `else` to `elsif`.
      end
    RUBY

    expect_correction(<<~RUBY)
      if x
        'x'
      else
        if y
        'y'
        elsif z
        'z'
      end
      end
    RUBY
  end

  it 'handles a nested `if...then...elsif...else...end`' do
    expect_offense(<<~RUBY)
      if x
        'x'
      else
        if y then 'y' elsif z then 'z' else 'a' end
        ^^ Convert `if` nested inside `else` to `elsif`.
      end
    RUBY

    expect_correction(<<~RUBY)
      if x
        'x'
      elsif y
        'y'
        elsif z
        'z'
        else
        'a'
      end
    RUBY
  end

  it 'handles a nested multiline `if...then...elsif...else...end`' do
    expect_offense(<<~RUBY)
      if x
        'x'
      else
        if y then 'y'
        ^^ Convert `if` nested inside `else` to `elsif`.
        elsif z then 'z'
        else 'a' end
      end
    RUBY

    expect_correction(<<~RUBY)
      if x
        'x'
      else
        if y
        'y'
        elsif z
        'z'
        else
        'a'
        end
      end
    RUBY
  end

  it 'handles a deep nested multiline `if...then...elsif...else...end`' do
    expect_offense(<<~RUBY)
      if cond
      else
        if nested_one
        ^^ Convert `if` nested inside `else` to `elsif`.
        else
          if c
          ^^ Convert `if` nested inside `else` to `elsif`.
            if d
            else
              if e
              ^^ Convert `if` nested inside `else` to `elsif`.
              end
            end
          end
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      if cond
      elsif nested_one
        else
          if c
            if d
            else
              if e
              end
            end
          end
      end
    RUBY
  end

  context 'when AllowIfModifier is false' do
    it 'catches a modifier if nested inside an else' do
      expect_offense(<<~RUBY)
        if a
          blah
        else
          foo if b
              ^^ Convert `if` nested inside `else` to `elsif`.
        end
      RUBY

      expect_correction(<<~RUBY)
        if a
          blah
        elsif b
          foo
        end
      RUBY
    end
  end

  context 'when AllowIfModifier is true' do
    let(:cop_config) { { 'AllowIfModifier' => true } }

    it 'accepts a modifier if nested inside an else' do
      expect_no_offenses(<<~RUBY)
        if a
          blah
        else
          foo if b
        end
      RUBY
    end
  end

  it "isn't offended if there is a statement following the if node" do
    expect_no_offenses(<<~RUBY)
      if a
        blah
      else
        if b
          foo
        end
        bar
      end
    RUBY
  end

  it "isn't offended if there is a statement preceding the if node" do
    expect_no_offenses(<<~RUBY)
      if a
        blah
      else
        bar
        if b
          foo
        end
      end
    RUBY
  end

  it "isn't offended by if..elsif..else" do
    expect_no_offenses(<<~RUBY)
      if a
        blah
      elsif b
        blah
      else
        blah
      end
    RUBY
  end

  it 'ignores unless inside else' do
    expect_no_offenses(<<~RUBY)
      if a
        blah
      else
        unless b
          foo
        end
      end
    RUBY
  end

  it 'ignores if inside unless' do
    expect_no_offenses(<<~RUBY)
      unless a
        if b
          foo
        end
      end
    RUBY
  end

  it 'ignores nested ternary expressions' do
    expect_no_offenses('a ? b : c ? d : e')
  end

  it 'ignores ternary inside if..else' do
    expect_no_offenses(<<~RUBY)
      if a
        blah
      else
        a ? b : c
      end
    RUBY
  end
end
