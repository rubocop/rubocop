# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::CaseLikeIf, :config do
  let(:cop_config) { { 'MinBranchesCount' => 2 } }

  it 'registers an offense and corrects when using `===`' do
    expect_offense(<<~RUBY)
      if Integer === x
      ^^^^^^^^^^^^^^^^ Convert `if-elsif` to `case-when`.
      elsif /foo/ === x
      elsif (1..10) === x
      else
      end
    RUBY

    expect_correction(<<~RUBY)
      case x
      when Integer
      when /foo/
      when (1..10)
      else
      end
    RUBY
  end

  it 'registers an offense and corrects when using `==` with literal' do
    expect_offense(<<~RUBY)
      if x == 1
      ^^^^^^^^^ Convert `if-elsif` to `case-when`.
      elsif 'str' == x
      else
      end
    RUBY

    expect_correction(<<~RUBY)
      case x
      when 1
      when 'str'
      else
      end
    RUBY
  end

  it 'registers an offense and corrects when using `==` with constant' do
    expect_offense(<<~RUBY)
      if x == CONSTANT1
      ^^^^^^^^^^^^^^^^^ Convert `if-elsif` to `case-when`.
      elsif CONSTANT2 == x
      else
      end
    RUBY

    expect_correction(<<~RUBY)
      case x
      when CONSTANT1
      when CONSTANT2
      else
      end
    RUBY
  end

  it 'does not register an offense when using `==` with method call with arguments' do
    expect_no_offenses(<<~RUBY)
      if x == foo(1)
      elsif bar(1) == x
      else
      end
    RUBY
  end

  it 'does not register an offense when using `==` with class reference' do
    expect_no_offenses(<<~RUBY)
      if x == Foo
      elsif Bar == x
      else
      end
    RUBY
  end

  it 'does not register an offense when one of the branches contains `==` with class reference' do
    expect_no_offenses(<<~RUBY)
      if x == 1
      elsif x == Foo
      else
      end
    RUBY
  end

  it 'does not register an offense when using `==` with constant containing 1 letter in name' do
    expect_no_offenses(<<~RUBY)
      if x == F
      elsif B == x
      else
      end
    RUBY
  end

  it 'does not register an offense when using `equal?` without a receiver' do
    expect_no_offenses(<<~RUBY)
      if equal?(Foo)
      elsif Bar == x
      else
      end
    RUBY
  end

  it 'registers an offense and corrects when using `is_a?`' do
    expect_offense(<<~RUBY)
      if x.is_a?(Foo)
      ^^^^^^^^^^^^^^^ Convert `if-elsif` to `case-when`.
      elsif x.is_a?(Bar)
      else
      end
    RUBY

    expect_correction(<<~RUBY)
      case x
      when Foo
      when Bar
      else
      end
    RUBY
  end

  it 'registers an offense and corrects when using `match?` with regexp' do
    expect_offense(<<~RUBY)
      if /foo/.match?(x)
      ^^^^^^^^^^^^^^^^^^ Convert `if-elsif` to `case-when`.
      elsif x.match?(/bar/)
      else
      end
    RUBY

    expect_correction(<<~RUBY)
      case x
      when /foo/
      when /bar/
      else
      end
    RUBY
  end

  it 'does not register an offense when using `match?` with non regexp' do
    expect_no_offenses(<<~RUBY)
      if y.match?(x)
      elsif x.match?('str')
      else
      end
    RUBY
  end

  it 'does not register an offense when using `match?` without a receiver' do
    expect_no_offenses(<<~RUBY)
      if match?(/foo/)
      elsif x.match?(/bar/)
      else
      end
    RUBY
  end

  it 'does not register an offense when using `include?` without a receiver' do
    expect_no_offenses(<<~RUBY)
      if include?(Foo)
      elsif include?(Bar)
      else
      end
    RUBY
  end

  it 'does not register an offense when using `cover?` without a receiver' do
    expect_no_offenses(<<~RUBY)
      if x == 1
      elsif cover?(Bar)
      else
      end
    RUBY
  end

  it 'registers an offense and corrects when using `=~`' do
    expect_offense(<<~RUBY)
      if /foo/ =~ x
      ^^^^^^^^^^^^^ Convert `if-elsif` to `case-when`.
      elsif x =~ returns_regexp(arg)
      else
      end
    RUBY

    expect_correction(<<~RUBY)
      case x
      when /foo/
      when returns_regexp(arg)
      else
      end
    RUBY
  end

  it 'does not register an offense when using `=~` in first branch with non regexp' do
    expect_no_offenses(<<~RUBY)
      if x =~ returns_regexp(arg)
      elsif x =~ /foo/
      else
      end
    RUBY
  end

  it 'does not register an offense when using `match?` in first branch with non regexp' do
    expect_no_offenses(<<~RUBY)
      if returns_regexp(arg).match?(x)
      elsif x.match?(/bar/)
      else
      end
    RUBY
  end

  it 'registers an offense and corrects when using `match?` with non regexp in other branches except first' do
    expect_offense(<<~RUBY)
      if /foo/.match?(x)
      ^^^^^^^^^^^^^^^^^^ Convert `if-elsif` to `case-when`.
      elsif returns_regexp(arg).match?(x)
      else
      end
    RUBY

    expect_correction(<<~RUBY)
      case x
      when /foo/
      when returns_regexp(arg)
      else
      end
    RUBY
  end

  it 'registers an offense and corrects when using `include?` with range' do
    expect_offense(<<~RUBY)
      if (1..10).include?(x)
      ^^^^^^^^^^^^^^^^^^^^^^ Convert `if-elsif` to `case-when`.
      elsif (11...100).include?(x)
      else
      end
    RUBY

    expect_correction(<<~RUBY)
      case x
      when 1..10
      when 11...100
      else
      end
    RUBY
  end

  it 'registers an offense and corrects when using `||` within conditions' do
    expect_offense(<<~RUBY)
      if Integer === x || x == 2
      ^^^^^^^^^^^^^^^^^^^^^^^^^^ Convert `if-elsif` to `case-when`.
      elsif 1 == x || (1..10) === x || x.match?(/foo/)
      else
      end
    RUBY

    expect_correction(<<~RUBY)
      case x
      when Integer, 2
      when 1, (1..10), /foo/
      else
      end
    RUBY
  end

  it 'does not register an offense when one of `||` subconditions is not convertible' do
    expect_no_offenses(<<~RUBY)
      if Integer === x || (x == 2 && x == 3)
      elsif 1 == x || (1..10) === x || x.match?(/foo/)
      else
      end
    RUBY
  end

  it 'registers an offense and corrects when using nested conditions with `||`' do
    expect_offense(<<~RUBY)
      if Integer === x || ((x == 2) || (3 == x)) || x =~ /foo/
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Convert `if-elsif` to `case-when`.
      elsif 1 == x || (1..10) === x || x.match?(/bar/)
      else
      end
    RUBY

    expect_correction(<<~RUBY)
      case x
      when Integer, 2, 3, /foo/
      when 1, (1..10), /bar/
      else
      end
    RUBY
  end

  it 'registers an offense and corrects when target is a method call' do
    expect_offense(<<~RUBY)
      if x.type == 1 || x.type == 2
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Convert `if-elsif` to `case-when`.
      elsif /foo/ === x.type
      else
      end
    RUBY

    expect_correction(<<~RUBY)
      case x.type
      when 1, 2
      when /foo/
      else
      end
    RUBY
  end

  it 'does not register an offense when not all conditions contain target' do
    expect_no_offenses(<<~RUBY)
      if x == 2
      elsif 3 == y
      else
      end
    RUBY
  end

  it 'does not register an offense when only single `if`' do
    expect_no_offenses(<<~RUBY)
      if x == 1
      end
    RUBY
  end

  it 'does not register an offense when only `if-else`' do
    expect_no_offenses(<<~RUBY)
      if x == 1
      else
      end
    RUBY
  end

  it 'does not register an offense when using `unless`' do
    expect_no_offenses(<<~RUBY)
      unless x == 1
      else
      end
    RUBY
  end

  it 'does not register an offense when using ternary operator' do
    expect_no_offenses(<<~RUBY)
      x == 1 ? y : z
    RUBY
  end

  it 'does not register an offense when using modifier `if`' do
    expect_no_offenses(<<~RUBY)
      foo if x == 1
    RUBY
  end

  it 'does not register an offense when an object overrides `equal?` with no arity' do
    expect_no_offenses(<<~RUBY)
      if x.equal?
      elsif y
      end
    RUBY
  end

  context 'when using regexp with named captures' do
    it 'does not register an offense with =~ and regexp on lhs' do
      expect_no_offenses(<<~RUBY)
        if /(?<name>.*)/ =~ foo
        elsif foo == 123
        end
      RUBY
    end

    it 'registers and corrects an offense with =~ and regexp on rhs' do
      expect_offense(<<~RUBY)
        if foo =~ /(?<name>.*)/
        ^^^^^^^^^^^^^^^^^^^^^^^ Convert `if-elsif` to `case-when`.
        elsif foo == 123
        end
      RUBY

      expect_correction(<<~RUBY)
        case foo
        when /(?<name>.*)/
        when 123
        end
      RUBY
    end

    it 'does not register an offense with match and regexp on lhs' do
      expect_no_offenses(<<~RUBY)
        if /(?<name>.*)/.match(foo)
        elsif foo == 123
        end
      RUBY
    end

    it 'does not register an offense with match and regexp on rhs' do
      expect_no_offenses(<<~RUBY)
        if foo.match(/(?<name>.*)/)
        elsif foo == 123
        end
      RUBY
    end

    it 'registers and corrects an offense with match? and regexp on lhs' do
      expect_offense(<<~RUBY)
        if /(?<name>.*)/.match?(foo)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Convert `if-elsif` to `case-when`.
        elsif foo == 123
        end
      RUBY

      expect_correction(<<~RUBY)
        case foo
        when /(?<name>.*)/
        when 123
        end
      RUBY
    end

    it 'registers and corrects an offense with match? and regexp on rhs' do
      expect_offense(<<~RUBY)
        if foo.match?(/(?<name>.*)/)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Convert `if-elsif` to `case-when`.
        elsif foo == 123
        end
      RUBY

      expect_correction(<<~RUBY)
        case foo
        when /(?<name>.*)/
        when 123
        end
      RUBY
    end
  end

  context 'MinBranchesCount: 3' do
    let(:cop_config) { { 'MinBranchesCount' => 3 } }

    it 'does not register an offense when branches count is less than required' do
      expect_no_offenses(<<~RUBY)
        if x == 1
        elsif x == 2
        else
        end
      RUBY
    end
  end
end
