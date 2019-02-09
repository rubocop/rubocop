# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::FirstMethodArgumentLineBreak do
  subject(:cop) { described_class.new }

  context 'args listed on the first line' do
    it 'detects the offense' do
      expect_offense(<<-RUBY.strip_indent)
        foo(bar,
            ^^^ Add a line break before the first argument of a multi-line method argument list.
          baz)
      RUBY
    end

    it 'autocorrects the offense' do
      new_source = autocorrect_source(<<-RUBY.strip_indent)
        foo(bar,
          baz)
      RUBY

      expect(new_source).to eq(<<-RUBY.strip_indent)
        foo(
        bar,
          baz)
      RUBY
    end

    context 'when using safe navigation operator', :ruby23 do
      it 'detects the offense' do
        expect_offense(<<-RUBY.strip_indent)
          receiver&.foo(bar,
                        ^^^ Add a line break before the first argument of a multi-line method argument list.
            baz)
        RUBY
      end

      it 'autocorrects the offense' do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          receiver&.foo(bar,
            baz)
        RUBY

        expect(new_source).to eq(<<-RUBY.strip_indent)
          receiver&.foo(
          bar,
            baz)
        RUBY
      end
    end
  end

  context 'hash arg spanning multiple lines' do
    it 'detects the offense' do
      expect_offense(<<-RUBY.strip_indent)
        something(3, bar: 1,
                  ^ Add a line break before the first argument of a multi-line method argument list.
        baz: 2)
      RUBY
    end

    it 'autocorrects the offense' do
      new_source = autocorrect_source(<<-RUBY.strip_indent)
        something(3, bar: 1,
        baz: 2)
      RUBY

      expect(new_source).to eq(<<-RUBY.strip_indent)
        something(
        3, bar: 1,
        baz: 2)
      RUBY
    end
  end

  context 'hash arg without a line break before the first pair' do
    it 'detects the offense' do
      expect_offense(<<-RUBY.strip_indent)
        something(bar: 1,
                  ^^^^^^ Add a line break before the first argument of a multi-line method argument list.
        baz: 2)
      RUBY
    end

    it 'autocorrects the offense' do
      new_source = autocorrect_source(<<-RUBY.strip_indent)
        something(bar: 1,
        baz: 2)
      RUBY

      expect(new_source).to eq(<<-RUBY.strip_indent)
        something(
        bar: 1,
        baz: 2)
      RUBY
    end
  end

  it 'ignores arguments listed on a single line' do
    expect_no_offenses('foo(bar, baz, bing)')
  end

  it 'ignores arguments without parens' do
    expect_no_offenses(<<-RUBY.strip_indent)
      foo bar,
        baz
    RUBY
  end

  it 'ignores methods without arguments' do
    expect_no_offenses('foo')
  end
end
