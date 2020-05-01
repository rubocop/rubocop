# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::IfWithSemicolon do
  subject(:cop) { described_class.new }

  it 'registers an offense and corrects for one line if/;/end' do
    expect_offense(<<~RUBY)
      if cond; run else dont end
      ^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not use if x; Use the ternary operator instead.
    RUBY

    expect_correction(<<~RUBY)
      cond ? run : dont
    RUBY
  end

  it 'accepts without `else` branch' do
    # This case is corrected to a modifier form by `Style/IfUnlessModifier` cop.
    # Therefore, this cop does not handle it.
    expect_no_offenses(<<~RUBY)
      if cond; run end
    RUBY
  end

  it 'can handle modifier conditionals' do
    expect_no_offenses(<<~RUBY)
      class Hash
      end if RUBY_VERSION < "1.8.7"
    RUBY
  end
end
