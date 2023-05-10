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

  it 'registers an offense for a semicolon at the beginning of a block' do
    expect_offense(<<~RUBY)
      foo {; bar }
           ^ Do not use semicolons to terminate expressions.
    RUBY

    expect_correction(<<~RUBY)
      foo { bar }
    RUBY
  end

  it 'registers an offense for a semicolon at the end of a block' do
    expect_offense(<<~RUBY)
      foo { bar; }
               ^ Do not use semicolons to terminate expressions.
    RUBY

    expect_correction(<<~RUBY)
      foo { bar }
    RUBY
  end

  it 'registers an offense for a semicolon at the middle of a block' do
    expect_offense(<<~RUBY)
      foo { bar; baz }
               ^ Do not use semicolons to terminate expressions.
    RUBY

    expect_correction(<<~RUBY)
      foo { bar
       baz }
    RUBY
  end

  it 'does not register an offense when using a comment containing a semicolon before a block' do
    expect_no_offenses(<<~RUBY)
      # ;
      foo {
      }
    RUBY
  end

  it 'registers an offense when a semicolon at before a closing brace of string interpolation' do
    expect_offense(<<~'RUBY')
      "#{foo;}"
            ^ Do not use semicolons to terminate expressions.
    RUBY

    expect_correction(<<~'RUBY')
      "#{foo}"
    RUBY
  end

  it 'registers an offense when a semicolon at after a opening brace of string interpolation' do
    expect_offense(<<~'RUBY')
      "#{;foo}"
         ^ Do not use semicolons to terminate expressions.
    RUBY

    expect_correction(<<~'RUBY')
      "#{foo}"
    RUBY
  end

  it 'registers an offense for range (`1..42`) with semicolon' do
    expect_offense(<<~RUBY)
      1..42;
           ^ Do not use semicolons to terminate expressions.
    RUBY

    expect_correction(<<~RUBY)
      1..42
    RUBY
  end

  it 'registers an offense for range (`1...42`) with semicolon' do
    expect_offense(<<~RUBY)
      1...42;
            ^ Do not use semicolons to terminate expressions.
    RUBY

    expect_correction(<<~RUBY)
      1...42
    RUBY
  end

  context 'Ruby >= 2.6', :ruby26 do
    it 'registers an offense for endless range with semicolon (irange only)' do
      expect_offense(<<~RUBY)
        42..;
            ^ Do not use semicolons to terminate expressions.
      RUBY

      expect_correction(<<~RUBY)
        (42..)
      RUBY
    end

    it 'registers an offense for endless range with semicolon (irange and erange)' do
      expect_offense(<<~RUBY)
        42..;
            ^ Do not use semicolons to terminate expressions.
        42...;
             ^ Do not use semicolons to terminate expressions.
      RUBY

      expect_correction(<<~RUBY)
        (42..)
        (42...)
      RUBY
    end

    it 'registers an offense for endless range with semicolon in the method definition' do
      expect_offense(<<~RUBY)
        def foo
          42..;
              ^ Do not use semicolons to terminate expressions.
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo
          (42..)
        end
      RUBY
    end

    it 'does not register an offense for endless range without semicolon' do
      expect_no_offenses(<<~RUBY)
        42..
      RUBY
    end
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
