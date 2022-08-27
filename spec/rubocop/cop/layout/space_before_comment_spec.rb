# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::SpaceBeforeComment, :config do
  it 'registers an offense and corrects missing space before an EOL comment' do
    expect_offense(<<~RUBY)
      a += 1# increment
            ^^^^^^^^^^^ Put a space before an end-of-line comment.
    RUBY

    expect_correction(<<~RUBY)
      a += 1 # increment
    RUBY
  end

  it 'accepts an EOL comment with a preceding space' do
    expect_no_offenses('a += 1 # increment')
  end

  it 'accepts a comment that begins a line' do
    expect_no_offenses('# comment')
  end

  it 'accepts a doc comment' do
    expect_no_offenses(<<~RUBY)
      =begin
      Doc comment
      =end
    RUBY
  end

  it 'registers an offense and corrects after a heredoc' do
    expect_offense(<<~RUBY)
      <<~STR# my string
            ^^^^^^^^^^^ Put a space before an end-of-line comment.
        text
      STR
    RUBY

    expect_correction(<<~RUBY)
      <<~STR # my string
        text
      STR
    RUBY
  end
end
