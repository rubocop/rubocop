# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Security::YAMLLoad, :config do
  it 'does not register an offense for YAML.dump' do
    expect_no_offenses(<<~RUBY)
      YAML.dump("foo")
      ::YAML.dump("foo")
      Module::YAML.dump("foo")
    RUBY
  end

  it 'does not register an offense for YAML.load under a different namespace' do
    expect_no_offenses('Module::YAML.load("foo")')
  end

  it 'registers an offense and corrects load with a literal string' do
    expect_offense(<<~RUBY)
      YAML.load("--- !ruby/object:Foo {}")
           ^^^^ Prefer using `YAML.safe_load` over `YAML.load`.
    RUBY

    expect_correction(<<~RUBY)
      YAML.safe_load("--- !ruby/object:Foo {}")
    RUBY
  end

  it 'registers an offense and corrects a fully qualified ::YAML.load' do
    expect_offense(<<~RUBY)
      ::YAML.load("--- foo")
             ^^^^ Prefer using `YAML.safe_load` over `YAML.load`.
    RUBY

    expect_correction(<<~RUBY)
      ::YAML.safe_load("--- foo")
    RUBY
  end

  # Ruby 3.1+ (Psych 4) uses `Psych.load` as `Psych.safe_load` by default.
  # https://github.com/ruby/psych/pull/487
  context 'Ruby >= 3.1', :ruby31 do
    it 'does not register an offense and corrects load with a literal string' do
      expect_no_offenses(<<~RUBY)
        YAML.load("--- !ruby/object:Foo {}", permitted_classes: [Foo])
      RUBY
    end

    it 'does not register an offense and corrects a fully qualified `::YAML.load`' do
      expect_no_offenses(<<~RUBY)
        ::YAML.load("--- !ruby/object:Foo {}", permitted_classes: [Foo])
      RUBY
    end
  end
end
