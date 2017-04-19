# frozen_string_literal: true

describe RuboCop::Cop::Layout::EmptyComment do
  subject(:cop) { described_class.new }

  let(:code_with_empty_comment) do
    <<-END.strip_indent
      class Foo
        #
        def foo
        end
      end
    END
  end

  let(:code_with_non_empty_comment) do
    <<-END.strip_indent
      class Foo
        # class doc
        def foo
        end
      end
    END
  end

  it 'registers an offense for empty comment' do
    inspect_source(cop, '#')
    expect(cop.offenses.size).to eq(1)
    expect(cop.messages).to eq(['Empty comment.'])
  end

  it 'registers an offense for empty comment with surrounding spaces' do
    inspect_source(cop, '  #      ')
    expect(cop.offenses.size).to eq(1)
    expect(cop.messages).to eq(['Empty comment.'])
  end

  it 'registers an offense for empty comment in the middle of code' do
    inspect_source(cop, code_with_empty_comment)
    expect(cop.offenses.size).to eq(1)
    expect(cop.messages).to eq(['Empty comment.'])
  end

  it 'does not register offence for non-empty comments' do
    inspect_source(cop, code_with_non_empty_comment)
    expect(cop.offenses).to be_empty
  end

  it 'does not register offence for string with # in it' do
    inspect_source(cop, '"#"')
    expect(cop.offenses).to be_empty
  end

  it 'does not register offense for #!' do
    inspect_source(cop, '#!')
    expect(cop.offenses).to be_empty
  end

  it 'auto-corrects empty comment' do
    new_source = autocorrect_source(cop, code_with_empty_comment)
    expected_source = <<-END.strip_indent
      class Foo

        def foo
        end
      end
    END

    expect(new_source).to eq(expected_source)
  end

  it 'does not auto-correct non-empty comment' do
    new_source = autocorrect_source(cop, code_with_non_empty_comment)
    expect(new_source).to eq(code_with_non_empty_comment)
  end
end
