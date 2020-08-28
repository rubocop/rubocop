# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::TrailingEmptyLines, :config do
  context 'when EnforcedStyle is final_newline' do
    let(:cop_config) { { 'EnforcedStyle' => 'final_newline' } }

    it 'accepts final newline' do
      expect_no_offenses("x = 0\n")
    end

    it 'accepts an empty file' do
      expect_no_offenses('')
    end

    it 'accepts final blank lines if they come after __END__' do
      expect_no_offenses(<<~RUBY)
        x = 0

        __END__

      RUBY
    end

    it 'accepts final blank lines if they come after __END__ in empty file' do
      expect_no_offenses(<<~RUBY)
        __END__


      RUBY
    end

    it 'registers an offense for multiple trailing blank lines' do
      offenses = inspect_source(<<~RUBY)
        x = 0



      RUBY
      expect(offenses.size).to eq(1)
      expect(offenses.first.message).to eq('3 trailing blank lines detected.')
    end

    it 'registers an offense for multiple blank lines in an empty file' do
      offenses = inspect_source(<<~RUBY)




      RUBY
      expect(offenses.size).to eq(1)
      expect(offenses.first.message).to eq('3 trailing blank lines detected.')
    end

    it 'registers an offense for no final newline after assignment' do
      offenses = inspect_source('x = 0')
      expect(offenses.first.message).to eq('Final newline missing.')
    end

    it 'registers an offense for no final newline after block comment' do
      offenses = inspect_source("puts 'testing rubocop when final new line is missing " \
                                "after block comments'\n\n=begin\nfirst line\nsecond " \
                                "line\nthird line\n=end")

      expect(offenses.first.message).to eq('Final newline missing.')
    end

    it 'auto-corrects unwanted blank lines' do
      new_source = autocorrect_source(<<~RUBY)
        x = 0




      RUBY
      expect(new_source).to eq(<<~RUBY)
        x = 0
      RUBY
    end

    it 'auto-corrects unwanted blank lines in an empty file' do
      new_source = autocorrect_source(<<~RUBY)





      RUBY
      expect(new_source).to eq("\n")
    end

    it 'auto-corrects even if some lines have space' do
      new_source = autocorrect_source(['x = 0', '', '  ', '', ''].join("\n"))
      expect(new_source).to eq(['x = 0', ''].join("\n"))
    end
  end

  context 'when EnforcedStyle is final_blank_line' do
    let(:cop_config) { { 'EnforcedStyle' => 'final_blank_line' } }

    it 'registers an offense for final newline' do
      offenses = inspect_source(<<~RUBY)
        x = 0
      RUBY

      expect(offenses.first.message).to eq('Trailing blank line missing.')
    end

    it 'registers an offense for multiple trailing blank lines' do
      offenses = inspect_source(<<~RUBY)
        x = 0



      RUBY
      expect(offenses.size).to eq(1)
      expect(offenses.first.message).to eq('3 trailing blank lines instead of 1 detected.')
    end

    it 'registers an offense for multiple blank lines in an empty file' do
      offenses = inspect_source(<<~RUBY)




      RUBY
      expect(offenses.size).to eq(1)
      expect(offenses.first.message).to eq('3 trailing blank lines instead of 1 detected.')
    end

    it 'registers an offense for no final newline' do
      offenses = inspect_source('x = 0')
      expect(offenses.first.message).to eq('Final newline missing.')
    end

    it 'accepts final blank line' do
      expect_no_offenses("x = 0\n\n")
    end

    it 'auto-corrects unwanted blank lines' do
      new_source = autocorrect_source(<<~RUBY)
        x = 0




      RUBY

      expect(new_source).to eq(<<~RUBY)
        x = 0

      RUBY
    end

    it 'auto-corrects unwanted blank lines in an empty file' do
      new_source = autocorrect_source(<<~RUBY)




      RUBY
      expect(new_source).to eq(<<-RUBY)


      RUBY
    end

    it 'auto-corrects missing blank line' do
      new_source = autocorrect_source(<<~RUBY)
        x = 0
      RUBY
      expect(new_source).to eq(<<~RUBY)
        x = 0

      RUBY
    end

    it 'auto-corrects missing newline' do
      new_source = autocorrect_source('x = 0')
      expect(new_source).to eq(<<~RUBY)
        x = 0

      RUBY
    end
  end
end
