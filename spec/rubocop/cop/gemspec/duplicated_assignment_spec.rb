# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Gemspec::DuplicatedAssignment, :config do
  it 'registers an offense when using `name=` twice' do
    expect_offense(<<~RUBY)
      Gem::Specification.new do |spec|
        spec.name = 'rubocop'
        spec.name = 'rubocop2'
        ^^^^^^^^^^^^^^^^^^^^^^ `name=` method calls already given on line 2 of the gemspec.
      end
    RUBY
  end

  it 'registers an offense when using `version=` twice' do
    expect_offense(<<~RUBY)
      require 'rubocop/version'

      Gem::Specification.new do |spec|
        spec.version = RuboCop::Version::STRING
        spec.version = RuboCop::Version::STRING
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ `version=` method calls already given on line 4 of the gemspec.
      end
    RUBY
  end

  it 'registers an offense when using `name=` twice with `cbase`' do
    expect_offense(<<~RUBY)
      ::Gem::Specification.new do |spec|
        spec.name = 'rubocop'
        spec.name = 'rubocop2'
        ^^^^^^^^^^^^^^^^^^^^^^ `name=` method calls already given on line 2 of the gemspec.
      end
    RUBY
  end

  it 'registers an offense when using `required_ruby_version=` twice' do
    expect_offense(<<~RUBY)
      ::Gem::Specification.new do |spec|
        spec.required_ruby_version = '2.5'
        spec.required_ruby_version = '2.6'
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ `required_ruby_version=` method calls already given on line 2 of the gemspec.
      end
    RUBY
  end

  it 'does not register an offense when using `<<` twice' do
    expect_no_offenses(<<~RUBY)
      Gem::Specification.new do |spec|
        spec.requirements << 'libmagick, v6.0'
        spec.requirements << 'A good graphics card'
      end
    RUBY
  end

  it 'does not register an offense when using `spec.add_dependency` twice' do
    expect_no_offenses(<<~RUBY)
      Gem::Specification.new do |spec|
        spec.add_runtime_dependency('parallel', '~> 1.10')
        spec.add_runtime_dependency('parser', '>= 2.3.3.1', '< 3.0')
      end
    RUBY
  end

  it 'does not register an offense when `name=` method call is not block value' do
    expect_no_offenses(<<~RUBY)
      Gem::Specification.new do |spec|
        foo = Foo.new
        foo.name = :foo
        foo.name = :bar
      end
    RUBY
  end
end
