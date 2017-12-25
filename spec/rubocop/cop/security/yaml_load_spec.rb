# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Security::YAMLLoad, :config do
  subject(:cop) { described_class.new(config) }

  it 'does not register an offense for YAML.dump' do
    expect_no_offenses(<<-RUBY.strip_indent)
      YAML.dump("foo")
      ::YAML.dump("foo")
      Module::YAML.dump("foo")
    RUBY
  end

  it 'does not register an offense for YAML.load under a different namespace' do
    expect_no_offenses('Module::YAML.load("foo")')
  end

  it 'registers an offense for load with a literal string' do
    expect_offense(<<-RUBY.strip_indent)
      YAML.load("--- foo")
           ^^^^ Prefer using `YAML.safe_load` over `YAML.load`.
    RUBY
  end

  it 'registers an offense for a fully qualified ::YAML.load' do
    expect_offense(<<-RUBY.strip_indent)
      ::YAML.load("--- foo")
             ^^^^ Prefer using `YAML.safe_load` over `YAML.load`.
    RUBY
  end

  it 'autocorrects load to safe_load' do
    expect(autocorrect_source('::YAML.load("-- foo")')).to eq(
      '::YAML.safe_load("-- foo")'
    )
  end
end
