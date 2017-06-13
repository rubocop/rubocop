# frozen_string_literal: true

describe RuboCop::Cop::Layout::TrailingBlankLines, :config do
  subject(:cop) { described_class.new(config) }

  context 'when EnforcedStyle is final_newline' do
    let(:cop_config) { { 'EnforcedStyle' => 'final_newline' } }

    it 'accepts final newline' do
      expect_no_offenses("x = 0\n")
    end

    it 'accepts an empty file' do
      expect_no_offenses('')
    end

    it 'accepts final blank lines if they come after __END__' do
      expect_no_offenses(<<-RUBY.strip_indent)
        x = 0

        __END__

      RUBY
    end

    it 'accepts final blank lines if they come after __END__ in empty file' do
      expect_no_offenses(<<-RUBY.strip_indent)
        __END__


      RUBY
    end

    it 'registers an offense for multiple trailing blank lines' do
      inspect_source(['x = 0', '', '', '', ''])
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages).to eq(['3 trailing blank lines detected.'])
    end

    it 'registers an offense for multiple blank lines in an empty file' do
      inspect_source(['', '', '', '', ''])
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages).to eq(['3 trailing blank lines detected.'])
    end

    it 'registers an offense for no final newline after assignment' do
      inspect_source('x = 0')
      expect(cop.messages).to eq(['Final newline missing.'])
    end

    it 'registers an offense for no final newline after block comment' do
      inspect_source("puts 'testing rubocop when final new line is missing " \
                     "after block comments'\n\n=begin\nfirst line\nsecond " \
                     "line\nthird line\n=end")

      expect(cop.messages).to eq(['Final newline missing.'])
    end

    it 'auto-corrects unwanted blank lines' do
      new_source = autocorrect_source(cop, ['x = 0', '', '', '', ''])
      expect(new_source).to eq(['x = 0', ''].join("\n"))
    end

    it 'auto-corrects unwanted blank lines in an empty file' do
      new_source = autocorrect_source(cop, ['', '', '', '', ''])
      expect(new_source).to eq(['', ''].join("\n"))
    end

    it 'auto-corrects even if some lines have space' do
      new_source = autocorrect_source(cop, ['x = 0', '', '  ', '', ''])
      expect(new_source).to eq(['x = 0', ''].join("\n"))
    end
  end

  context 'when EnforcedStyle is final_blank_line' do
    let(:cop_config) { { 'EnforcedStyle' => 'final_blank_line' } }

    it 'registers an offense for final newline' do
      inspect_source(['x = 0', ''])
      expect(cop.messages).to eq(['Trailing blank line missing.'])
    end

    it 'registers an offense for multiple trailing blank lines' do
      inspect_source(['x = 0', '', '', '', ''])
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(['3 trailing blank lines instead of 1 detected.'])
    end

    it 'registers an offense for multiple blank lines in an empty file' do
      inspect_source(['', '', '', '', ''])
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(['3 trailing blank lines instead of 1 detected.'])
    end

    it 'registers an offense for no final newline' do
      inspect_source('x = 0')
      expect(cop.messages).to eq(['Final newline missing.'])
    end

    it 'accepts final blank line' do
      expect_no_offenses("x = 0\n\n")
    end

    it 'auto-corrects unwanted blank lines' do
      new_source = autocorrect_source(cop, ['x = 0', '', '', '', ''])
      expect(new_source).to eq(['x = 0', '', ''].join("\n"))
    end

    it 'auto-corrects unwanted blank lines in an empty file' do
      new_source = autocorrect_source(cop, ['', '', '', '', ''])
      expect(new_source).to eq(['', '', ''].join("\n"))
    end

    it 'auto-corrects missing blank line' do
      new_source = autocorrect_source(cop, ['x = 0', ''])
      expect(new_source).to eq(['x = 0', '', ''].join("\n"))
    end

    it 'auto-corrects missing newline' do
      new_source = autocorrect_source(cop, ['x = 0'])
      expect(new_source).to eq(['x = 0', '', ''].join("\n"))
    end
  end
end
