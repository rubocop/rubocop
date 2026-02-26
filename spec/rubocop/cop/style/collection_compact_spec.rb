# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::CollectionCompact, :config do
  it 'registers an offense and corrects when using `reject` on array to reject nils' do
    expect_offense(<<~RUBY)
      array.reject { |e| e.nil? }
            ^^^^^^^^^^^^^^^^^^^^^ Use `compact` instead of `reject { |e| e.nil? }`.
      array.reject! { |e| e.nil? }
            ^^^^^^^^^^^^^^^^^^^^^^ Use `compact!` instead of `reject! { |e| e.nil? }`.
    RUBY

    expect_correction(<<~RUBY)
      array.compact
      array.compact!
    RUBY
  end

  it 'registers an offense and corrects when using `reject` on hash to reject nils' do
    expect_offense(<<~RUBY)
      hash.reject { |k, v| v.nil? }
           ^^^^^^^^^^^^^^^^^^^^^^^^ Use `compact` instead of `reject { |k, v| v.nil? }`.
      hash.reject! { |k, v| v.nil? }
           ^^^^^^^^^^^^^^^^^^^^^^^^^ Use `compact!` instead of `reject! { |k, v| v.nil? }`.
    RUBY

    expect_correction(<<~RUBY)
      hash.compact
      hash.compact!
    RUBY
  end

  it 'registers an offense and corrects when using `select/select!` to reject nils' do
    expect_offense(<<~RUBY)
      array.select { |e| !e.nil? }
            ^^^^^^^^^^^^^^^^^^^^^^ Use `compact` instead of `select { |e| !e.nil? }`.
      hash.select! { |k, v| !v.nil? }
           ^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `compact!` instead of `select! { |k, v| !v.nil? }`.
    RUBY

    expect_correction(<<~RUBY)
      array.compact
      hash.compact!
    RUBY
  end

  it 'registers an offense and corrects when using `reject` without a receiver to reject nils' do
    expect_offense(<<~RUBY)
      reject { |e| e.nil? }
      ^^^^^^^^^^^^^^^^^^^^^ Use `compact` instead of `reject { |e| e.nil? }`.
    RUBY

    expect_correction(<<~RUBY)
      compact
    RUBY
  end

  it 'does not register an offense when using `reject` to not to rejecting nils' do
    expect_no_offenses(<<~RUBY)
      array.reject { |e| e.odd? }
    RUBY
  end

  it 'does not register an offense when using `compact/compact!`' do
    expect_no_offenses(<<~RUBY)
      array.compact
      array.compact!
    RUBY
  end
end
