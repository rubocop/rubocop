# frozen_string_literal: true

describe RuboCop::Cop::Lint::Void do
  subject(:cop) { described_class.new }

  described_class::BINARY_OPERATORS.each do |op|
    it "registers an offense for void op #{op} if not on last line" do
      inspect_source(<<-RUBY.strip_indent)
        a #{op} b
        a #{op} b
        a #{op} b
      RUBY
      expect(cop.offenses.size).to eq(2)
    end
  end

  described_class::BINARY_OPERATORS.each do |op|
    it "accepts void op #{op} if on last line" do
      expect_no_offenses(<<-RUBY.strip_indent)
        something
        a #{op} b
      RUBY
    end
  end

  described_class::BINARY_OPERATORS.each do |op|
    it "accepts void op #{op} by itself without a begin block" do
      expect_no_offenses("a #{op} b")
    end
  end

  unary_operators = %i[+ - ~ !]
  unary_operators.each do |op|
    it "registers an offense for void op #{op} if not on last line" do
      inspect_source(<<-RUBY.strip_indent)
        #{op}b
        #{op}b
        #{op}b
      RUBY
      expect(cop.offenses.size).to eq(2)
    end
  end

  unary_operators.each do |op|
    it "accepts void op #{op} if on last line" do
      expect_no_offenses(<<-RUBY.strip_indent)
        something
        #{op}b
      RUBY
    end
  end

  unary_operators.each do |op|
    it "accepts void op #{op} by itself without a begin block" do
      expect_no_offenses("#{op}b")
    end
  end

  %w[var @var @@var VAR $var].each do |var|
    it "registers an offense for void var #{var} if not on last line" do
      inspect_source(["#{var} = 5",
                      var,
                      'top'])
      expect(cop.offenses.size).to eq(1)
    end
  end

  %w(1 2.0 :test /test/ [1] {}).each do |lit|
    it "registers an offense for void lit #{lit} if not on last line" do
      inspect_source([lit,
                      'top'])
      expect(cop.offenses.size).to eq(1)
    end
  end

  it 'registers an offense for void `self` if not on last line' do
    expect_offense(<<-RUBY.strip_indent)
      self; top
      ^^^^ `self` used in void context.
    RUBY
  end

  it 'registers an offense for void `defined?` if not on last line' do
    expect_offense(<<-RUBY.strip_indent)
      defined?(x)
      ^^^^^^^^^^^ `defined?(x)` used in void context.
      top
    RUBY
  end

  it 'registers an offense for void literal in a method definition' do
    expect_offense(<<-RUBY.strip_indent)
      def something
        42
        ^^ Literal `42` used in void context.
        42
      end
    RUBY
  end

  it 'registers two offenses for void literals in an initialize method' do
    expect_offense(<<-RUBY.strip_indent)
      def initialize
        42
        ^^ Literal `42` used in void context.
        42
        ^^ Literal `42` used in void context.
      end
    RUBY
  end

  it 'registers two offenses for void literals in a setter method' do
    expect_offense(<<-RUBY.strip_indent)
      def foo=(rhs)
        42
        ^^ Literal `42` used in void context.
        42
        ^^ Literal `42` used in void context.
      end
    RUBY
  end

  it 'registers two offenses for void literals in a `#each` method' do
    expect_offense(<<-RUBY.strip_indent)
      array.each do |_item|
        42
        ^^ Literal `42` used in void context.
        42
        ^^ Literal `42` used in void context.
      end
    RUBY
  end

  it 'registers two offenses for void literals in a `for`' do
    expect_offense(<<-RUBY.strip_indent)
      for _item in array do
        42
        ^^ Literal `42` used in void context.
        42
        ^^ Literal `42` used in void context.
      end
    RUBY
  end

  it 'handles explicit begin blocks' do
    expect_offense(<<-RUBY.strip_indent)
      begin
       1
       ^ Literal `1` used in void context.
       2
      end
    RUBY
  end

  it 'accepts short call syntax' do
    expect_no_offenses(<<-RUBY.strip_indent)
      lambda.(a)
      top
    RUBY
  end

  it 'accepts backtick commands' do
    expect_no_offenses(<<-RUBY.strip_indent)
      `touch x`
      nil
    RUBY
  end

  it 'accepts percent-x commands' do
    expect_no_offenses(<<-RUBY.strip_indent)
      %x(touch x)
      nil
    RUBY
  end
end
