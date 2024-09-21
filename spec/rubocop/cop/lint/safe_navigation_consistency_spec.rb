# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::SafeNavigationConsistency, :config do
  let(:cop_config) { { 'AllowedMethods' => %w[present? blank? try presence] } }

  it 'allows && without receiver' do
    expect_no_offenses(<<~RUBY)
      foo && bar
    RUBY
  end

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

  it 'allows || with comparison method' do
    expect_no_offenses(<<~RUBY)
      foo == bar || foo == baz
    RUBY
  end

  it 'allows safe navigation when different variables are used' do
    expect_no_offenses(<<~RUBY)
      foo&.bar || foobar.baz
    RUBY
  end

  it 'does not register an offense using calling `nil?` after safe navigation with `||`' do
    expect_no_offenses(<<~RUBY)
      foo&.bar || foo.nil?
    RUBY
  end

  it 'does not register an offense using calling `nil?` before safe navigation with `&&`' do
    expect_no_offenses(<<~RUBY)
      foo.nil? && foo&.bar
    RUBY
  end

  it 'does not register an offense when calling to methods that nil responds to' do
    expect_no_offenses(<<~RUBY)
      return true if a.nil? || a&.whatever?
    RUBY
  end

  it 'does not register an offense using safe navigation on the left of &&' do
    expect_no_offenses(<<~RUBY)
      foo&.bar && foo.baz
    RUBY
  end

  it 'registers an offense and corrects using safe navigation on the right of &&' do
    expect_offense(<<~RUBY)
      foo.bar && foo&.baz
                    ^^ Use `.` instead of unnecessary `&.`.
    RUBY

    expect_correction(<<~RUBY)
      foo.bar && foo.baz
    RUBY
  end

  it 'does not register an offense using safe navigation for difference receiver on the right of &&' do
    expect_no_offenses(<<~RUBY)
      x.foo.bar && y.foo&.baz
    RUBY
  end

  it 'registers an offense and corrects using safe navigation on the both of &&' do
    expect_offense(<<~RUBY)
      foo&.bar && foo&.baz
                     ^^ Use `.` instead of unnecessary `&.`.
    RUBY

    expect_correction(<<~RUBY)
      foo&.bar && foo.baz
    RUBY
  end

  it 'registers an offense and corrects using safe navigation on the left of ||' do
    expect_offense(<<~RUBY)
      foo&.bar || foo.baz
                     ^ Use `&.` for consistency with safe navigation.
    RUBY

    expect_correction(<<~RUBY)
      foo&.bar || foo&.baz
    RUBY
  end

  it 'registers an offense and corrects using safe navigation on the right of ||' do
    expect_offense(<<~RUBY)
      foo.bar || foo&.baz
                    ^^ Use `.` instead of unnecessary `&.`.
    RUBY

    expect_correction(<<~RUBY)
      foo.bar || foo.baz
    RUBY
  end

  it 'registers an offense and corrects when there is code before or after the condition' do
    expect_offense(<<~RUBY)
      foo = nil
      foo&.bar || foo.baz
                     ^ Use `&.` for consistency with safe navigation.
      something
    RUBY

    expect_correction(<<~RUBY)
      foo = nil
      foo&.bar || foo&.baz
      something
    RUBY
  end

  it 'registers an offense and corrects non dot method calls for `&&` on LHS only' do
    expect_offense(<<~RUBY)
      foo > 5 && foo&.zero?
                    ^^ Use `.` instead of unnecessary `&.`.
    RUBY

    expect_correction(<<~RUBY)
      foo > 5 && foo.zero?
    RUBY
  end

  it 'registers an offense but does not correct non dot method calls for `||` on RHS only' do
    expect_offense(<<~RUBY)
      foo&.zero? || foo > 5
                    ^^^^^^^ Use `&.` for consistency with safe navigation.
    RUBY

    expect_no_corrections
  end

  it 'does not register an offense assignment when using safe navigation on the left `&`' do
    expect_no_offenses(<<~RUBY)
      foo&.bar && foo.baz = 1
    RUBY
  end

  it 'registers an offense and corrects assignment when using safe navigation on the right `&`' do
    expect_offense(<<~RUBY)
      foo.bar && foo&.baz = 1
                    ^^ Use `.` instead of unnecessary `&.`.
    RUBY

    expect_correction(<<~RUBY)
      foo.bar && foo.baz = 1
    RUBY
  end

  it 'registers an offense and corrects assignment when using safe navigation on the both `&`' do
    expect_offense(<<~RUBY)
      foo&.bar && foo&.baz = 1
                     ^^ Use `.` instead of unnecessary `&.`.
    RUBY

    expect_correction(<<~RUBY)
      foo&.bar && foo.baz = 1
    RUBY
  end

  it 'does not register an offense using safe navigation on the left `&&` and inside of separated conditions' do
    expect_no_offenses(<<~RUBY)
      foo&.bar && foobar.baz && foo.qux
    RUBY
  end

  it 'registers an offense and corrects using safe navigation on the right `&&` and inside of separated conditions' do
    expect_offense(<<~RUBY)
      foo.bar && foobar.baz && foo&.qux
                                  ^^ Use `.` instead of unnecessary `&.`.
    RUBY

    expect_correction(<<~RUBY)
      foo.bar && foobar.baz && foo.qux
    RUBY
  end

  it 'registers an offense and corrects using safe navigation on the right `||` and inside of separated conditions' do
    expect_offense(<<~RUBY)
      foo.bar || foobar.baz || foo&.qux
                                  ^^ Use `.` instead of unnecessary `&.`.
    RUBY

    expect_correction(<<~RUBY)
      foo.bar || foobar.baz || foo.qux
    RUBY
  end

  it 'does not register an offense using safe navigation in conditions on the right hand side' do
    expect_no_offenses(<<~RUBY)
      foobar.baz && foo&.bar && foo.qux
    RUBY
  end

  it 'registers and corrects multiple offenses' do
    expect_no_offenses(<<~RUBY)
      foobar.baz && foo&.bar && foo.qux && foo.foobar
    RUBY
  end

  it 'registers an offense and corrects using unsafe navigation with both && and ||' do
    expect_offense(<<~RUBY)
      foo&.bar && foo&.baz || foo&.qux
                     ^^ Use `.` instead of unnecessary `&.`.
                                 ^^ Use `.` instead of unnecessary `&.`.
    RUBY

    expect_correction(<<~RUBY)
      foo&.bar && foo.baz || foo.qux
    RUBY
  end

  it 'does not register an offense using unsafe navigation with grouped conditions' do
    expect_no_offenses(<<~RUBY)
      foo&.bar && (foo.baz || foo.qux)
    RUBY
  end

  it 'registers an offense and corrects safe navigation that appears after dot method call' do
    expect_offense(<<~RUBY)
      foo.bar && foo.baz || foo&.qux
                               ^^ Use `.` instead of unnecessary `&.`.
    RUBY

    expect_correction(<<~RUBY)
      foo.bar && foo.baz || foo.qux
    RUBY
  end

  it 'does not register an offense safe navigation that appears before dot method call' do
    expect_no_offenses(<<~RUBY)
      foo&.bar || foo&.baz && foo.qux
    RUBY
  end

  it 'does not register an offense using unsafe navigation and the safe navigation appears in a group' do
    expect_no_offenses(<<~RUBY)
      (foo&.bar && foo.baz) || foo.qux
    RUBY
  end

  it 'registers a single offense and corrects when safe navigation is used multiple times' do
    expect_offense(<<~RUBY)
      foo&.bar && foo&.baz || foo.qux
                     ^^ Use `.` instead of unnecessary `&.`.
    RUBY

    expect_correction(<<~RUBY)
      foo&.bar && foo.baz || foo.qux
    RUBY
  end
end
