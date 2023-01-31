# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::MixedRegexpCaptureTypes, :config do
  it 'registers an offense when both of named and numbered captures are used' do
    expect_offense(<<~RUBY)
      /(?<foo>bar)(baz)/
      ^^^^^^^^^^^^^^^^^^ Do not mix named captures and numbered captures in a Regexp literal.
    RUBY
  end

  it 'does not register offense to a regexp with named capture only' do
    expect_no_offenses(<<~RUBY)
      /(?<foo>foo?<bar>bar)/
    RUBY
  end

  it 'does not register offense to a regexp with numbered capture only' do
    expect_no_offenses(<<~RUBY)
      /(foo)(bar)/
    RUBY
  end

  it 'does not register offense to a regexp with named capture and non-capturing group' do
    expect_no_offenses(<<~RUBY)
      /(?<foo>bar)(?:bar)/
    RUBY
  end

  # See https://github.com/rubocop/rubocop/issues/8083
  it 'does not register offense when using a Regexp cannot be processed by regexp_parser gem' do
    expect_no_offenses(<<~RUBY)
      /data = ({"words":.+}}}[^}]*})/m
    RUBY
  end

  # RuboCop does not know a value of variables that it will contain in the regexp literal.
  # For example, `/(?<foo>#{var}*)` is interpreted as `/(?<foo>*)`.
  # So it does not offense when variables are used in regexp literals.
  context 'when containing a non-regexp literal' do
    it 'does not register an offense when containing a lvar' do
      expect_no_offenses(<<~'RUBY')
        var = '(\d+)'
        /(?<foo>#{var}*)/
      RUBY
    end

    it 'does not register an offense when containing a ivar' do
      expect_no_offenses(<<~'RUBY')
        /(?<foo>#{@var}*)/
      RUBY
    end

    it 'does not register an offense when containing a cvar' do
      expect_no_offenses(<<~'RUBY')
        /(?<foo>#{@@var}*)/
      RUBY
    end

    it 'does not register an offense when containing a gvar' do
      expect_no_offenses(<<~'RUBY')
        /(?<foo>#{$var}*)/
      RUBY
    end

    it 'does not register an offense when containing a method' do
      expect_no_offenses(<<~'RUBY')
        /(?<foo>#{do_something}*)/
      RUBY
    end

    it 'does not register an offense when containing a constant' do
      expect_no_offenses(<<~'RUBY')
        /(?<foo>#{CONST}*)/
      RUBY
    end
  end
end
