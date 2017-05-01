# frozen_string_literal: true

describe RuboCop::Cop::Layout::InitialIndentation do
  subject(:cop) { described_class.new }

  it 'registers an offense for indented method definition ' do
    inspect_source(cop, <<-END.strip_margin('|'))
      |  def f
      |  end
    END
    expect(cop.messages).to eq(['Indentation of first line in file detected.'])
  end

  it 'accepts unindented method definition' do
    inspect_source(cop, <<-END.strip_indent)
      def f
      end
    END
    expect(cop.offenses).to be_empty
  end

  context 'for a file with byte order mark' do
    let(:bom) { "\xef\xbb\xbf" }

    it 'accepts unindented method call' do
      inspect_source(cop, bom + 'puts 1')
      expect(cop.offenses).to be_empty
    end

    it 'registers an offense for indented method call' do
      inspect_source(cop, bom + '  puts 1')
      expect(cop.offenses.size).to eq(1)
    end

    it 'registers an offense for indented method call after comment' do
      inspect_source(cop, [bom + '# comment',
                           '  puts 1'])
      expect(cop.offenses.size).to eq(1)
    end
  end

  it 'accepts empty file' do
    expect_no_offenses('')
  end

  it 'registers an offense for indented assignment disregarding comment' do
    inspect_source(cop, <<-END.strip_margin('|'))
      | # comment
      | x = 1
    END
    expect(cop.highlights).to eq(['x'])
  end

  it 'accepts unindented comment + assignment' do
    inspect_source(cop, <<-END.strip_indent)
      # comment
      x = 1
    END
    expect(cop.offenses).to be_empty
  end

  it 'auto-corrects indented method definition' do
    corrected = autocorrect_source(cop, <<-END.strip_margin('|'))
      |  def f
      |  end
    END
    expect(corrected).to eq <<-END.strip_indent
      def f
        end
    END
  end

  it 'auto-corrects indented assignment but not comment' do
    corrected = autocorrect_source(cop, <<-END.strip_margin('|'))
      |  # comment
      |  x = 1
    END
    expect(corrected).to eq <<-END.strip_indent
        # comment
      x = 1
    END
  end
end
