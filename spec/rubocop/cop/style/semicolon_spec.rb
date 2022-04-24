# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::Semicolon, :config do
  let(:cop_config) { { 'AllowAsExpressionSeparator' => false } }

  it 'registers an offense for a single expression' do
    expect_offense(<<~RUBY)
      puts "this is a test";
                           ^ Do not use semicolons to terminate expressions.
    RUBY

    expect_correction(<<~RUBY)
      puts "this is a test"
    RUBY
  end

  it 'registers an offense for several expressions' do
    expect_offense(<<~RUBY)
      puts "this is a test"; puts "So is this"
                           ^ Do not use semicolons to terminate expressions.
    RUBY

    expect_correction(<<~RUBY)
      puts "this is a test"
       puts "So is this"
    RUBY
  end

  it 'registers an offense for one line method with two statements' do
    expect_offense(<<~RUBY)
      def foo(a) x(1); y(2); z(3); end
                                 ^ Do not use semicolons to terminate expressions.
                           ^ Do not use semicolons to terminate expressions.
                     ^ Do not use semicolons to terminate expressions.
    RUBY

    expect_correction(<<~RUBY)
      def foo(a) x(1)
       y(2)
       z(3)
       end
    RUBY
  end

  it 'accepts semicolon before end if so configured' do
    expect_no_offenses('def foo(a) z(3); end')
  end

  it 'accepts semicolon after params if so configured' do
    expect_no_offenses('def foo(a); z(3) end')
  end

  it 'accepts one line method definitions' do
    expect_no_offenses(<<~RUBY)
      def foo1; x(3) end
      def initialize(*_); end
      def foo2() x(3); end
      def foo3; x(3); end
    RUBY
  end

  it 'accepts one line empty class definitions' do
    expect_no_offenses(<<~RUBY)
      # Prefer a single-line format for class ...
      class Foo < Exception; end

      class Bar; end
    RUBY
  end

  it 'accepts one line empty method definitions' do
    expect_no_offenses(<<~RUBY)
      # One exception to the rule are empty-body methods
      def no_op; end

      def foo; end
    RUBY
  end

  it 'accepts one line empty module definitions' do
    expect_no_offenses('module Foo; end')
  end

  it 'registers an offense for semicolon at the end no matter what' do
    expect_offense(<<~RUBY)
      module Foo; end;
                     ^ Do not use semicolons to terminate expressions.
    RUBY

    expect_correction(<<~RUBY)
      module Foo; end
    RUBY
  end

  it 'accept semicolons inside strings' do
    expect_no_offenses(<<~RUBY)
      string = ";
      multi-line string"
    RUBY
  end

  it 'registers an offense for a semicolon at the beginning of a line' do
    expect_offense(<<~RUBY)
      ; puts 1
      ^ Do not use semicolons to terminate expressions.
    RUBY

    expect_correction(" puts 1\n")
  end

  context 'with a multi-expression line without a semicolon' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        def foo
          bar = baz if qux rescue quux
        end
      RUBY
    end
  end

  context 'when AllowAsExpressionSeparator is true' do
    let(:cop_config) { { 'AllowAsExpressionSeparator' => true } }

    it 'accepts several expressions' do
      expect_no_offenses('puts "this is a test"; puts "So is this"')
    end

    it 'accepts one line method with two statements' do
      expect_no_offenses('def foo(a) x(1); y(2); z(3); end')
    end
  end
end
