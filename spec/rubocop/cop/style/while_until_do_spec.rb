# frozen_string_literal: true

describe RuboCop::Cop::Style::WhileUntilDo do
  subject(:cop) { described_class.new }

  it 'registers an offense for do in multiline while' do
    inspect_source(cop, <<-END.strip_indent)
      while cond do
      end
    END
    expect(cop.offenses.size).to eq(1)
  end

  it 'registers an offense for do in multiline until' do
    inspect_source(cop, <<-END.strip_indent)
      until cond do
      end
    END
    expect(cop.offenses.size).to eq(1)
  end

  it 'accepts do in single-line while' do
    inspect_source(cop, 'while cond do something end')
    expect(cop.offenses).to be_empty
  end

  it 'accepts do in single-line until' do
    inspect_source(cop, 'until cond do something end')
    expect(cop.offenses).to be_empty
  end

  it 'accepts multi-line while without do' do
    inspect_source(cop, <<-END.strip_indent)
      while cond
      end
    END
    expect(cop.offenses).to be_empty
  end

  it 'accepts multi-line until without do' do
    inspect_source(cop, <<-END.strip_indent)
      until cond
      end
    END
    expect(cop.offenses).to be_empty
  end

  it 'auto-corrects the usage of "do" in multiline while' do
    new_source = autocorrect_source(cop, <<-END.strip_indent)
      while cond do
      end
    END
    expect(new_source).to eq(<<-END.strip_indent)
      while cond
      end
    END
  end

  it 'auto-corrects the usage of "do" in multiline until' do
    new_source = autocorrect_source(cop, <<-END.strip_indent)
      until cond do
      end
    END
    expect(new_source).to eq(<<-END.strip_indent)
      until cond
      end
    END
  end
end
