# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Gemspec::RubyVersionGlobalsUsage, :config do
  subject(:cop) { described_class.new(config) }

  it 'registers an offense when using `RUBY_VERSION`' do
    expect_offense(<<~RUBY, '/path/to/foo.gemspec')
      Gem::Specification.new do |spec|
        RUBY_VERSION
        ^^^^^^^^^^^^ `RUBY_VERSION` used in gemspec file.
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
