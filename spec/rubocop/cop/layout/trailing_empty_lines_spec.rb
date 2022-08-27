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
      expect_offense(<<~RUBY)
        x = 0

        ^{} 3 trailing blank lines detected.


      RUBY

      expect_correction("x = 0\n")
    end

    it 'registers an offense for multiple blank lines in an empty file' do
      expect_offense(<<~RUBY)


        ^{} 3 trailing blank lines detected.


      RUBY

      expect_correction("\n")
    end

    it 'registers an offense for no final newline after assignment' do
      expect_offense(<<~RUBY, chomp: true)
        x = 0
             ^{} Final newline missing.
      RUBY
    end

    it 'registers an offense for no final newline after block comment' do
      expect_offense(<<~RUBY, chomp: true)
        puts 'testing rubocop when final new line is missing
                                  after block comments'

        =begin
        first line
        second line
        third line
        =end
            ^{} Final newline missing.
      RUBY
    end

    it 'autocorrects even if some lines have space' do
      expect_offense(<<~RUBY)
        x = 0

        ^{} 4 trailing blank lines detected.
        #{trailing_whitespace}


      RUBY

      expect_correction("x = 0\n")
    end
  end

  context 'when EnforcedStyle is final_blank_line' do
    let(:cop_config) { { 'EnforcedStyle' => 'final_blank_line' } }

    it 'registers an offense for final newline' do
      expect_offense(<<~RUBY, chomp: true)
        x = 0\n
        ^{} Trailing blank line missing.
      RUBY
    end

    it 'registers an offense for multiple trailing blank lines' do
      expect_offense(<<~RUBY)
        x = 0

        ^{} 3 trailing blank lines instead of 1 detected.


      RUBY

      expect_correction(<<~RUBY)
        x = 0

      RUBY
    end

    it 'registers an offense for multiple blank lines in an empty file' do
      expect_offense(<<~RUBY)


        ^{} 3 trailing blank lines instead of 1 detected.


      RUBY

      expect_correction(<<~RUBY)


      RUBY
    end

    it 'registers an offense for no final newline' do
      expect_offense(<<~RUBY, chomp: true)
        x = 0
             ^{} Final newline missing.
      RUBY
    end

    it 'accepts final blank line' do
      expect_no_offenses("x = 0\n\n")
    end

    it 'autocorrects missing blank line' do
      expect_correction(<<~RUBY, source: "x = 0\n")
        x = 0

      RUBY
    end

    it 'autocorrects missing newline' do
      expect_correction(<<~RUBY, source: 'x = 0')
        x = 0

      RUBY
    end
  end
end
