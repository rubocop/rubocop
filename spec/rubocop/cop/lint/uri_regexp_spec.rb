# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::UriRegexp, :config do
  it 'does not register an offense when using `regexp` without receiver' do
    expect_no_offenses(<<~RUBY)
      regexp('http://example.com')
    RUBY
  end

  it 'does not register an offense when using `regexp` with variable receiver' do
    expect_no_offenses(<<~RUBY)
      m.regexp('http://example.com')
    RUBY
  end

  it 'registers an offense and corrects using `URI.regexp` with argument' do
    expect_offense(<<~RUBY)
      URI.regexp('http://example.com')
          ^^^^^^ `URI.regexp('http://example.com')` is obsolete and should not be used. Instead, use `URI::DEFAULT_PARSER.make_regexp('http://example.com')`.
    RUBY

    expect_correction(<<~RUBY)
      URI::DEFAULT_PARSER.make_regexp('http://example.com')
    RUBY
  end

  it 'registers an offense and corrects using `::URI.regexp` with argument' do
    expect_offense(<<~RUBY)
      ::URI.regexp('http://example.com')
            ^^^^^^ `::URI.regexp('http://example.com')` is obsolete and should not be used. Instead, use `::URI::DEFAULT_PARSER.make_regexp('http://example.com')`.
    RUBY

    expect_correction(<<~RUBY)
      ::URI::DEFAULT_PARSER.make_regexp('http://example.com')
    RUBY
  end

  it 'registers an offense and corrects using `URI.regexp` without argument' do
    expect_offense(<<~RUBY)
      URI.regexp
          ^^^^^^ `URI.regexp` is obsolete and should not be used. Instead, use `URI::DEFAULT_PARSER.make_regexp`.
    RUBY

    expect_correction(<<~RUBY)
      URI::DEFAULT_PARSER.make_regexp
    RUBY
  end

  it 'registers an offense and corrects using `::URI.regexp` without argument' do
    expect_offense(<<~RUBY)
      ::URI.regexp
            ^^^^^^ `::URI.regexp` is obsolete and should not be used. Instead, use `::URI::DEFAULT_PARSER.make_regexp`.
    RUBY

    expect_correction(<<~RUBY)
      ::URI::DEFAULT_PARSER.make_regexp
    RUBY
  end

  context 'array argument' do
    it 'registers an offense and corrects using `URI.regexp` with literal arrays' do
      expect_offense(<<~RUBY)
        URI.regexp(['http', 'https'])
            ^^^^^^ `URI.regexp(['http', 'https'])` is obsolete and should not be used. Instead, use `URI::DEFAULT_PARSER.make_regexp(['http', 'https'])`.
      RUBY

      expect_correction(<<~RUBY)
        URI::DEFAULT_PARSER.make_regexp(['http', 'https'])
      RUBY
    end

    it 'registers an offense and corrects using `URI.regexp` with %w arrays' do
      expect_offense(<<~RUBY)
        URI.regexp(%w[http https])
            ^^^^^^ `URI.regexp(%w[http https])` is obsolete and should not be used. Instead, use `URI::DEFAULT_PARSER.make_regexp(%w[http https])`.
      RUBY

      expect_correction(<<~RUBY)
        URI::DEFAULT_PARSER.make_regexp(%w[http https])
      RUBY
    end

    it 'registers an offense and corrects using `URI.regexp` with %i arrays' do
      expect_offense(<<~RUBY)
        URI.regexp(%i[http https])
            ^^^^^^ `URI.regexp(%i[http https])` is obsolete and should not be used. Instead, use `URI::DEFAULT_PARSER.make_regexp(%i[http https])`.
      RUBY

      expect_correction(<<~RUBY)
        URI::DEFAULT_PARSER.make_regexp(%i[http https])
      RUBY
    end
  end
end
