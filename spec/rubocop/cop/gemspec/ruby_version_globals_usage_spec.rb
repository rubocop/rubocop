# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Gemspec::RubyVersionGlobalsUsage, :config do
  it 'registers an offense when using `RUBY_VERSION`' do
    expect_offense(<<~RUBY)
      Gem::Specification.new do |spec|
        RUBY_VERSION
        ^^^^^^^^^^^^ Do not use `RUBY_VERSION` in gemspec file.
      end
    RUBY
  end

  it 'registers an offense when using `::RUBY_VERSION`' do
    expect_offense(<<~RUBY)
      Gem::Specification.new do |spec|
        ::RUBY_VERSION
        ^^^^^^^^^^^^^^ Do not use `RUBY_VERSION` in gemspec file.
      end
    RUBY
  end

  it 'does not register an offense when no `RUBY_VERSION`' do
    expect_no_offenses(<<~RUBY)
      Gem::Specification.new do |spec|
      end
    RUBY
  end
end
