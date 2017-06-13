# frozen_string_literal: true

describe RuboCop::Cop::Style::CharacterLiteral do
  subject(:cop) { described_class.new }

  it 'registers an offense for character literals' do
    expect_offense(<<-RUBY.strip_indent)
      x = ?x
          ^^ Do not use the character literal - use string literal instead.
    RUBY
  end

  it 'registers an offense for literals like \n' do
    expect_offense(<<-'RUBY'.strip_indent)
      x = ?\n
          ^^^ Do not use the character literal - use string literal instead.
    RUBY
  end

  it 'accepts literals like ?\C-\M-d' do
    expect_no_offenses('x = ?\C-\M-d')
  end

  it 'accepts ? in a %w literal' do
    expect_no_offenses('%w{? A}')
  end

  it "auto-corrects ?x to 'x'" do
    new_source = autocorrect_source('x = ?x')
    expect(new_source).to eq("x = 'x'")
  end

  it 'auto-corrects ?\n to "\\n"' do
    new_source = autocorrect_source('x = ?\n')
    expect(new_source).to eq('x = "\\n"')
  end

  it 'auto-corrects ?\' to "\'"' do
    new_source = autocorrect_source('x = ?\'')
    expect(new_source).to eq('x = "\'"')
  end
end
