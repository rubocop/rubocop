# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::IfWithSemicolon do
  subject(:cop) { described_class.new }

  it 'registers an offense for one line if/;/end' do
    expect_offense(<<-RUBY.strip_indent)
      if cond; run else dont end
      ^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not use if x; Use the ternary operator instead.
    RUBY
  end

  it 'accepts one line if/then/end' do
    expect_no_offenses('if cond then run else dont end')
  end

  it 'can handle modifier conditionals' do
    expect_no_offenses(<<-RUBY.strip_indent)
      class Hash
      end if RUBY_VERSION < "1.8.7"
    RUBY
  end
end
