# frozen_string_literal: true

describe RuboCop::Cop::Style::TernaryOperator do
  subject(:cop) { described_class.new }

  it 'registers offense when the if branch and the else branch are ' \
     'on a separate line from the condition' do
    inspect_source(<<-RUBY.strip_indent)
      a = cond ?
        b : c
    RUBY
    expect(cop.offenses.size).to eq(1)
  end

  it 'registers an offense when the false branch is on a separate line' do
    inspect_source(<<-RUBY.strip_indent)
      a = cond ? b :
          c
    RUBY

    expect(cop.offenses.size).to eq(1)
  end

  it 'registers an offense when everything is on a separate line' do
    inspect_source(<<-RUBY.strip_indent)
      a = cond ?
          b :
          c
    RUBY

    expect(cop.offenses.size).to eq(1)
  end

  it 'does not accept a single line ternary operator expression' do
    inspect_source(<<-RUBY.strip_indent)
      a = cond ? b : c
    RUBY

    expect(cop.offenses.size).to eq(1)
  end
end
