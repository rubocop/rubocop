# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::InlineComment, :config do
  it 'registers an offense for a trailing inline comment' do
    expect_offense(<<~RUBY)
      two = 1 + 1 # A trailing inline comment
                  ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid trailing inline comments.
    RUBY
  end

  it 'does not register an offense for special rubocop inline comments' do
    expect_no_offenses(<<~RUBY)
      two = 1 + 1 # rubocop:disable Layout/ExtraSpacing
    RUBY
  end

  it 'does not register an offense for a standalone comment' do
    expect_no_offenses('# A standalone comment')
  end
end
