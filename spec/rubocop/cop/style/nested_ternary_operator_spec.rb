# frozen_string_literal: true

describe RuboCop::Cop::Style::NestedTernaryOperator do
  subject(:cop) { described_class.new }

  it 'registers an offense for a nested ternary operator expression' do
    inspect_source(cop, 'a ? (b ? b1 : b2) : a2')
    expect(cop.offenses.size).to eq(1)
  end

  it 'accepts a non-nested ternary operator within an if' do
    inspect_source(cop, <<-END.strip_indent)
      a = if x
        cond ? b : c
      else
        d
      end
    END
    expect(cop.offenses).to be_empty
  end
end
