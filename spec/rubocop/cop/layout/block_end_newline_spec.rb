# frozen_string_literal: true

describe RuboCop::Cop::Layout::BlockEndNewline do
  subject(:cop) { described_class.new }

  it 'does not register an offense for a one-liner' do
    inspect_source(cop, 'test do foo end')
    expect(cop.messages).to be_empty
  end

  it 'does not register an offense for multiline blocks with newlines before '\
     'the end' do
    inspect_source(cop, <<-END.strip_indent)
      test do
        foo
      end
    END
    expect(cop.messages).to be_empty
  end

  it 'registers an offense when multiline block end is not on its own line' do
    expect_offense(<<-END.strip_indent)
      test do
        foo end
            ^^^ Expression at 2, 7 should be on its own line.
    END
  end

  it 'registers an offense when multiline block } is not on its own line' do
    expect_offense(<<-END.strip_indent)
      test {
        foo }
            ^ Expression at 2, 7 should be on its own line.
    END
  end

  it 'autocorrects a do/end block where the end is not on its own line' do
    src = <<-END.strip_indent
      test do
        foo end
    END

    new_source = autocorrect_source(cop, src)

    expect(new_source).to eq(['test do',
                              '  foo ',
                              'end',
                              ''].join("\n"))
  end

  it 'autocorrects a {} block where the } is not on its own line' do
    src = <<-END.strip_indent
      test {
        foo }
    END

    new_source = autocorrect_source(cop, src)

    expect(new_source).to eq(['test {',
                              '  foo ',
                              '}',
                              ''].join("\n"))
  end
end
