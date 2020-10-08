# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::RedundantSafeNavigation, :config do
  let(:cop_config) do
    { 'IgnoredMethods' => [] }
  end

  it 'registers an offense and corrects when `.&` is used for `nil` method' do
    expect_offense(<<~RUBY)
      foo&.respond_to?(:bar)
         ^^^^^^^^^^^^^^^^^^^ Redundant safe navigation detected.
    RUBY

    expect_correction(<<~RUBY)
      foo.respond_to?(:bar)
    RUBY
  end

  it 'registers an offense and corrects when multiple `.&` are used for `nil` methods' do
    expect_offense(<<~RUBY)
      foo.do_something&.dup&.inspect
                      ^^^^^ Redundant safe navigation detected.
                           ^^^^^^^^^ Redundant safe navigation detected.
    RUBY

    expect_correction(<<~RUBY)
      foo.do_something.dup.inspect
    RUBY
  end

  it 'does not register an offense when using non-nil method with `.&`' do
    expect_no_offenses(<<~RUBY)
      foo.&do_something
    RUBY
  end

  it 'does not register an offense when using `nil` method without `.&`' do
    expect_no_offenses(<<~RUBY)
      foo.dup
    RUBY
  end

  context 'when AllowedMethods is set' do
    let(:cop_config) do
      { 'IgnoredMethods' => ['to_f'] }
    end

    it 'does not register an offense when using ignored `nil` method with `.&`' do
      expect_no_offenses(<<~RUBY)
        foo&.to_f
      RUBY
    end
  end
end
