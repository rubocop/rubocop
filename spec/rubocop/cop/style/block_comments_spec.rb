# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::BlockComments, :config do
  it 'registers an offense for block comments' do
    expect_offense(<<~RUBY)
      =begin
      ^^^^^^ Do not use block comments.
      comment
      =end
    RUBY

    expect_correction(<<~RUBY)
      # comment
    RUBY
  end

  it 'accepts regular comments' do
    expect_no_offenses('# comment')
  end

  it 'autocorrects a block comment into a regular comment' do
    expect_offense(<<~RUBY)
      =begin
      ^^^^^^ Do not use block comments.
      comment line 1

      comment line 2
      =end
      def foo
      end
    RUBY

    expect_correction(<<~RUBY)
      # comment line 1
      #
      # comment line 2
      def foo
      end
    RUBY
  end

  it 'autocorrects an empty block comment by removing it' do
    expect_offense(<<~RUBY)
      =begin
      ^^^^^^ Do not use block comments.
      =end
      def foo
      end
    RUBY

    expect_correction(<<~RUBY)
      def foo
      end
    RUBY
  end

  it 'autocorrects a block comment into a regular comment (without trailing newline)' do
    expect_offense(<<~RUBY)
      =begin
      ^^^^^^ Do not use block comments.
      comment line 1

      comment line 2
      =end
    RUBY

    expect_correction(<<~RUBY)
      # comment line 1
      #
      # comment line 2
    RUBY
  end
end
