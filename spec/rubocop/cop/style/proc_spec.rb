# frozen_string_literal: true

describe RuboCop::Cop::Style::Proc do
  subject(:cop) { described_class.new }

  it 'registers an offense for a Proc.new call' do
    inspect_source(cop, 'f = Proc.new { |x| puts x }')
    expect(cop.offenses.size).to eq(1)
  end

  it 'accepts the proc method' do
    inspect_source(cop, 'f = proc { |x| puts x }')
    expect(cop.offenses).to be_empty
  end

  it 'accepts the Proc.new call outside of block' do
    inspect_source(cop, 'p = Proc.new')
    expect(cop.offenses).to be_empty
  end

  it 'auto-corrects Proc.new to proc' do
    corrected = autocorrect_source(cop, ['Proc.new { test }'])
    expect(corrected).to eq 'proc { test }'
  end
end
