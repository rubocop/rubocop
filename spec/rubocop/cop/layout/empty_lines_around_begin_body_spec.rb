# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::EmptyLinesAroundBeginBody, :config do
  shared_examples 'accepts' do |name, code|
    it "accepts #{name}" do
      expect_no_offenses(code)
    end
  end

  it 'registers an offense for begin body starting with a blank' do
    expect_offense(<<~RUBY)
      begin

      ^{} Extra empty line detected at `begin` body beginning.
        foo
      end
    RUBY

    expect_correction(<<~RUBY)
      begin
        foo
      end
    RUBY
  end

  it 'registers an offense for ensure body ending' do
    expect_offense(<<~RUBY)
      begin
        foo
      ensure
        bar

      ^{} Extra empty line detected at `begin` body end.
      end
    RUBY

    expect_correction(<<~RUBY)
      begin
        foo
      ensure
        bar
      end
    RUBY
  end

  it 'registers an offense for begin body ending with a blank' do
    expect_offense(<<~RUBY)
      begin
        foo

      ^{} Extra empty line detected at `begin` body end.
      end
    RUBY

    expect_correction(<<~RUBY)
      begin
        foo
      end
    RUBY
  end

  it 'registers an offense for begin body starting in method' do
    expect_offense(<<~RUBY)
      def bar
        begin

      ^{} Extra empty line detected at `begin` body beginning.
          foo
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      def bar
        begin
          foo
        end
      end
    RUBY
  end

  it 'registers an offense for begin body ending in method' do
    expect_offense(<<~RUBY)
      def bar
        begin
          foo

      ^{} Extra empty line detected at `begin` body end.
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      def bar
        begin
          foo
        end
      end
    RUBY
  end

  it 'registers an offense for begin body starting with rescue' do
    expect_offense(<<~RUBY)
      begin

      ^{} Extra empty line detected at `begin` body beginning.
        foo
      rescue
        bar
      end
    RUBY

    expect_correction(<<~RUBY)
      begin
        foo
      rescue
        bar
      end
    RUBY
  end

  it 'registers an offense for rescue body ending' do
    expect_offense(<<~RUBY)
      begin
        foo
      rescue
        bar

      ^{} Extra empty line detected at `begin` body end.
      end
    RUBY

    expect_correction(<<~RUBY)
      begin
        foo
      rescue
        bar
      end
    RUBY
  end

  it 'registers an offense for else body ending' do
    expect_offense(<<~RUBY)
      begin
        foo
      rescue
        bar
      else
        baz

      ^{} Extra empty line detected at `begin` body end.
      end
    RUBY

    expect_correction(<<~RUBY)
      begin
        foo
      rescue
        bar
      else
        baz
      end
    RUBY
  end

  it 'registers many offenses with complex begin-end' do
    expect_offense(<<~RUBY)
      begin

      ^{} Extra empty line detected at `begin` body beginning.
        do_something1
      rescue RuntimeError
        do_something2
      rescue ArgumentError => ex
        do_something3
      rescue
        do_something3
      else
        do_something4
      ensure
        do_something4

      ^{} Extra empty line detected at `begin` body end.
      end
    RUBY

    expect_correction(<<~RUBY)
      begin
        do_something1
      rescue RuntimeError
        do_something2
      rescue ArgumentError => ex
        do_something3
      rescue
        do_something3
      else
        do_something4
      ensure
        do_something4
      end
    RUBY
  end

  include_examples 'accepts', 'begin block without empty line', <<-RUBY
    begin
      foo
    end
  RUBY

  include_examples 'accepts',
                   'begin block without empty line in a method', <<-RUBY
    def foo
      begin
        bar
      end
    end
  RUBY
end
