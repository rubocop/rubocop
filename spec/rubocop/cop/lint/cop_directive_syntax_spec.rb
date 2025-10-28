# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::CopDirectiveSyntax, :config do
  it 'does not register an offense for a single cop name' do
    expect_no_offenses(<<~RUBY)
      # rubocop:disable Layout/LineLength
    RUBY
  end

  it 'does not register an offense for a single cop department' do
    expect_no_offenses(<<~RUBY)
      # rubocop:disable Layout
    RUBY
  end

  it 'does not register an offense for multiple cops' do
    expect_no_offenses(<<~RUBY)
      # rubocop:disable Layout/LineLength, Style/Encoding
    RUBY
  end

  it 'does not register an offense for `all` cops' do
    expect_no_offenses(<<~RUBY)
      # rubocop:disable all
    RUBY
  end

  it 'does not register an offense for enable directives' do
    expect_no_offenses(<<~RUBY)
      # rubocop:enable Layout/LineLength
    RUBY
  end

  it 'does not register an offense for todo directives' do
    expect_no_offenses(<<~RUBY)
      # rubocop:todo Layout/LineLength
    RUBY
  end

  it 'registers an offense for multiple cops a without comma' do
    expect_offense(<<~RUBY)
      # rubocop:disable Layout/LineLength Style/Encoding
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Malformed directive comment detected. Cop names must be separated by commas. Comment in the directive must start with `--`.
    RUBY
  end

  it 'registers an offense for duplicate directives' do
    expect_offense(<<~RUBY)
      # rubocop:disable Layout/LineLength # rubocop:disable Style/Encoding
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Malformed directive comment detected. Cop names must be separated by commas. Comment in the directive must start with `--`.
    RUBY
  end

  it 'registers an offense for missing cop name' do
    expect_offense(<<~RUBY)
      # rubocop:disable
      ^^^^^^^^^^^^^^^^^ Malformed directive comment detected. The cop name is missing.
    RUBY
  end

  it 'registers an offense for incorrect mode' do
    expect_offense(<<~RUBY)
      # rubocop:disabled Layout/LineLength
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Malformed directive comment detected. The mode name must be one of `enable`, `disable`, `todo`, `push`, or `pop`.
    RUBY
  end

  it 'registers an offense if the mode name is missing' do
    expect_offense(<<~RUBY)
      # rubocop:
      ^^^^^^^^^^ Malformed directive comment detected. The mode name is missing.
    RUBY
  end

  it 'does not register an offense when a comment does not start with `# rubocop:`, which is not a directive comment' do
    expect_no_offenses(<<~RUBY)
      # "rubocop:disable Layout/LineLength"
    RUBY
  end

  it 'does not register an offense for duplicate comment out' do
    expect_no_offenses(<<~RUBY)
      # # rubocop:disable Layout/LineLength
    RUBY
  end

  it 'does not register an offense for an extra trailing comment' do
    expect_no_offenses(<<~RUBY)
      # rubocop:disable Layout/LineLength -- This is a good comment.
    RUBY
  end

  it 'does not register an offense for a single line directive with trailing comment' do
    expect_no_offenses(<<~RUBY)
      a = 1 # rubocop:disable Layout/LineLength -- This is a good comment.
    RUBY
  end

  it 'registers an offense when trailing comment does not start with `--`' do
    expect_offense(<<~RUBY)
      # rubocop:disable Layout/LineLength == This is a bad comment.
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Malformed directive comment detected. Cop names must be separated by commas. Comment in the directive must start with `--`.
    RUBY
  end
end
