# frozen_string_literal: true

describe RuboCop::Cop::Style::CharacterLiteral do
  subject(:cop) { described_class.new }

  it 'registers an offense for character literals' do
    inspect_source(cop, 'x = ?x')
    expect(cop.offenses.size).to eq(1)
  end

  it 'registers an offense for literals like \n' do
    inspect_source(cop, 'x = ?\n')
    expect(cop.offenses.size).to eq(1)
  end

  it 'accepts literals like ?\C-\M-d' do
    inspect_source(cop, 'x = ?\C-\M-d')
    expect(cop.offenses).to be_empty
  end

  it 'accepts ? in a %w literal' do
    inspect_source(cop, '%w{? A}')
    expect(cop.offenses).to be_empty
  end

  it "auto-corrects ?x to 'x'" do
    new_source = autocorrect_source(cop, 'x = ?x')
    expect(new_source).to eq("x = 'x'")
  end

  it 'auto-corrects ?\n to "\\n"' do
    new_source = autocorrect_source(cop, 'x = ?\n')
    expect(new_source).to eq('x = "\\n"')
  end

  it 'auto-corrects ?\' to "\'"' do
    new_source = autocorrect_source(cop, 'x = ?\'')
    expect(new_source).to eq('x = "\'"')
  end
end
