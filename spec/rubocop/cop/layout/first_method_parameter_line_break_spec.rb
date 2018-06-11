# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::FirstMethodParameterLineBreak do
  subject(:cop) { described_class.new }

  context 'params listed on the first line' do
    it 'detects the offense' do
      expect_offense(<<-RUBY.strip_indent)
        def foo(bar,
                ^^^ Add a line break before the first parameter of a multi-line method parameter list.
          baz)
          do_something
        end
      RUBY
    end

    it 'autocorrects the offense' do
      new_source = autocorrect_source(<<-RUBY.strip_indent)
        def foo(bar,
          baz)
          do_something
        end
      RUBY

      expect(new_source).to eq(<<-RUBY.strip_indent)
        def foo(
        bar,
          baz)
          do_something
        end
      RUBY
    end
  end

  context 'params on first line of singleton method' do
    it 'detects the offense' do
      expect_offense(<<-RUBY.strip_indent)
        def self.foo(bar,
                     ^^^ Add a line break before the first parameter of a multi-line method parameter list.
          baz)
          do_something
        end
      RUBY
    end

    it 'autocorrects the offense' do
      new_source = autocorrect_source(<<-RUBY.strip_indent)
        def self.foo(bar,
          baz)
          do_something
        end
      RUBY

      expect(new_source).to eq(<<-RUBY.strip_indent)
        def self.foo(
        bar,
          baz)
          do_something
        end
      RUBY
    end
  end

  it 'ignores params listed on a single line' do
    expect_no_offenses(<<-RUBY.strip_indent)
      def foo(bar, baz, bing)
        do_something
      end
    RUBY
  end

  it 'ignores params without parens' do
    expect_no_offenses(<<-RUBY.strip_indent)
      def foo bar,
        baz
        do_something
      end
    RUBY
  end

  it 'ignores single-line methods' do
    expect_no_offenses('def foo(bar, baz) ; bing ; end')
  end

  it 'ignores methods without params' do
    expect_no_offenses(<<-RUBY.strip_indent)
      def foo
        bing
      end
    RUBY
  end

  context 'params with default values' do
    it 'detects the offense' do
      expect_offense(<<-RUBY.strip_indent)
        def foo(bar = [],
                ^^^^^^^^ Add a line break before the first parameter of a multi-line method parameter list.
          baz = 2)
          do_something
        end
      RUBY
    end

    it 'autocorrects the offense' do
      new_source = autocorrect_source(<<-RUBY.strip_indent)
        def foo(bar = [],
          baz = 2)
          do_something
        end
      RUBY

      expect(new_source).to eq(<<-RUBY.strip_indent)
        def foo(
        bar = [],
          baz = 2)
          do_something
        end
      RUBY
    end
  end
end
