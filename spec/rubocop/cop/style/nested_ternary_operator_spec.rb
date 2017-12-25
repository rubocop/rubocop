# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::NestedTernaryOperator do
  subject(:cop) { described_class.new }

  it 'registers an offense for a nested ternary operator expression' do
    expect_offense(<<-RUBY.strip_indent)
      a ? (b ? b1 : b2) : a2
           ^^^^^^^^^^^ Ternary operators must not be nested. Prefer `if` or `else` constructs instead.
    RUBY
  end

  it 'accepts a non-nested ternary operator within an if' do
    expect_no_offenses(<<-RUBY.strip_indent)
      a = if x
        cond ? b : c
      else
        d
      end
    RUBY
  end
end
