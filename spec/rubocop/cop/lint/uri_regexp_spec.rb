# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::UriRegexp do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

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

  it 'registers an offense and corrects using `::URI.regexp` ' \
    'without argument' do
    expect_offense(<<~RUBY)
      ::URI.regexp
            ^^^^^^ `::URI.regexp` is obsolete and should not be used. Instead, use `::URI::DEFAULT_PARSER.make_regexp`.
    RUBY

    expect_correction(<<~RUBY)
      ::URI::DEFAULT_PARSER.make_regexp
    RUBY
  end
end
