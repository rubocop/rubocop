# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::SpaceAfterNot, :config do
  it 'registers an offense and corrects a single space after !' do
    expect_offense(<<~RUBY)
      ! something
      ^^^^^^^^^^^ Do not leave space between `!` and its argument.
    RUBY

    expect_correction(<<~RUBY)
      !something
    RUBY
  end

  it 'registers an offense and corrects multiple spaces after !' do
    expect_offense(<<~RUBY)
      !   something
      ^^^^^^^^^^^^^ Do not leave space between `!` and its argument.
    RUBY

    expect_correction(<<~RUBY)
      !something
    RUBY
  end

  it 'accepts no space after !' do
    expect_no_offenses('!something')
  end

  it 'accepts space after not keyword' do
    expect_no_offenses('not something')
  end

  it 'registers an offense and corrects space after ! with ' \
     'the negated receiver wrapped in parentheses' do
    expect_offense(<<~RUBY)
      ! (model)
      ^^^^^^^^^ Do not leave space between `!` and its argument.
    RUBY

    expect_correction(<<~RUBY)
      !(model)
    RUBY
  end
end
