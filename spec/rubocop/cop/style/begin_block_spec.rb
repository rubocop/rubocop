# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::BeginBlock do
  subject(:cop) { described_class.new }

  it 'reports an offense for a BEGIN block' do
    expect_offense(<<-RUBY.strip_indent)
      BEGIN { test }
      ^^^^^ Avoid the use of `BEGIN` blocks.
    RUBY
  end
end
