# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Bundler::InsecureProtocolSource, :config do
  it 'registers an offense when using `source :gemcutter`' do
    expect_offense(<<~RUBY)
      source :gemcutter
             ^^^^^^^^^^ The source `:gemcutter` is deprecated [...]
    RUBY

    expect_correction(<<~RUBY)
      source 'https://rubygems.org'
    RUBY
  end

  it 'registers an offense when using `source :rubygems`' do
    expect_offense(<<~RUBY)
      source :rubygems
             ^^^^^^^^^ The source `:rubygems` is deprecated [...]
    RUBY

    expect_correction(<<~RUBY)
      source 'https://rubygems.org'
    RUBY
  end

  it 'registers an offense when using `source :rubyforge`' do
    expect_offense(<<~RUBY)
      source :rubyforge
             ^^^^^^^^^^ The source `:rubyforge` is deprecated [...]
    RUBY

    expect_correction(<<~RUBY)
      source 'https://rubygems.org'
    RUBY
  end
end
