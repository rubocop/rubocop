# frozen_string_literal: true

RSpec.describe RuboCop::Cop::InternalAffairs::LocationLineEqualityComparison, :config do
  it 'registers and corrects an offense when comparing `#loc.line` with LHS and RHS' do
    expect_offense(<<~RUBY)
      node.loc.line == node.parent.loc.line
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `same_line?(node, node.parent)`.
    RUBY

    expect_correction(<<~RUBY)
      same_line?(node, node.parent)
    RUBY
  end

  it 'does not register an offense when using `same_line?`' do
    expect_no_offenses(<<~RUBY)
      same_line?(node, node.parent)
    RUBY
  end
end
