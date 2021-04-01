# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::UriEscapeUnescape, :config do
  it "registers an offense when using `URI.escape('http://example.com')`" do
    expect_offense(<<~RUBY)
      URI.escape('http://example.com')
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ `URI.escape` method is obsolete and should not be used. Instead, use `CGI.escape`, `URI.encode_www_form` or `URI.encode_www_form_component` depending on your specific use case.
    RUBY
  end

  it "registers an offense when using `URI.escape('@?@!', '!?')`" do
    expect_offense(<<~RUBY)
      URI.escape('@?@!', '!?')
      ^^^^^^^^^^^^^^^^^^^^^^^^ `URI.escape` method is obsolete and should not be used. Instead, use `CGI.escape`, `URI.encode_www_form` or `URI.encode_www_form_component` depending on your specific use case.
    RUBY
  end

  it "registers an offense when using `::URI.escape('http://example.com')`" do
    expect_offense(<<~RUBY)
      ::URI.escape('http://example.com')
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ `::URI.escape` method is obsolete and should not be used. Instead, use `CGI.escape`, `URI.encode_www_form` or `URI.encode_www_form_component` depending on your specific use case.
    RUBY
  end

  it "registers an offense when using `URI.encode('http://example.com')`" do
    expect_offense(<<~RUBY)
      URI.encode('http://example.com')
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ `URI.encode` method is obsolete and should not be used. Instead, use `CGI.escape`, `URI.encode_www_form` or `URI.encode_www_form_component` depending on your specific use case.
    RUBY
  end

  it "registers an offense when using `::URI.encode('http://example.com)`" do
    expect_offense(<<~RUBY)
      ::URI.encode('http://example.com')
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ `::URI.encode` method is obsolete and should not be used. Instead, use `CGI.escape`, `URI.encode_www_form` or `URI.encode_www_form_component` depending on your specific use case.
    RUBY
  end

  it 'registers an offense when using `URI.unescape(enc_uri)`' do
    expect_offense(<<~RUBY)
      URI.unescape(enc_uri)
      ^^^^^^^^^^^^^^^^^^^^^ `URI.unescape` method is obsolete and should not be used. Instead, use `CGI.unescape`, `URI.decode_www_form` or `URI.decode_www_form_component` depending on your specific use case.
    RUBY
  end

  it 'registers an offense when using `::URI.unescape(enc_uri)`' do
    expect_offense(<<~RUBY)
      ::URI.unescape(enc_uri)
      ^^^^^^^^^^^^^^^^^^^^^^^ `::URI.unescape` method is obsolete and should not be used. Instead, use `CGI.unescape`, `URI.decode_www_form` or `URI.decode_www_form_component` depending on your specific use case.
    RUBY
  end

  it 'registers an offense when using `URI.decode(enc_uri)`' do
    expect_offense(<<~RUBY)
      URI.decode(enc_uri)
      ^^^^^^^^^^^^^^^^^^^ `URI.decode` method is obsolete and should not be used. Instead, use `CGI.unescape`, `URI.decode_www_form` or `URI.decode_www_form_component` depending on your specific use case.
    RUBY
  end

  it 'registers an offense when using `::URI.decode(enc_uri)`' do
    expect_offense(<<~RUBY)
      ::URI.decode(enc_uri)
      ^^^^^^^^^^^^^^^^^^^^^ `::URI.decode` method is obsolete and should not be used. Instead, use `CGI.unescape`, `URI.decode_www_form` or `URI.decode_www_form_component` depending on your specific use case.
    RUBY
  end
end
