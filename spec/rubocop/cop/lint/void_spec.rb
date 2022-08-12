# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::Void, :config do
  described_class::BINARY_OPERATORS.each do |op|
    it "registers an offense for void op #{op} if not on last line" do
      expect_offense(<<~RUBY, op: op)
        a %{op} b
          ^{op} Operator `#{op}` used in void context.
        a %{op} b
          ^{op} Operator `#{op}` used in void context.
        a %{op} b
      RUBY
    end

    it "accepts void op #{op} if on last line" do
      expect_no_offenses(<<~RUBY)
        something
        a #{op} b
      RUBY
    end

    it "accepts void op #{op} by itself without a begin block" do
      expect_no_offenses("a #{op} b")
    end
  end

  sign_unary_operators = %i[+ -]
  other_unary_operators = %i[~ !]
  unary_operators = sign_unary_operators + other_unary_operators

  sign_unary_operators.each do |op|
    it "registers an offense for void sign op #{op} if not on last line" do
      expect_offense(<<~RUBY, op: op)
        %{op}b
        ^{op} Operator `#{op}@` used in void context.
        %{op}b
        ^{op} Operator `#{op}@` used in void context.
        %{op}b
      RUBY
    end
  end

  other_unary_operators.each do |op|
    it "registers an offense for void unary op #{op} if not on last line" do
      expect_offense(<<~RUBY, op: op)
        %{op}b
        ^{op} Operator `#{op}` used in void context.
        %{op}b
        ^{op} Operator `#{op}` used in void context.
        %{op}b
      RUBY
    end
  end

  unary_operators.each do |op|
    it "accepts void unary op #{op} if on last line" do
      expect_no_offenses(<<~RUBY)
        something
        #{op}b
      RUBY
    end

    it "accepts void unary op #{op} by itself without a begin block" do
      expect_no_offenses("#{op}b")
    end
  end

  %w[var @var @@var VAR $var].each do |var|
    it "registers an offense for void var #{var} if not on last line" do
      expect_offense(<<~RUBY, var: var)
        %{var} = 5
        %{var}
        ^{var} Variable `#{var}` used in void context.
        top
      RUBY
    end
  end

  %w(1 2.0 :test /test/ [1] {}).each do |lit|
    it "registers an offense for void lit #{lit} if not on last line" do
      expect_offense(<<~RUBY, lit: lit)
        %{lit}
        ^{lit} Literal `#{lit}` used in void context.
        top
      RUBY
    end
  end

  it 'registers an offense for void `self` if not on last line' do
    expect_offense(<<~RUBY)
      self; top
      ^^^^ `self` used in void context.
    RUBY
  end

  it 'registers an offense for void `defined?` if not on last line' do
    expect_offense(<<~RUBY)
      defined?(x)
      ^^^^^^^^^^^ `defined?(x)` used in void context.
      top
    RUBY
  end

  context 'when checking for methods with no side effects' do
    let(:config) do
      RuboCop::Config.new('Lint/Void' => { 'CheckForMethodsWithNoSideEffects' => true })
    end

    it 'registers an offense if not on last line' do
      expect_offense(<<~RUBY)
        x.sort
        ^^^^^^ Method `#sort` used in void context. Did you mean `#sort!`?
        top(x)
      RUBY
    end

    it 'registers an offense for chained methods' do
      expect_offense(<<~RUBY)
        x.sort.flatten
        ^^^^^^^^^^^^^^ Method `#flatten` used in void context. Did you mean `#flatten!`?
        top(x)
      RUBY
    end
  end

  context 'when not checking for methods with no side effects' do
    let(:config) do
      RuboCop::Config.new('Lint/Void' => { 'CheckForMethodsWithNoSideEffects' => false })
    end

    it 'does not register an offense for void nonmutating methods' do
      expect_no_offenses(<<~RUBY)
        x.sort
        top(x)
      RUBY
    end
  end

  it 'registers an offense for void literal in a method definition' do
    expect_offense(<<~RUBY)
      def something
        42
        ^^ Literal `42` used in void context.
        42
      end
    RUBY
  end

  it 'registers two offenses for void literals in an initialize method' do
    expect_offense(<<~RUBY)
      def initialize
        42
        ^^ Literal `42` used in void context.
        42
        ^^ Literal `42` used in void context.
      end
    RUBY
  end

  it 'registers two offenses for void literals in a setter method' do
    expect_offense(<<~RUBY)
      def foo=(rhs)
        42
        ^^ Literal `42` used in void context.
        42
        ^^ Literal `42` used in void context.
      end
    RUBY
  end

  it 'registers two offenses for void literals in a `#each` method' do
    expect_offense(<<~RUBY)
      array.each do |_item|
        42
        ^^ Literal `42` used in void context.
        42
        ^^ Literal `42` used in void context.
      end
    RUBY
  end

  it 'handles `#each` block with single expression' do
    expect_offense(<<~RUBY)
      array.each do |_item|
        42
        ^^ Literal `42` used in void context.
      end
    RUBY
  end

  context 'Ruby 2.7', :ruby27 do
    it 'registers two offenses for void literals in `#tap` method' do
      expect_offense(<<~RUBY)
        foo.tap do
          _1
          ^^ Variable `_1` used in void context.
          42
        end
      RUBY
    end
  end

  it 'accepts empty block' do
    expect_no_offenses(<<~RUBY)
      array.each { |_item| }
    RUBY
  end

  it 'registers two offenses for void literals in `#tap` method' do
    expect_offense(<<~RUBY)
      foo.tap do |x|
        42
        ^^ Literal `42` used in void context.
        42
        ^^ Literal `42` used in void context.
      end
    RUBY
  end

  it 'registers two offenses for void literals in a `for`' do
    expect_offense(<<~RUBY)
      for _item in array do
        42
        ^^ Literal `42` used in void context.
        42
        ^^ Literal `42` used in void context.
      end
    RUBY
  end

  it 'handles explicit begin blocks' do
    expect_offense(<<~RUBY)
      begin
       1
       ^ Literal `1` used in void context.
       2
      end
    RUBY
  end

  it 'accepts short call syntax' do
    expect_no_offenses(<<~RUBY)
      lambda.(a)
      top
    RUBY
  end

  it 'accepts backtick commands' do
    expect_no_offenses(<<~RUBY)
      `touch x`
      nil
    RUBY
  end

  it 'accepts percent-x commands' do
    expect_no_offenses(<<~RUBY)
      %x(touch x)
      nil
    RUBY
  end

  it 'accepts method with irange block' do
    expect_no_offenses(<<~RUBY)
      def foo
        1..100.times.each { puts 1 }
        do_something
      end
    RUBY
  end

  it 'accepts method with erange block' do
    expect_no_offenses(<<~RUBY)
      def foo
        1...100.times.each { puts 1 }
        do_something
      end
    RUBY
  end
end
