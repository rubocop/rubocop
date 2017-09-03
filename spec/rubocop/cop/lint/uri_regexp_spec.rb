# frozen_string_literal: true

describe RuboCop::Cop::Lint::UriRegexp do
  let(:config) { RuboCop::Config.new }
  subject(:cop) { described_class.new(config) }

  it 'registers an offense when using `URI.regexp` with argument' do
    expect_offense(<<-RUBY.strip_indent)
      URI.regexp('http://example.com')
          ^^^^^^ Use `URI::DEFAULT_PARSER.make_regexp('http://example.com')` instead of `URI.regexp('http://example.com')`.
    RUBY
  end

  it 'registers an offense when using `::URI.regexp` with argument' do
    expect_offense(<<-RUBY.strip_indent)
      ::URI.regexp('http://example.com')
            ^^^^^^ Use `::URI::DEFAULT_PARSER.make_regexp('http://example.com')` instead of `::URI.regexp('http://example.com')`.
    RUBY
  end

  it 'registers an offense when using `URI.regexp` without argument' do
    expect_offense(<<-RUBY.strip_indent)
      URI.regexp
          ^^^^^^ Use `URI::DEFAULT_PARSER.make_regexp` instead of `URI.regexp`.
    RUBY
  end

  it 'registers an offense when using `::URI.regexp` without argument' do
    expect_offense(<<-RUBY.strip_indent)
      ::URI.regexp
            ^^^^^^ Use `::URI::DEFAULT_PARSER.make_regexp` instead of `::URI.regexp`.
    RUBY
  end

  it "autocorrects URI::DEFAULT_PARSER.make_regexp('http://example.com')" do
    new_source = autocorrect_source("URI.regexp('http://example.com')")

    expect(
      new_source
    ).to eq "URI::DEFAULT_PARSER.make_regexp('http://example.com')"
  end

  it "autocorrects ::URI::DEFAULT_PARSER.make_regexp('http://example.com')" do
    new_source = autocorrect_source("::URI.regexp('http://example.com')")

    expect(
      new_source
    ).to eq "::URI::DEFAULT_PARSER.make_regexp('http://example.com')"
  end

  it 'autocorrects URI::DEFAULT_PARSER.make_regexp' do
    new_source = autocorrect_source('URI.regexp')

    expect(new_source).to eq 'URI::DEFAULT_PARSER.make_regexp'
  end

  it 'autocorrects ::URI::DEFAULT_PARSER.make_regexp' do
    new_source = autocorrect_source('::URI.regexp')

    expect(new_source).to eq '::URI::DEFAULT_PARSER.make_regexp'
  end
end
