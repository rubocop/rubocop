# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::CollectionQuerying, :config do
  it 'registers an offense for `.count.positive?`' do
    expect_offense(<<~RUBY)
      x.count.positive?
        ^^^^^^^^^^^^^^^ Use `any?` instead.
    RUBY

    expect_correction(<<~RUBY)
      x.any?
    RUBY
  end

  it 'registers an offense for multiline `.count.positive?`' do
    expect_offense(<<~RUBY)
      x
        .count
         ^^^^^ Use `any?` instead.
        .positive?
    RUBY

    expect_correction(<<~RUBY)
      x
        .any?
    RUBY
  end

  it 'registers an offense for `.count(&:foo?).positive?`' do
    expect_offense(<<~RUBY)
      x.count(&:foo?).positive?
        ^^^^^^^^^^^^^^^^^^^^^^^ Use `any?` instead.
    RUBY

    expect_correction(<<~RUBY)
      x.any?(&:foo?)
    RUBY
  end

  it 'registers an offense for `.count { |item| item.foo? }.positive?`' do
    expect_offense(<<~RUBY)
      x.count { |item| item.foo? }.positive?
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `any?` instead.
    RUBY

    expect_correction(<<~RUBY)
      x.any? { |item| item.foo? }
    RUBY
  end

  it 'registers an offense for `.count { _1.foo? }.positive?`' do
    expect_offense(<<~RUBY)
      x.count { _1.foo? }.positive?
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `any?` instead.
    RUBY

    expect_correction(<<~RUBY)
      x.any? { _1.foo? }
    RUBY
  end

  it 'registers an offense for `.count { it.foo? }.positive?`' do
    expect_offense(<<~RUBY)
      x.count { it.foo? }.positive?
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `any?` instead.
    RUBY

    expect_correction(<<~RUBY)
      x.any? { it.foo? }
    RUBY
  end

  it 'registers an offense for `&.count(&:foo?).positive?`' do
    expect_offense(<<~RUBY)
      x&.count(&:foo?).positive?
         ^^^^^^^^^^^^^^^^^^^^^^^ Use `any?` instead.
    RUBY

    expect_correction(<<~RUBY)
      x&.any?(&:foo?)
    RUBY
  end

  it 'registers an offense for `&.count.positive?`' do
    expect_offense(<<~RUBY)
      x&.count.positive?
         ^^^^^^^^^^^^^^^ Use `any?` instead.
    RUBY

    expect_correction(<<~RUBY)
      x&.any?
    RUBY
  end

  it 'registers an offense for `.count(&:foo?) > 0`' do
    expect_offense(<<~RUBY)
      x.count(&:foo?) > 0
        ^^^^^^^^^^^^^^^^^ Use `any?` instead.
    RUBY

    expect_correction(<<~RUBY)
      x.any?(&:foo?)
    RUBY
  end

  it 'registers an offense for `.count(&:foo?) != 0`' do
    expect_offense(<<~RUBY)
      x.count(&:foo?) != 0
        ^^^^^^^^^^^^^^^^^^ Use `any?` instead.
    RUBY

    expect_correction(<<~RUBY)
      x.any?(&:foo?)
    RUBY
  end

  it 'registers an offense for `.count(&:foo?).zero?`' do
    expect_offense(<<~RUBY)
      x.count(&:foo?).zero?
        ^^^^^^^^^^^^^^^^^^^ Use `none?` instead.
    RUBY

    expect_correction(<<~RUBY)
      x.none?(&:foo?)
    RUBY
  end

  it 'registers an offense for `.count(&:foo?) == 0`' do
    expect_offense(<<~RUBY)
      x.count(&:foo?) == 0
        ^^^^^^^^^^^^^^^^^^ Use `none?` instead.
    RUBY

    expect_correction(<<~RUBY)
      x.none?(&:foo?)
    RUBY
  end

  it 'registers an offense for `.count(&:foo?) == 1`' do
    expect_offense(<<~RUBY)
      x.count(&:foo?) == 1
        ^^^^^^^^^^^^^^^^^^ Use `one?` instead.
    RUBY

    expect_correction(<<~RUBY)
      x.one?(&:foo?)
    RUBY
  end

  context 'when `AllCops/ActiveSupportExtensionsEnabled: true`' do
    let(:config) do
      RuboCop::Config.new('AllCops' => { 'ActiveSupportExtensionsEnabled' => true })
    end

    it 'registers an offense for `.count(&:foo?) > 1`' do
      expect_offense(<<~RUBY)
        x.count(&:foo?) > 1
          ^^^^^^^^^^^^^^^^^ Use `many?` instead.
      RUBY

      expect_correction(<<~RUBY)
        x.many?(&:foo?)
      RUBY
    end
  end

  context 'when `AllCops/ActiveSupportExtensionsEnabled: false`' do
    let(:config) do
      RuboCop::Config.new('AllCops' => { 'ActiveSupportExtensionsEnabled' => false })
    end

    it 'does not register an offense for `.count(&:foo?) > 1`' do
      expect_no_offenses(<<~RUBY)
        x.count(&:foo?) > 1
      RUBY
    end
  end

  it 'does not register an offense for `.count(foo).positive?`' do
    expect_no_offenses(<<~RUBY)
      x.count(foo).positive?
    RUBY
  end

  it 'does not register an offense for `.count(foo: bar).positive?`' do
    expect_no_offenses(<<~RUBY)
      x.count(foo: bar).positive?
    RUBY
  end

  it 'does not register an offense for `.count&.positive?`' do
    expect_no_offenses(<<~RUBY)
      x.count&.positive?
    RUBY
  end

  it 'does not register an offense for `.count`' do
    expect_no_offenses(<<~RUBY)
      x.count
    RUBY
  end

  it 'does not register an offense when `count` does not have a receiver' do
    expect_no_offenses(<<~RUBY)
      count.positive?
    RUBY
  end
end
