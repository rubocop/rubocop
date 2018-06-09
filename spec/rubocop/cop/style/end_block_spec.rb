# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::EndBlock do
  subject(:cop) { described_class.new }

  it 'reports an offense for an END block' do
    expect_offense(<<-RUBY.strip_indent)
      END { test }
      ^^^ Avoid the use of `END` blocks. Use `Kernel#at_exit` instead.
    RUBY
  end
end
