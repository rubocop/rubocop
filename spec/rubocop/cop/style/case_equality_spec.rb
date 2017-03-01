# frozen_string_literal: true

describe RuboCop::Cop::Style::CaseEquality do
  subject(:cop) { described_class.new }

  it 'registers an offense for ===' do
    inspect_source(cop, 'Array === var')
    expect(cop.offenses.size).to eq(1)
    expect(cop.highlights).to eq(['==='])
  end
end
