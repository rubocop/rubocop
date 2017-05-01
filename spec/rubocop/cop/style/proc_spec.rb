# frozen_string_literal: true

describe RuboCop::Cop::Style::Proc do
  subject(:cop) { described_class.new }

  it 'registers an offense for a Proc.new call' do
    inspect_source(cop, 'f = Proc.new { |x| puts x }')
    expect(cop.offenses.size).to eq(1)
  end

  it 'accepts the proc method' do
    expect_no_offenses('f = proc { |x| puts x }')
  end

  it 'accepts the Proc.new call outside of block' do
    expect_no_offenses('p = Proc.new')
  end

  it 'auto-corrects Proc.new to proc' do
    corrected = autocorrect_source(cop, ['Proc.new { test }'])
    expect(corrected).to eq 'proc { test }'
  end
end
