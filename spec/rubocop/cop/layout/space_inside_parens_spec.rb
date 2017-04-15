# frozen_string_literal: true

describe RuboCop::Cop::Layout::SpaceInsideParens do
  subject(:cop) { described_class.new }

  it 'registers an offense for spaces inside parens' do
    inspect_source(cop, <<-END.strip_indent)
      f( 3)
      g = (a + 3 )
    END
    expect(cop.messages).to eq(['Space inside parentheses detected.'] * 2)
  end

  it 'accepts parentheses in block parameter list' do
    inspect_source(cop, <<-END.strip_indent)
      list.inject(Tms.new) { |sum, (label, item)|
      }
    END
    expect(cop.messages).to be_empty
  end

  it 'accepts parentheses with no spaces' do
    inspect_source(cop, 'split("\n")')
    expect(cop.messages).to be_empty
  end

  it 'accepts parentheses with line break' do
    inspect_source(cop, <<-END.strip_indent)
      f(
        1)
    END
    expect(cop.messages).to be_empty
  end

  it 'accepts parentheses with comment and line break' do
    inspect_source(cop, <<-END.strip_indent)
      f( # Comment
        1)
    END
    expect(cop.messages).to be_empty
  end

  it 'auto-corrects unwanted space' do
    new_source = autocorrect_source(cop, <<-END.strip_indent)
      f( 3)
      g = ( a + 3 )
    END
    expect(new_source).to eq(<<-END.strip_indent)
      f(3)
      g = (a + 3)
    END
  end
end
