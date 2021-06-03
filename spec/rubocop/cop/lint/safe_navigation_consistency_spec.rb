# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::SafeNavigationConsistency, :config do
  let(:cop_config) { { 'AllowedMethods' => %w[present? blank? try presence] } }

  it 'allows && without safe navigation' do
    expect_no_offenses(<<~RUBY)
      foo.bar && foo.baz
    RUBY
  end

  it 'allows || without safe navigation' do
    expect_no_offenses(<<~RUBY)
      foo.bar || foo.baz
    RUBY
  end

  it 'allows safe navigation when different variables are used' do
    expect_no_offenses(<<~RUBY)
      foo&.bar || foobar.baz
    RUBY
  end

  it 'allows calls to methods that nil responds to' do
    expect_no_offenses(<<~RUBY)
      return true if a.nil? || a&.whatever?
    RUBY
  end

  it 'registers an offense and corrects using safe navigation on the left of &&' do
    expect_offense(<<~RUBY)
      foo&.bar && foo.baz
      ^^^^^^^^^^^^^^^^^^^ Ensure that safe navigation is used consistently inside of `&&` and `||`.
    RUBY

    expect_correction(<<~RUBY)
      foo&.bar && foo&.baz
    RUBY
  end

  it 'registers an offense and corrects using safe navigation on the right of &&' do
    expect_offense(<<~RUBY)
      foo.bar && foo&.baz
      ^^^^^^^^^^^^^^^^^^^ Ensure that safe navigation is used consistently inside of `&&` and `||`.
    RUBY

    expect_correction(<<~RUBY)
      foo&.bar && foo&.baz
    RUBY
  end

  it 'registers an offense and corrects using safe navigation on the left of ||' do
    expect_offense(<<~RUBY)
      foo&.bar || foo.baz
      ^^^^^^^^^^^^^^^^^^^ Ensure that safe navigation is used consistently inside of `&&` and `||`.
    RUBY

    expect_correction(<<~RUBY)
      foo&.bar || foo&.baz
    RUBY
  end

  it 'registers an offense and corrects using safe navigation on the right of ||' do
    expect_offense(<<~RUBY)
      foo.bar || foo&.baz
      ^^^^^^^^^^^^^^^^^^^ Ensure that safe navigation is used consistently inside of `&&` and `||`.
    RUBY

    expect_correction(<<~RUBY)
      foo&.bar || foo&.baz
    RUBY
  end

  it 'registers an offense and corrects when there is code before or after the condition' do
    expect_offense(<<~RUBY)
      foo = nil
      foo&.bar || foo.baz
      ^^^^^^^^^^^^^^^^^^^ Ensure that safe navigation is used consistently inside of `&&` and `||`.
      something
    RUBY

    expect_correction(<<~RUBY)
      foo = nil
      foo&.bar || foo&.baz
      something
    RUBY
  end

  it 'registers an offense but does not correct non dot method calls' do
    expect_offense(<<~RUBY)
      foo&.zero? || foo > 5
      ^^^^^^^^^^^^^^^^^^^^^ Ensure that safe navigation is used consistently inside of `&&` and `||`.
    RUBY

    expect_no_corrections
  end

  it 'registers an offense and corrects assignment' do
    expect_offense(<<~RUBY)
      foo&.bar && foo.baz = 1
      ^^^^^^^^^^^^^^^^^^^^^^^ Ensure that safe navigation is used consistently inside of `&&` and `||`.
    RUBY

    expect_correction(<<~RUBY)
      foo&.bar && foo&.baz = 1
    RUBY
  end

  it 'registers an offense and corrects using safe navigation inside of separated conditions' do
    expect_offense(<<~RUBY)
      foo&.bar && foobar.baz && foo.qux
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Ensure that safe navigation is used consistently inside of `&&` and `||`.
    RUBY

    expect_correction(<<~RUBY)
      foo&.bar && foobar.baz && foo&.qux
    RUBY
  end

  it 'registers an offense and corrects using safe navigation in conditions ' \
     'on the right hand side' do
    expect_offense(<<~RUBY)
      foobar.baz && foo&.bar && foo.qux
                    ^^^^^^^^^^^^^^^^^^^ Ensure that safe navigation is used consistently inside of `&&` and `||`.
    RUBY

    expect_correction(<<~RUBY)
      foobar.baz && foo&.bar && foo&.qux
    RUBY
  end

  it 'registers and corrects multiple offenses' do
    expect_offense(<<~RUBY)
      foobar.baz && foo&.bar && foo.qux && foo.foobar
                    ^^^^^^^^^^^^^^^^^^^ Ensure that safe navigation is used consistently inside of `&&` and `||`.
                    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Ensure that safe navigation is used consistently inside of `&&` and `||`.
    RUBY

    expect_correction(<<~RUBY)
      foobar.baz && foo&.bar && foo&.qux && foo&.foobar
    RUBY
  end

  it 'registers an offense and corrects using unsafe navigation with both && and ||' do
    expect_offense(<<~RUBY)
      foo&.bar && foo.baz || foo.qux
      ^^^^^^^^^^^^^^^^^^^ Ensure that safe navigation is used consistently inside of `&&` and `||`.
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Ensure that safe navigation is used consistently inside of `&&` and `||`.
    RUBY

    expect_correction(<<~RUBY)
      foo&.bar && foo&.baz || foo&.qux
    RUBY
  end

  it 'registers an offense and corrects using unsafe navigation with grouped conditions' do
    expect_offense(<<~RUBY)
      foo&.bar && (foo.baz || foo.qux)
      ^^^^^^^^^^^^^^^^^^^^ Ensure that safe navigation is used consistently inside of `&&` and `||`.
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Ensure that safe navigation is used consistently inside of `&&` and `||`.
    RUBY

    expect_correction(<<~RUBY)
      foo&.bar && (foo&.baz || foo&.qux)
    RUBY
  end

  it 'registers an offense and corrects unsafe navigation that appears before safe navigation' do
    expect_offense(<<~RUBY)
      foo.bar && foo.baz || foo&.qux
                 ^^^^^^^^^^^^^^^^^^^ Ensure that safe navigation is used consistently inside of `&&` and `||`.
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Ensure that safe navigation is used consistently inside of `&&` and `||`.
    RUBY

    expect_correction(<<~RUBY)
      foo&.bar && foo&.baz || foo&.qux
    RUBY
  end

  it 'registers an offense and corrects using unsafe navigation ' \
     'and the safe navigation appears in a group' do
    expect_offense(<<~RUBY)
      (foo&.bar && foo.baz) || foo.qux
       ^^^^^^^^^^^^^^^^^^^ Ensure that safe navigation is used consistently inside of `&&` and `||`.
       ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Ensure that safe navigation is used consistently inside of `&&` and `||`.
    RUBY

    expect_correction(<<~RUBY)
      (foo&.bar && foo&.baz) || foo&.qux
    RUBY
  end

  it 'registers a single offense and corrects when safe navigation is used multiple times' do
    expect_offense(<<~RUBY)
      foo&.bar && foo&.baz || foo.qux
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Ensure that safe navigation is used consistently inside of `&&` and `||`.
    RUBY

    expect_correction(<<~RUBY)
      foo&.bar && foo&.baz || foo&.qux
    RUBY
  end
end
