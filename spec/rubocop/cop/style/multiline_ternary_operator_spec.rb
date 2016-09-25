# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::MultilineTernaryOperator do
  subject(:cop) { described_class.new }

  it 'registers offense when the if branch and the else branch are ' \
     'on a separate line from the condition' do
    inspect_source(cop, ['a = cond ?',
                         '  b : c'])
    expect(cop.offenses.size).to eq(1)
  end

  it 'registers an offense when the false branch is on a separate line' do
    inspect_source(cop, ['a = cond ? b :',
                         '    c'].join("\n"))

    expect(cop.offenses.size).to eq(1)
  end

  it 'registers an offense when everything is on a separate line' do
    inspect_source(cop, ['a = cond ?',
                         '    b :',
                         '    c'])

    expect(cop.offenses.size).to eq(1)
  end

  it 'accepts a single line ternary operator expression' do
    inspect_source(cop, 'a = cond ? b : c')
    expect(cop.offenses).to be_empty
  end
end
