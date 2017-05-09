# frozen_string_literal: true

describe RuboCop::Cop::Style::IfWithSemicolon do
  subject(:cop) { described_class.new }

  it 'registers an offense for one line if/;/end' do
    expect_offense(<<-RUBY.strip_indent)
      if cond; run else dont end
      ^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not use if x; Use the ternary operator instead.
    RUBY
  end

  it 'accepts one line if/then/end' do
    inspect_source(cop, 'if cond then run else dont end')
    expect(cop.messages).to be_empty
  end

  it 'can handle modifier conditionals' do
    inspect_source(cop, <<-END.strip_indent)
      class Hash
      end if RUBY_VERSION < "1.8.7"
    END
    expect(cop.messages).to be_empty
  end
end
