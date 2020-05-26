# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Bundler::InsecureProtocolSource, :config do
  it 'registers an offense when using `source :gemcutter`' do
    expect_offense(<<~RUBY)
      source :gemcutter
             ^^^^^^^^^^ The source `:gemcutter` is deprecated because HTTP requests are insecure. Please change your source to 'https://rubygems.org' if possible, or 'http://rubygems.org' if not.
    RUBY

    expect_correction(<<~RUBY)
      source 'https://rubygems.org'
    RUBY
  end

  it 'registers an offense when using `source :rubygems`' do
    expect_offense(<<~RUBY)
      source :rubygems
             ^^^^^^^^^ The source `:rubygems` is deprecated because HTTP requests are insecure. Please change your source to 'https://rubygems.org' if possible, or 'http://rubygems.org' if not.
    RUBY

    expect_correction(<<~RUBY)
      source 'https://rubygems.org'
    RUBY
  end

  it 'registers an offense when using `source :rubyforge`' do
    expect_offense(<<~RUBY)
      source :rubyforge
             ^^^^^^^^^^ The source `:rubyforge` is deprecated because HTTP requests are insecure. Please change your source to 'https://rubygems.org' if possible, or 'http://rubygems.org' if not.
    RUBY

    expect_correction(<<~RUBY)
      source 'https://rubygems.org'
    RUBY
  end
end
