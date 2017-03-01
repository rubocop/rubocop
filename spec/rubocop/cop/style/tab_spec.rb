# frozen_string_literal: true

describe RuboCop::Cop::Style::Tab do
  subject(:cop) { described_class.new }

  it 'registers an offense for a line indented with tab' do
    inspect_source(cop, "\tx = 0")
    expect(cop.offenses.size).to eq(1)
  end

  it 'registers an offense for a line indented with multiple tabs' do
    inspect_source(cop, "\t\t\tx = 0")
    expect(cop.offenses.size).to eq(1)
  end

  it 'registers an offense for a line indented with mixed whitespace' do
    inspect_source(cop, " \tx = 0")
    expect(cop.offenses.size).to eq(1)
  end

  it 'registers offenses before __END__ but not after' do
    inspect_source(cop, ["\tx = 0",
                         '__END__',
                         "\tx = 0"])
    expect(cop.messages).to eq(['Tab detected.'])
  end

  it 'accepts a line with tab in a string' do
    inspect_source(cop, "(x = \"\t\")")
    expect(cop.offenses).to be_empty
  end

  it 'accepts a line which begins with tab in a string' do
    inspect_source(cop, "x = '\n\thello'")
    expect(cop.offenses).to be_empty
  end

  it 'accepts a line which begins with tab in a heredoc' do
    inspect_source(cop, "x = <<HELLO\n\thello\nHELLO")
    expect(cop.offenses).to be_empty
  end

  it 'auto-corrects a line indented with tab' do
    new_source = autocorrect_source(cop, ["\tx = 0"])
    expect(new_source).to eq('  x = 0')
  end

  it 'auto-corrects a line indented with multiple tabs' do
    new_source = autocorrect_source(cop, ["\t\t\tx = 0"])
    expect(new_source).to eq('      x = 0')
  end

  it 'auto-corrects a line indented with mixed whitespace' do
    new_source = autocorrect_source(cop, [" \tx = 0"])
    expect(new_source).to eq('   x = 0')
  end

  it 'auto-corrects a line with tab in a string indented with tab' do
    new_source = autocorrect_source(cop, ["\t(x = \"\t\")"])
    expect(new_source).to eq("  (x = \"\t\")")
  end
end
