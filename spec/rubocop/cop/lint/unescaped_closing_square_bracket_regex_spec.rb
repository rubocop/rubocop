# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::UnescapedClosingSquareBracketRegex, :config do
  context 'when an unescaped closing square bracket is used in a regular expression' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        regex = /abc]123/
                ^^^^^^^^^ Regular expression has ']' without escape
      RUBY

      expect_correction(<<~'RUBY')
        regex = /abc\]123/
      RUBY
    end
  end

  context 'when multiple unescaped closing square brackets are used in a regular expression' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        regex = /ab]c12]3/
                ^^^^^^^^^^ Regular expression has ']' without escape
      RUBY

      expect_correction(<<~'RUBY')
        regex = /ab\]c12\]3/
      RUBY
    end
  end

  context 'when an unescaped closing square bracket is used inside a character class' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        regex = /ab[c]12]3/
                ^^^^^^^^^^^ Regular expression has ']' without escape
      RUBY

      expect_correction(<<~'RUBY')
        regex = /ab[c]12\]3/
      RUBY
    end
  end

  context 'when an unescaped closing square bracket is used outside a character class' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        regex = /ab[c]]123/
                ^^^^^^^^^^^ Regular expression has ']' without escape
      RUBY

      expect_correction(<<~'RUBY')
        regex = /ab[c]\]123/
      RUBY
    end
  end

  context 'when an unescaped and escaped closing square bracket is used in a regular expression' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        regex = /abc\\]]123/
                ^^^^^^^^^^^ Regular expression has ']' without escape
      RUBY

      expect_correction(<<~'RUBY')
        regex = /abc\]\]123/
      RUBY
    end
  end

  context 'when an unescaped closing square bracket is used outside a regular expression' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        def some_method
          string = 'abc]123'
          puts string
        end
      RUBY
    end
  end

  context 'when an escaped closing square bracket is used in a regular expression' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        def some_method
          regex = /abc\\]123/
          puts regex
        end
      RUBY
    end
  end

  context 'when a character class is used in a regular expression' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        def some_method
          regex = /a[bc]123/
          puts regex
        end
      RUBY
    end
  end
end
