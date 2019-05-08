# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::BlockComments do
  subject(:cop) { described_class.new }

  it 'registers an offense for block comments' do
    expect_offense(<<~RUBY)
      =begin
      ^^^^^^ Do not use block comments.
      comment
      =end
    RUBY
  end

  it 'accepts regular comments' do
    expect_no_offenses('# comment')
  end

  it 'auto-corrects a block comment into a regular comment' do
    new_source = autocorrect_source(<<~RUBY)
      =begin
      comment line 1

      comment line 2
      =end
      def foo
      end
    RUBY
    expect(new_source).to eq(<<~RUBY)
      # comment line 1
      #
      # comment line 2
      def foo
      end
    RUBY
  end

  it 'auto-corrects an empty block comment by removing it' do
    new_source = autocorrect_source(<<~RUBY)
      =begin
      =end
      def foo
      end
    RUBY
    expect(new_source).to eq(<<~RUBY)
      def foo
      end
    RUBY
  end

  it 'auto-corrects a block comment into a regular comment (without trailing' \
    'newline)' do
    source = <<~RUBY
      =begin
      comment line 1

      comment line 2
      =end
    RUBY

    new_source = autocorrect_source(source.chomp)

    expected_source = <<~RUBY
      # comment line 1
      #
      # comment line 2
    RUBY

    expect(new_source).to eq(expected_source)
  end
end
