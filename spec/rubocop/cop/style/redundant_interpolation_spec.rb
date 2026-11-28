# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::RedundantInterpolation, :config do
  it 'registers an offense for "#{1 + 1}"' do
    expect_offense(<<~'RUBY')
      "#{1 + 1}"
      ^^^^^^^^^^ Prefer `to_s` over string interpolation.
    RUBY

    expect_correction(<<~RUBY)
      (1 + 1).to_s
    RUBY
  end

  it 'registers an offense for "%|#{1 + 1}|"' do
    expect_offense(<<~'RUBY')
      %|#{1 + 1}|
      ^^^^^^^^^^^ Prefer `to_s` over string interpolation.
    RUBY

    expect_correction(<<~RUBY)
      (1 + 1).to_s
    RUBY
  end

  it 'registers an offense for "%Q(#{1 + 1})"' do
    expect_offense(<<~'RUBY')
      %Q(#{1 + 1})
      ^^^^^^^^^^^^ Prefer `to_s` over string interpolation.
    RUBY

    expect_correction(<<~RUBY)
      (1 + 1).to_s
    RUBY
  end

  it 'registers an offense for "#{1 + 1; 2 + 2}"' do
    expect_offense(<<~'RUBY')
      "#{1 + 1; 2 + 2}"
      ^^^^^^^^^^^^^^^^^ Prefer `to_s` over string interpolation.
    RUBY

    expect_correction(<<~RUBY)
      (1 + 1; 2 + 2).to_s
    RUBY
  end

  it 'registers an offense for "#{@var}"' do
    expect_offense(<<~'RUBY')
      "#{@var}"
      ^^^^^^^^^ Prefer `to_s` over string interpolation.
    RUBY

    expect_correction(<<~RUBY)
      @var.to_s
    RUBY
  end

  it 'registers an offense for "#@var"' do
    expect_offense(<<~'RUBY')
      "#@var"
      ^^^^^^^ Prefer `to_s` over string interpolation.
    RUBY

    expect_correction(<<~RUBY)
      @var.to_s
    RUBY
  end

  it 'registers an offense for "#{@@var}"' do
    expect_offense(<<~'RUBY')
      "#{@@var}"
      ^^^^^^^^^^ Prefer `to_s` over string interpolation.
    RUBY

    expect_correction(<<~RUBY)
      @@var.to_s
    RUBY
  end

  it 'registers an offense for "#@@var"' do
    expect_offense(<<~'RUBY')
      "#@@var"
      ^^^^^^^^ Prefer `to_s` over string interpolation.
    RUBY

    expect_correction(<<~RUBY)
      @@var.to_s
    RUBY
  end

  it 'registers an offense for "#{$var}"' do
    expect_offense(<<~'RUBY')
      "#{$var}"
      ^^^^^^^^^ Prefer `to_s` over string interpolation.
    RUBY

    expect_correction(<<~RUBY)
      $var.to_s
    RUBY
  end

  it 'registers an offense for "#$var"' do
    expect_offense(<<~'RUBY')
      "#$var"
      ^^^^^^^ Prefer `to_s` over string interpolation.
    RUBY

    expect_correction(<<~RUBY)
      $var.to_s
    RUBY
  end

  it 'registers an offense for "#{$1}"' do
    expect_offense(<<~'RUBY')
      "#{$1}"
      ^^^^^^^ Prefer `to_s` over string interpolation.
    RUBY

    expect_correction(<<~RUBY)
      $1.to_s
    RUBY
  end

  it 'registers an offense for "#$1"' do
    expect_offense(<<~'RUBY')
      "#$1"
      ^^^^^ Prefer `to_s` over string interpolation.
    RUBY

    expect_correction(<<~RUBY)
      $1.to_s
    RUBY
  end

  it 'registers an offense for "#{$+}"' do
    expect_offense(<<~'RUBY')
      "#{$+}"
      ^^^^^^^ Prefer `to_s` over string interpolation.
    RUBY

    expect_correction(<<~RUBY)
      $+.to_s
    RUBY
  end

  it 'registers an offense for "#$+"' do
    expect_offense(<<~'RUBY')
      "#$+"
      ^^^^^ Prefer `to_s` over string interpolation.
    RUBY

    expect_correction(<<~RUBY)
      $+.to_s
    RUBY
  end

  it 'registers an offense for "#{number}"' do
    expect_offense(<<~'RUBY')
      "#{number}"
      ^^^^^^^^^^^ Prefer `to_s` over string interpolation.
    RUBY

    expect_correction(<<~RUBY)
      number.to_s
    RUBY
  end

  it 'registers an offense for "#{do_something(42)}"' do
    expect_offense(<<~'RUBY')
      "#{do_something(42)}"
      ^^^^^^^^^^^^^^^^^^^^^ Prefer `to_s` over string interpolation.
    RUBY

    expect_correction(<<~RUBY)
      do_something(42).to_s
    RUBY
  end

  it 'registers an offense for "#{do_something 42}"' do
    expect_offense(<<~'RUBY')
      "#{do_something 42}"
      ^^^^^^^^^^^^^^^^^^^^ Prefer `to_s` over string interpolation.
    RUBY

    expect_correction(<<~RUBY)
      do_something(42).to_s
    RUBY
  end

  it 'registers an offense for "#{foo.do_something 42}"' do
    expect_offense(<<~'RUBY')
      "#{foo.do_something 42}"
      ^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `to_s` over string interpolation.
    RUBY

    expect_correction(<<~RUBY)
      foo.do_something(42).to_s
    RUBY
  end

  it 'registers offenses for a nested interpolation in an argument of a method call without parentheses' do
    expect_offense(<<~'RUBY')
      "#{do_something foo, "#{bar}"}"
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `to_s` over string interpolation.
                           ^^^^^^^^ Prefer `to_s` over string interpolation.
    RUBY

    expect_correction(<<~RUBY)
      do_something(foo, bar.to_s).to_s
    RUBY
  end

  it 'registers offenses for a nested interpolation in an argument of a method call with parentheses' do
    expect_offense(<<~'RUBY')
      "#{do_something(foo, "#{bar}")}"
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `to_s` over string interpolation.
                           ^^^^^^^^ Prefer `to_s` over string interpolation.
    RUBY

    expect_correction(<<~RUBY)
      do_something(foo, bar.to_s).to_s
    RUBY
  end

  it 'preserves a comment before the interpolated expression' do
    expect_offense(<<~'RUBY')
      label = "#{
              ^^^ Prefer `to_s` over string interpolation.
        # Use the public name.
        account.name}"
    RUBY

    expect_correction(<<~RUBY)
      label = (
        # Use the public name.
        account.name).to_s
    RUBY
  end

  it 'omits parentheses when only whitespace precedes the interpolated expression' do
    expect_offense(<<~'RUBY')
      label = "#{
              ^^^ Prefer `to_s` over string interpolation.
        account.name}"
    RUBY

    expect_correction(<<~RUBY)
      label = account.name.to_s
    RUBY
  end

  it 'preserves a heredoc body between the method call and the closing brace' do
    expect_offense(<<~'RUBY')
      "#{lookup(<<~TEXT)
      ^^^^^^^^^^^^^^^^^^ Prefer `to_s` over string interpolation.
        key
      TEXT
      }"
    RUBY

    expect_correction(<<~RUBY)
      (lookup(<<~TEXT)
        key
      TEXT
      ).to_s
    RUBY
  end

  it 'corrects a method call before its heredoc body' do
    expect_offense(<<~'RUBY')
      "#{lookup(<<~TEXT)}"
      ^^^^^^^^^^^^^^^^^^^^ Prefer `to_s` over string interpolation.
        key
      TEXT
    RUBY

    expect_correction(<<~RUBY)
      lookup(<<~TEXT).to_s
        key
      TEXT
    RUBY
  end

  it 'registers an offense and keeps the arguments of a multiline method call without parentheses' do
    expect_offense(<<~'RUBY')
      "#{do_something foo, # comment
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `to_s` over string interpolation.
        bar}"
    RUBY

    expect_correction(<<~RUBY)
      do_something(foo, # comment
        bar).to_s
    RUBY
  end

  it 'registers an offense for "#{var}"' do
    expect_offense(<<~'RUBY')
      var = 1; "#{var}"
               ^^^^^^^^ Prefer `to_s` over string interpolation.
    RUBY

    expect_correction(<<~RUBY)
      var = 1; var.to_s
    RUBY
  end

  it 'registers an offense for ["#{@var}"]' do
    expect_offense(<<~'RUBY')
      ["#{@var}", 'foo']
       ^^^^^^^^^ Prefer `to_s` over string interpolation.
    RUBY

    expect_correction(<<~RUBY)
      [@var.to_s, 'foo']
    RUBY
  end

  it 'registers an offense for a one-line `in` pattern matching', :ruby27 do
    # `42 in var` is `match-pattern` node.
    expect_offense(<<~'RUBY')
      "#{42 in var}"
      ^^^^^^^^^^^^^^ Prefer `to_s` over string interpolation.
    RUBY

    expect_correction(<<~RUBY)
      (42 in var).to_s
    RUBY
  end

  it 'registers an offense for a one-line `in` pattern matching', :ruby30 do
    # `42 in var` is `match-pattern-p` node.
    expect_offense(<<~'RUBY')
      "#{42 in var}"
      ^^^^^^^^^^^^^^ Prefer `to_s` over string interpolation.
    RUBY

    expect_correction(<<~RUBY)
      (42 in var).to_s
    RUBY
  end

  it 'accepts an offense for a one-line `=>` pattern matching', :ruby30 do
    # `42 => var` is `match-pattern` node.
    expect_no_offenses(<<~'RUBY')
      "#{42 => var}"
    RUBY
  end

  it 'accepts an offense for a part of one-line `=>` pattern matching', :ruby30 do
    # `42 => var` is `match-pattern` node.
    expect_no_offenses(<<~'RUBY')
      "#{x; 42 => var}"
    RUBY
  end

  it 'accepts a parenthesized one-line `=>` pattern matching', :ruby30 do
    expect_no_offenses(<<~'RUBY')
      "#{(42 => var)}"
    RUBY
  end

  it 'registers an offense when one-line `=>` pattern matching is followed by an expression', :ruby30 do
    expect_offense(<<~'RUBY')
      "#{42 => var; x}"
      ^^^^^^^^^^^^^^^^^ Prefer `to_s` over string interpolation.
    RUBY

    expect_correction(<<~RUBY)
      (42 => var; x).to_s
    RUBY
  end

  it 'accepts `return` with a value' do
    expect_no_offenses(<<~'RUBY')
      "#{return foo}"
    RUBY
  end

  %w[break next redo].each do |keyword|
    it "accepts `#{keyword}`" do
      expect_no_offenses(<<~RUBY)
        "\#{#{keyword}}"
      RUBY
    end
  end

  it 'accepts `return` as the last expression' do
    expect_no_offenses(<<~'RUBY')
      "#{foo; return}"
    RUBY
  end

  it 'registers an offense when `return` is not the last expression' do
    expect_offense(<<~'RUBY')
      "#{return; foo}"
      ^^^^^^^^^^^^^^^^ Prefer `to_s` over string interpolation.
    RUBY

    expect_correction(<<~RUBY)
      (return; foo).to_s
    RUBY
  end

  it 'accepts `if` whose branches both return' do
    expect_no_offenses(<<~'RUBY')
      "#{foo ? return : return}"
    RUBY
  end

  it 'registers an offense for `if` whose branch is not void' do
    expect_offense(<<~'RUBY')
      "#{return if foo}"
      ^^^^^^^^^^^^^^^^^^ Prefer `to_s` over string interpolation.
    RUBY

    expect_correction(<<~RUBY)
      (return if foo).to_s
    RUBY
  end

  it 'accepts `begin` whose `ensure` branch returns' do
    expect_no_offenses(<<~'RUBY')
      "#{begin
        foo
      ensure
        return bar
      end}"
    RUBY
  end

  it 'accepts `begin` whose body and `rescue` branches return' do
    expect_no_offenses(<<~'RUBY')
      "#{begin
        return foo
      rescue
        return bar
      end}"
    RUBY
  end

  it 'registers an offense for `begin` whose `rescue` branch is not void' do
    expect_offense(<<~'RUBY')
      "#{begin
      ^^^^^^^^ Prefer `to_s` over string interpolation.
        return foo
      rescue
        bar
      end}"
    RUBY

    expect_correction(<<~RUBY)
      (begin
        return foo
      rescue
        bar
      end).to_s
    RUBY
  end

  it 'accepts `begin` whose body and `else` branch return' do
    expect_no_offenses(<<~'RUBY')
      "#{begin
        return foo
      rescue
        bar
      else
        return baz
      end}"
    RUBY
  end

  it 'accepts strings with characters before the interpolation' do
    expect_no_offenses('"this is #{@sparta}"')
  end

  it 'accepts strings with characters after the interpolation' do
    expect_no_offenses('"#{@sparta} this is"')
  end

  it 'accepts strings implicitly concatenated with a later string' do
    expect_no_offenses(%q("#{sparta}" ' this is'))
  end

  it 'accepts strings implicitly concatenated with an earlier string' do
    expect_no_offenses(%q('this is ' "#{sparta}"))
  end

  it 'accepts strings that are part of a %W()' do
    expect_no_offenses('%W(#{@var} foo)')
  end
end
