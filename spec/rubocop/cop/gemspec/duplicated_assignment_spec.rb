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

  it 'registers an offense when using `metadata#[]=` with same key twice' do
    expect_offense(<<~RUBY)
      ::Gem::Specification.new do |spec|
        spec.metadata['key'] = 1
        spec.metadata[:key] = 2
        spec.metadata['key'] = 2
        ^^^^^^^^^^^^^^^^^^^^^^^^ `metadata['key']=` method calls already given on line 2 of the gemspec.
        spec.metadata['key'] = 3
        ^^^^^^^^^^^^^^^^^^^^^^^^ `metadata['key']=` method calls already given on line 2 of the gemspec.
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

  it 'does not register an offense when using `#[]=` with different keys' do
    expect_no_offenses(<<~RUBY)
      Gem::Specification.new do |spec|
        spec.metadata[:foo] = 1
        spec.metadata[:bar] = 2
      end
    RUBY
  end

  it 'does not register an offense when using `#[]=` with same keys and different receivers' do
    expect_no_offenses(<<~RUBY)
      Gem::Specification.new do |spec|
        spec.misc[:foo] = 1
        spec.metadata[:foo] = 2
      end
    RUBY
  end

  it 'does not register an offense when using both `metadata#[]=` and `metadata=`' do
    expect_no_offenses(<<~RUBY)
      Gem::Specification.new do |spec|
        spec.metadata = { foo: 1 }
        spec.metadata[:foo] = 1
      end
    RUBY
  end

  it 'does not register an offense when using `metadata#[]=` with same key twice which are not literals' do
    expect_no_offenses(<<~RUBY)
      Gem::Specification.new do |spec|
        spec.metadata[foo()] = 1
        spec.metadata[foo()] = 2
      end
    RUBY
  end

  context 'with non-standard `[]=` method arity' do
    it 'does not register an offense with single argument' do
      expect_no_offenses(<<~RUBY)
        Gem::Specification.new do |spec|
          spec.metadata.[]=(1)
          spec.metadata.[]=(2)
        end
      RUBY
    end

    it 'does not register an offense with more than two arguments' do
      expect_no_offenses(<<~RUBY)
        Gem::Specification.new do |spec|
          spec.metadata[1, 2] = 3
          spec.metadata[1, 2] = 3
        end
      RUBY
    end
  end
end
