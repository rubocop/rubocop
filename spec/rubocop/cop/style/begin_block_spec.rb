# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::BeginBlock, :config do
  it 'reports an offense for a BEGIN block' do
    expect_offense(<<~RUBY)
      BEGIN { test }
      ^^^^^ Avoid the use of `BEGIN` blocks.
    RUBY
  end
end
