# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::FileTouch, :config do
  it 'registers an offense when using `File.open` in append mode with empty block' do
    expect_offense(<<~RUBY)
      File.open(filename, 'a') {}
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `FileUtils.touch(filename)` instead of `File.open` in append mode with empty block.
    RUBY

    expect_correction(<<~RUBY)
      FileUtils.touch(filename)
    RUBY
  end

  it 'does not register an offense when using `File.open` in append mode without a block' do
    expect_no_offenses(<<~RUBY)
      File.open(filename, 'a')
    RUBY
  end

  it 'does not register an offense when using `File.open` in write mode' do
    expect_no_offenses(<<~RUBY)
      File.open(filename, 'w') {}
    RUBY
  end

  it 'does not register an offense when using `File.open` without an access mode' do
    expect_no_offenses(<<~RUBY)
      File.open(filename) {}
    RUBY
  end
end
