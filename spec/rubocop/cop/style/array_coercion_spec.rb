# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::ArrayCoercion, :config do
  it 'registers an offense and corrects when splatting variable into array' do
    expect_offense(<<~RUBY)
      [*paths].each { |path| do_something(path) }
      ^^^^^^^^ Use `Array(paths)` instead of `[*paths]`.
    RUBY

    expect_correction(<<~RUBY)
      Array(paths).each { |path| do_something(path) }
    RUBY
  end

  it 'registers an offense and corrects when converting variable into array with check' do
    expect_offense(<<~RUBY)
      paths = [paths] unless paths.is_a?(Array)
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `Array(paths)` instead of explicit `Array` check.
    RUBY

    expect_correction(<<~RUBY)
      paths = Array(paths)
    RUBY
  end

  it 'does not register an offense when splat is not in array' do
    expect_no_offenses(<<~RUBY)
      first_path, rest = *paths
    RUBY
  end

  it 'does not register an offense when splatting multiple variables into array' do
    expect_no_offenses(<<~RUBY)
      [*paths, '/root'].each { |path| do_something(path) }
    RUBY
  end

  it 'does not register an offense when converting variable into other named array variable with check' do
    expect_no_offenses(<<~RUBY)
      other_paths = [paths] unless paths.is_a?(Array)
    RUBY
  end
end
