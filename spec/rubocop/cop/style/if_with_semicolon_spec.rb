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

  it 'registers an offense and corrects for one line if/;/end without else body' do
    expect_offense(<<~RUBY)
      if cond; run else; end
      ^^^^^^^^^^^^^^^^^^^^^^ Do not use `if cond;` - use a ternary operator instead.
    RUBY

    expect_correction(<<~RUBY)
      cond ? run : nil
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

  it 'can handle modifier conditionals' do
    expect_no_offenses(<<~RUBY)
      class Hash
      end if RUBY_VERSION < "1.8.7"
    RUBY
  end

  context 'when elsif is present' do
    it 'accepts without `else` branch' do
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

    it 'accepts second elsif block' do
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

    it 'accepts with `else` branch' do
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
  end
end
