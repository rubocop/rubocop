# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Gemspec::AddRuntimeDependency, :config do
  it 'registers an offense when using `add_runtime_dependency`' do
    expect_offense(<<~RUBY)
      Gem::Specification.new do |spec|
        spec.add_runtime_dependency('rubocop')
             ^^^^^^^^^^^^^^^^^^^^^^ Use `add_dependency` instead of `add_runtime_dependency`.
      end
    RUBY

    expect_correction(<<~RUBY)
      Gem::Specification.new do |spec|
        spec.add_dependency('rubocop')
      end
    RUBY
  end

  it 'does not register an offense when using `add_dependency`' do
    expect_no_offenses(<<~RUBY)
      Gem::Specification.new do |spec|
        spec.add_dependency('rubocop')
      end
    RUBY
  end

  it 'does not register an offense when using `add_development_dependency`' do
    expect_no_offenses(<<~RUBY)
      Gem::Specification.new do |spec|
        spec.add_development_dependency('rubocop')
      end
    RUBY
  end

  it 'does not register an offense when using `add_runtime_dependency` without receiver' do
    expect_no_offenses(<<~RUBY)
      add_runtime_dependency('rubocop')
    RUBY
  end

  it 'does not register an offense when using `add_runtime_dependency` without arguments' do
    expect_no_offenses(<<~RUBY)
      spec.add_runtime_dependency
    RUBY
  end
end
