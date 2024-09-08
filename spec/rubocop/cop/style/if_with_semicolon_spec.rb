# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::IfWithSemicolon, :config do
  it 'registers an offense and corrects for one line if/;/end' do
    expect_offense(<<~RUBY)
      if cond; run else dont end
      ^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not use `if cond;` - use a ternary operator instead.
    RUBY

    expect_correction(<<~RUBY)
      cond ? run : dont
    RUBY
  end

  it 'registers an offense and corrects for one line if/;/end without then body' do
    expect_offense(<<~RUBY)
      if cond; else dont end
      ^^^^^^^^^^^^^^^^^^^^^^ Do not use `if cond;` - use a ternary operator instead.
    RUBY

    expect_correction(<<~RUBY)
      cond ? nil : dont
    RUBY
  end

  it 'registers an offense when not using `else` branch' do
    expect_offense(<<~RUBY)
      if cond; run end
      ^^^^^^^^^^^^^^^^ Do not use `if cond;` - use a ternary operator instead.
    RUBY

    expect_correction(<<~RUBY)
      cond ? run : nil
    RUBY
  end

  it 'registers an offense and corrects a single-line `if/;/end` when the then body contains a parenthesized method call with an argument' do
    expect_offense(<<~RUBY)
      if cond;do_something(arg) end
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not use `if cond;` - use a ternary operator instead.
    RUBY

    expect_correction(<<~RUBY)
      cond ? do_something(arg) : nil
    RUBY
  end

  it 'registers an offense and corrects a single-line `if/;/end` when the then body contains an array literal with an argument' do
    expect_offense(<<~RUBY)
      if cond;[] end
      ^^^^^^^^^^^^^^ Do not use `if cond;` - use a ternary operator instead.
    RUBY

    expect_correction(<<~RUBY)
      cond ? [] : nil
    RUBY
  end

  it 'registers an offense and corrects a single-line `if/;/end` when the then body contains a method call with an argument' do
    expect_offense(<<~RUBY)
      if cond;do_something arg end
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not use `if cond;` - use a ternary operator instead.
    RUBY

    expect_correction(<<~RUBY)
      cond ? do_something(arg) : nil
    RUBY
  end

  it 'registers an offense and corrects a single-line `if/;/end` when the then body contains a safe navigation method call with an argument' do
    expect_offense(<<~RUBY)
      if cond;obj&.do_something arg end
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not use `if cond;` - use a ternary operator instead.
    RUBY

    expect_correction(<<~RUBY)
      cond ? obj&.do_something(arg) : nil
    RUBY
  end

  it 'registers an offense and corrects a single-line `if/;/else/end` when the then body contains a method call with an argument' do
    expect_offense(<<~RUBY)
      if cond;foo foo_arg else bar bar_arg end
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not use `if cond;` - use a ternary operator instead.
    RUBY

    expect_correction(<<~RUBY)
      cond ? foo(foo_arg) : bar(bar_arg)
    RUBY
  end

  it 'registers an offense and corrects a single-line `if/;/else/end` when the then body contains a safe navigation method call with an argument' do
    expect_offense(<<~RUBY)
      if cond;foo obj&.foo_arg else bar obj&.bar_arg end
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not use `if cond;` - use a ternary operator instead.
    RUBY

    expect_correction(<<~RUBY)
      cond ? foo(obj&.foo_arg) : bar(obj&.bar_arg)
    RUBY
  end

  it 'registers an offense and corrects a single-line `if/;/end` when the then body contains a method call with `[]`' do
    expect_offense(<<~RUBY)
      if cond; foo[key] else bar end
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not use `if cond;` - use a ternary operator instead.
    RUBY

    expect_correction(<<~RUBY)
      cond ? foo[key] : bar
    RUBY
  end

  it 'registers an offense and corrects a single-line `if/;/end` when the then body contains a method call with `[]=`' do
    expect_offense(<<~RUBY)
      if cond; foo[key] = value else bar end
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not use `if cond;` - use a ternary operator instead.
    RUBY

    expect_correction(<<~RUBY)
      cond ? foo[key] = value : bar
    RUBY
  end

  it 'registers an offense when using multiple expressions in the `else` branch' do
    expect_offense(<<~RUBY)
      if cond; foo else bar'arg'; baz end
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not use `if cond;` - use `if/else` instead.
    RUBY

    expect_correction(<<~RUBY)
      if cond
       foo else bar'arg'; baz end
    RUBY
  end

  it 'can handle modifier conditionals' do
    expect_no_offenses(<<~RUBY)
      class Hash
      end if RUBY_VERSION < "1.8.7"
    RUBY
  end

  context 'when elsif is present' do
    it 'registers an offense when without branch bodies' do
      expect_offense(<<~RUBY)
        if cond; elsif cond2; end
        ^^^^^^^^^^^^^^^^^^^^^^^^^ Do not use `if cond;` - use `if/else` instead.
      RUBY

      expect_correction(<<~RUBY)
        if cond
        #{' ' * 2}
        elsif cond2
        #{' ' * 2}
        end
      RUBY
    end

    it 'registers an offense when without `else` branch' do
      expect_offense(<<~RUBY)
        if cond; run elsif cond2; run2 end
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not use `if cond;` - use `if/else` instead.
      RUBY

      expect_correction(<<~RUBY)
        if cond
          run
        elsif cond2
          run2
        end
      RUBY
    end

    it 'registers an offense when second elsif block' do
      expect_offense(<<~RUBY)
        if cond; run elsif cond2; run2 elsif cond3; run3 else dont end
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not use `if cond;` - use `if/else` instead.
      RUBY

      expect_correction(<<~RUBY)
        if cond
          run
        elsif cond2
          run2
        elsif cond3
          run3
        else
          dont
        end
      RUBY
    end

    it 'registers an offense when with `else` branch' do
      expect_offense(<<~RUBY)
        if cond; run elsif cond2; run2 else dont end
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not use `if cond;` - use `if/else` instead.
      RUBY

      expect_correction(<<~RUBY)
        if cond
          run
        elsif cond2
          run2
        else
          dont
        end
      RUBY
    end

    it 'registers an offense when a nested `if` with a semicolon is used' do
      expect_offense(<<~RUBY)
        if cond; run
        ^^^^^^^^^^^^ Do not use `if cond;` - use a newline instead.
          if cond; run
          ^^^^^^^^^^^^ Do not use `if cond;` - use a ternary operator instead.
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        if cond
         run
          cond ? run : nil
        end
      RUBY
    end

    it 'registers an offense and corrects when using nested single-line if/;/end in block of if body' do
      expect_offense(<<~RUBY)
        if foo?; bar { if qux?; quux else end } end
                       ^^^^^^^^^^^^^^^^^^^^^^ Do not use `if qux?;` - use a ternary operator instead.
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not use `if foo?;` - use `if/else` instead.
      RUBY

      expect_correction(<<~RUBY)
        if foo?
         bar { qux? ? quux : nil } end
      RUBY
    end

    it 'registers an offense and corrects when using nested single-line if/;/end in the block of else body' do
      expect_offense(<<~RUBY)
        if foo?; bar else baz { if qux?; quux else end } end
                                ^^^^^^^^^^^^^^^^^^^^^^ Do not use `if qux?;` - use a ternary operator instead.
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not use `if foo?;` - use `if/else` instead.
      RUBY

      expect_correction(<<~RUBY)
        if foo?
         bar else baz { qux? ? quux : nil } end
      RUBY
    end

    it 'registers an offense and corrects when using nested single-line if/;/end in numblock of if body' do
      expect_offense(<<~RUBY)
        if foo?; bar { if _1; quux else end } end
                       ^^^^^^^^^^^^^^^^^^^^ Do not use `if _1;` - use a ternary operator instead.
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not use `if foo?;` - use `if/else` instead.
      RUBY

      expect_correction(<<~RUBY)
        if foo?
         bar { _1 ? quux : nil } end
      RUBY
    end

    it 'registers an offense and corrects when using nested single-line if/;/end in the numblock of else body' do
      expect_offense(<<~RUBY)
        if foo?; bar else baz { if _1; quux else end } end
                                ^^^^^^^^^^^^^^^^^^^^ Do not use `if _1;` - use a ternary operator instead.
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not use `if foo?;` - use `if/else` instead.
      RUBY

      expect_correction(<<~RUBY)
        if foo?
         bar else baz { _1 ? quux : nil } end
      RUBY
    end
  end
end
