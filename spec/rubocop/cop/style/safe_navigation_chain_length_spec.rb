# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::SafeNavigationChainLength, :config do
  let(:cop_config) { { 'Max' => max } }
  let(:max) { 2 }

  it 'registers an offense when exceeding safe navigation chain length' do
    expect_offense(<<~RUBY)
      x&.foo&.bar&.baz
      ^^^^^^^^^^^^^^^^ Avoid safe navigation chains longer than 2 calls.
    RUBY
  end

  it 'registers an offense when exceeding safe navigation chain length on method call receiver' do
    expect_offense(<<~RUBY)
      x.foo&.bar&.baz&.zoo
      ^^^^^^^^^^^^^^^^^^^^ Avoid safe navigation chains longer than 2 calls.
    RUBY
  end

  it 'registers an offense when exceeding safe navigation chain length in the middle of call chain' do
    expect_offense(<<~RUBY)
      x.foo&.bar&.baz&.zoo.nil?
      ^^^^^^^^^^^^^^^^^^^^ Avoid safe navigation chains longer than 2 calls.
    RUBY
  end

  it 'does not register an offense when not exceeding safe navigation chain length' do
    expect_no_offenses(<<~RUBY)
      x&.foo&.bar
    RUBY
  end

  it 'does not register an offense when using regular methods calls' do
    expect_no_offenses(<<~RUBY)
      x.foo.bar
    RUBY
  end

  context 'Max: 1' do
    let(:max) { 1 }

    it 'registers an offense when exceeding safe navigation chain length' do
      expect_offense(<<~RUBY)
        x&.foo&.bar
        ^^^^^^^^^^^ Avoid safe navigation chains longer than 1 calls.
      RUBY
    end
  end

  context 'Max: 3' do
    let(:max) { 3 }

    it 'registers an offense when exceeding safe navigation chain length' do
      expect_offense(<<~RUBY)
        x&.foo&.bar&.baz&.zoo
        ^^^^^^^^^^^^^^^^^^^^^ Avoid safe navigation chains longer than 3 calls.
      RUBY
    end

    it 'does not register an offense when not exceeding safe navigation chain length' do
      expect_no_offenses(<<~RUBY)
        x&.foo&.bar&.baz
      RUBY
    end
  end
end
