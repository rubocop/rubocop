# frozen_string_literal: true

describe RuboCop::Cop::Layout::Tab do
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
    expect_offense(<<-END.strip_indent)
      \tx = 0
      ^ Tab detected.
      __END__
      \tx = 0
    END
  end

  it 'accepts a line with tab in a string' do
    expect_no_offenses("(x = \"\t\")")
  end

  it 'accepts a line which begins with tab in a string' do
    expect_no_offenses("x = '\n\thello'")
  end

  it 'accepts a line which begins with tab in a heredoc' do
    expect_no_offenses("x = <<HELLO\n\thello\nHELLO")
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
