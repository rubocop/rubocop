# frozen_string_literal: true

describe RuboCop::Cop::Style::Semicolon, :config do
  subject(:cop) { described_class.new(config) }
  let(:cop_config) { { 'AllowAsExpressionSeparator' => false } }

  it 'registers an offense for a single expression' do
    expect_offense(<<-RUBY.strip_indent)
      puts "this is a test";
                           ^ Do not use semicolons to terminate expressions.
    RUBY
  end

  it 'registers an offense for several expressions' do
    expect_offense(<<-RUBY.strip_indent)
      puts "this is a test"; puts "So is this"
                           ^ Do not use semicolons to terminate expressions.
    RUBY
  end

  it 'registers an offense for one line method with two statements' do
    expect_offense(<<-RUBY.strip_indent)
      def foo(a) x(1); y(2); z(3); end
                     ^ Do not use semicolons to terminate expressions.
    RUBY
  end

  it 'accepts semicolon before end if so configured' do
    expect_no_offenses('def foo(a) z(3); end')
  end

  it 'accepts semicolon after params if so configured' do
    expect_no_offenses('def foo(a); z(3) end')
  end

  it 'accepts one line method definitions' do
    expect_no_offenses(<<-RUBY.strip_indent)
      def foo1; x(3) end
      def initialize(*_); end
      def foo2() x(3); end
      def foo3; x(3); end
    RUBY
  end

  it 'accepts one line empty class definitions' do
    expect_no_offenses(<<-RUBY.strip_indent)
      # Prefer a single-line format for class ...
      class Foo < Exception; end

      class Bar; end
    RUBY
  end

  it 'accepts one line empty method definitions' do
    expect_no_offenses(<<-RUBY.strip_indent)
      # One exception to the rule are empty-body methods
      def no_op; end

      def foo; end
    RUBY
  end

  it 'accepts one line empty module definitions' do
    expect_no_offenses('module Foo; end')
  end

  it 'registers an offense for semicolon at the end no matter what' do
    expect_offense(<<-RUBY.strip_indent)
      module Foo; end;
                     ^ Do not use semicolons to terminate expressions.
    RUBY
  end

  it 'accept semicolons inside strings' do
    expect_no_offenses(<<-RUBY.strip_indent)
      string = ";
      multi-line string"
    RUBY
  end

  it 'registers an offense for a semicolon at the beginning of a line' do
    expect_offense(<<-RUBY.strip_indent)
      ; puts 1
      ^ Do not use semicolons to terminate expressions.
    RUBY
  end

  it 'auto-corrects semicolons when syntactically possible' do
    corrected =
      autocorrect_source(cop, <<-RUBY.strip_indent)
        module Foo; end;
        puts "this is a test";
        puts "this is a test"; puts "So is this"
        def foo(a) x(1); y(2); z(3); end
        ;puts 1
      RUBY
    expect(corrected)
      .to eq(<<-RUBY.strip_indent)
        module Foo; end
        puts "this is a test"
        puts "this is a test"; puts "So is this"
        def foo(a) x(1); y(2); z(3); end
        puts 1
      RUBY
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
