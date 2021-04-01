# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::EndBlock, :config do
  it 'reports an offense and corrects END block' do
    expect_offense(<<~RUBY)
      END { test }
      ^^^ Avoid the use of `END` blocks. Use `Kernel#at_exit` instead.
    RUBY

    expect_correction(<<~RUBY)
      at_exit { test }
    RUBY
  end

  it 'does not report offenses for other blocks' do
    expect_no_offenses(<<~RUBY)
      end_block { test }
    RUBY
  end
end
