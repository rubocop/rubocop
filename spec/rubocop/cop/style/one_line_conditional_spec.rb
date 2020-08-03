# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::OneLineConditional do
  subject(:cop) { described_class.new }

  context 'one line if/then/else/end' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        if cond then run else dont end
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Favor the ternary operator (`?:`) over `if/then/else/end` constructs.
      RUBY
      expect_correction(<<~RUBY)
        cond ? run : dont
      RUBY
    end

    it 'allows empty else' do
      expect_no_offenses('if cond then run else end')
    end
  end

  context 'one line if/then/else/end when `then` branch has no body' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        if cond then else dont end
        ^^^^^^^^^^^^^^^^^^^^^^^^^^ Favor the ternary operator (`?:`) over `if/then/else/end` constructs.
      RUBY
      expect_correction(<<~RUBY)
        cond ? nil : dont
      RUBY
    end
  end

  it 'allows one line if/then/end' do
    expect_no_offenses('if cond then run end')
  end

  context 'one line unless/then/else/end' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        unless cond then run else dont end
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Favor the ternary operator (`?:`) over `unless/then/else/end` constructs.
      RUBY
      expect_correction(<<~RUBY)
        cond ? dont : run
      RUBY
    end

    it 'allows empty else' do
      expect_no_offenses('unless cond then run else end')
    end
  end

  it 'allows one line unless/then/end' do
    expect_no_offenses('unless cond then run end')
  end

  %w[| ^ & <=> == === =~ > >= < <= << >> + - * / % ** ~ ! != !~
     && ||].each do |operator|
    it 'parenthesizes the expression if it is preceded by an operator' do
      expect_offense(<<~RUBY, operator: operator)
        a %{operator} if cond then run else dont end
          _{operator} ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Favor the ternary operator (`?:`) over `if/then/else/end` constructs.
      RUBY
      expect_correction(<<~RUBY)
        a #{operator} (cond ? run : dont)
      RUBY
    end
  end

  shared_examples 'changed precedence' do |expr|
    it "adds parentheses around `#{expr}`" do
      expect_offense(<<~RUBY, expr: expr)
        if %{expr} then %{expr} else %{expr} end
        ^^^^{expr}^^^^^^^{expr}^^^^^^^{expr}^^^^ Favor the ternary operator (`?:`) over `if/then/else/end` constructs.
      RUBY

      expect_correction(<<~RUBY)
        (#{expr}) ? (#{expr}) : (#{expr})
      RUBY
    end
  end

  it_behaves_like 'changed precedence', 'puts 1'
  it_behaves_like 'changed precedence', 'defined? :A'
  it_behaves_like 'changed precedence', 'yield a'
  it_behaves_like 'changed precedence', 'super b'
  it_behaves_like 'changed precedence', 'not a'
  it_behaves_like 'changed precedence', 'a and b'
  it_behaves_like 'changed precedence', 'a or b'
  it_behaves_like 'changed precedence', 'a = b'
  it_behaves_like 'changed precedence', 'a ? b : c'

  it 'does not parenthesize expressions when they do not contain method ' \
     'calls with unparenthesized arguments' do
    expect_offense(<<~RUBY)
      if a(0) then puts(1) else yield(2) end
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Favor the ternary operator (`?:`) over `if/then/else/end` constructs.
    RUBY

    expect_correction(<<~RUBY)
      a(0) ? puts(1) : yield(2)
    RUBY
  end

  it 'does not parenthesize expressions when they contain unparenthesized ' \
     'operator method calls' do
    expect_offense(<<~RUBY)
      if 0 + 0 then 1 + 1 else 2 + 2 end
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Favor the ternary operator (`?:`) over `if/then/else/end` constructs.
    RUBY

    expect_correction(<<~RUBY)
      0 + 0 ? 1 + 1 : 2 + 2
    RUBY
  end

  it 'does not break when one of the branches contains a retry keyword' do
    expect_offense(<<~RUBY)
      if true then retry else 7 end
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Favor the ternary operator (`?:`) over `if/then/else/end` constructs.
    RUBY

    expect_correction(<<~RUBY)
      true ? retry : 7
    RUBY
  end

  it 'does not break when one of the branches contains a break keyword' do
    expect_offense(<<~RUBY)
      if true then break else 7 end
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Favor the ternary operator (`?:`) over `if/then/else/end` constructs.
    RUBY

    expect_correction(<<~RUBY)
      true ? break : 7
    RUBY
  end

  it 'does not break when one of the branches contains a self keyword' do
    expect_offense(<<~RUBY)
      if true then self else 7 end
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Favor the ternary operator (`?:`) over `if/then/else/end` constructs.
    RUBY

    expect_correction(<<~RUBY)
      true ? self : 7
    RUBY
  end

  it 'does not break when one of the branches contains `next` keyword' do
    expect_offense(<<~RUBY)
      map{ |line| if line.match(/^\s*#/) || line.strip.empty? then next else line end }
                  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Favor the ternary operator (`?:`) over `if/then/else/end` constructs.
    RUBY

    expect_correction(<<~RUBY)
      map{ |line| (line.match(/^ *#/) || line.strip.empty?) ? next : line }
    RUBY
  end
end
