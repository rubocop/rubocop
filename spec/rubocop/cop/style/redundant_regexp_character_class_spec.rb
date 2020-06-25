# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::RedundantRegexpCharacterClass do
  subject(:cop) { described_class.new }

  context 'with a character class containing a single character' do
    it 'registers an offense and corrects' do
      expect_offense(<<~RUBY)
        foo = /[a]/
               ^^^ Redundant single-element character class, `[a]` can be replaced with `a`.
      RUBY

      expect_correction(<<~RUBY)
        foo = /a/
      RUBY
    end
  end

  context 'with multiple character classes containing single characters' do
    it 'registers an offense and corrects' do
      expect_offense(<<~RUBY)
        foo = /[a]b[c]d/
               ^^^ Redundant single-element character class, `[a]` can be replaced with `a`.
                   ^^^ Redundant single-element character class, `[c]` can be replaced with `c`.
      RUBY

      expect_correction(<<~RUBY)
        foo = /abcd/
      RUBY
    end
  end

  context 'with a character class containing an escaped ]' do
    it 'registers an offense and corrects' do
      expect_offense(<<~'RUBY')
        foo = /[\]]/
               ^^^^ Redundant single-element character class, `[\]]` can be replaced with `\]`.
      RUBY

      expect_correction(<<~'RUBY')
        foo = /\]/
      RUBY
    end
  end

  context 'with a character class containing an escaped [' do
    it 'registers an offense and corrects' do
      expect_offense(<<~'RUBY')
        foo = /[\[]/
               ^^^^ Redundant single-element character class, `[\[]` can be replaced with `\[`.
      RUBY

      expect_correction(<<~'RUBY')
        foo = /\[/
      RUBY
    end
  end

  context 'with a character class containing a space meta-character' do
    it 'registers an offense and corrects' do
      expect_offense(<<~'RUBY')
        foo = /[\s]/
               ^^^^ Redundant single-element character class, `[\s]` can be replaced with `\s`.
      RUBY

      expect_correction(<<~'RUBY')
        foo = /\s/
      RUBY
    end
  end

  context 'with a character class containing a negated-space meta-character' do
    it 'registers an offense and corrects' do
      expect_offense(<<~'RUBY')
        foo = /[\S]/
               ^^^^ Redundant single-element character class, `[\S]` can be replaced with `\S`.
      RUBY

      expect_correction(<<~'RUBY')
        foo = /\S/
      RUBY
    end
  end

  context 'with a character class containing a single unicode code-point' do
    it 'registers an offense and corrects' do
      expect_offense(<<~'RUBY')
        foo = /[\u{06F2}]/
               ^^^^^^^^^^ Redundant single-element character class, `[\u{06F2}]` can be replaced with `\u{06F2}`.
      RUBY

      expect_correction(<<~'RUBY')
        foo = /\u{06F2}/
      RUBY
    end
  end

  context 'with a character class containing a single unicode character property' do
    it 'registers an offense and corrects' do
      expect_offense(<<~'RUBY')
        foo = /[\p{Digit}]/
               ^^^^^^^^^^^ Redundant single-element character class, `[\p{Digit}]` can be replaced with `\p{Digit}`.
      RUBY

      expect_correction(<<~'RUBY')
        foo = /\p{Digit}/
      RUBY
    end
  end

  context 'with a character class containing a single negated unicode character property' do
    it 'registers an offense and corrects' do
      expect_offense(<<~'RUBY')
        foo = /[\P{Digit}]/
               ^^^^^^^^^^^ Redundant single-element character class, `[\P{Digit}]` can be replaced with `\P{Digit}`.
      RUBY

      expect_correction(<<~'RUBY')
        foo = /\P{Digit}/
      RUBY
    end
  end

  context 'with a character class containing an escaped-#' do
    it 'registers an offense and corrects' do
      expect_offense(<<~'RUBY')
        foo = /[\#]/
               ^^^^ Redundant single-element character class, `[\#]` can be replaced with `\#`.
      RUBY

      expect_correction(<<~'RUBY')
        foo = /\#/
      RUBY
    end
  end

  context 'with a character class containing an escaped-b' do
    # See https://github.com/rubocop-hq/rubocop/issues/8193 for details - in short \b != [\b] - the
    # former matches a word boundary, the latter a backspace character.
    it 'does not register an offense' do
      expect_no_offenses('foo = /[\b]/')
    end
  end

  context 'with a character class containing a character requiring escape outside' do
    # Not implemented for now, since we would have to escape on auto-correct, and the cop message
    # would need to be dynamic to not be misleading.
    it 'does not register an offense' do
      expect_no_offenses('foo = /[+]/')
    end
  end

  context 'with a character class containing escaped character requiring escape outside' do
    it 'registers an offense and corrects' do
      expect_offense(<<~'RUBY')
        foo = /[\+]/
               ^^^^ Redundant single-element character class, `[\+]` can be replaced with `\+`.
      RUBY

      expect_correction(<<~'RUBY')
        foo = /\+/
      RUBY
    end
  end

  context 'with an interpolated unnecessary-character-class regexp' do
    it 'registers an offense and corrects' do
      expect_offense(<<~'RUBY')
        foo = /a#{/[b]/}c/
                   ^^^ Redundant single-element character class, `[b]` can be replaced with `b`.
      RUBY

      expect_correction(<<~'RUBY')
        foo = /a#{/b/}c/
      RUBY
    end
  end

  context 'with a character class with first element an escaped ]' do
    it 'does not register an offense' do
      expect_no_offenses('foo = /[\])]/')
    end
  end

  context 'with a negated character class with a single element' do
    it 'does not register an offense' do
      expect_no_offenses('foo = /[^x]/')
    end
  end

  context 'with a character class containing an interpolation' do
    it 'does not register an offense' do
      expect_no_offenses('foo = /[#{foo}]/')
    end
  end

  context 'with consecutive escaped square brackets' do
    it 'does not register an offense' do
      expect_no_offenses('foo = /\[\]/')
    end
  end

  context 'with consecutive escaped square brackets inside a character class' do
    it 'does not register an offense' do
      expect_no_offenses('foo = /[\[\]]/')
    end
  end

  context 'with escaped square brackets surrounding a single character' do
    it 'does not register an offense' do
      expect_no_offenses('foo = /\[x\]/')
    end
  end

  context 'with a character class containing two characters' do
    it 'does not register an offense' do
      expect_no_offenses('foo = /[ab]/')
    end
  end

  context 'with an array index inside an interpolation' do
    it 'does not register an offense' do
      expect_no_offenses('foo = /a#{b[0]}c/')
    end
  end

  context 'with a character class containing a space' do
    context 'when not using free-spaced mode' do
      it 'registers an offense and corrects' do
        expect_offense(<<~RUBY)
          foo = /[ ]/
                 ^^^ Redundant single-element character class, `[ ]` can be replaced with ` `.
        RUBY

        expect_correction(<<~RUBY)
          foo = / /
        RUBY
      end
    end

    context 'with an unnecessary-character-class after a comment' do
      it 'registers an offense and corrects' do
        expect_offense(<<~'RUBY')
          foo = /
            a # This comment shouldn't affect the position of the offense
            [b]
            ^^^ Redundant single-element character class, `[b]` can be replaced with `b`.
          /x
        RUBY

        expect_correction(<<~'RUBY')
          foo = /
            a # This comment shouldn't affect the position of the offense
            b
          /x
        RUBY
      end
    end

    context 'when using free-spaced mode' do
      context 'with a commented single-element character class' do
        it 'does not register an offense' do
          expect_no_offenses('foo = /foo # [a]/x')
        end
      end

      context 'with a single space character class' do
        it 'does not register an offense with only /x' do
          expect_no_offenses('foo = /[ ]/x')
        end

        it 'does not register an offense with /ix' do
          expect_no_offenses('foo = /[ ]/ix')
        end

        it 'does not register an offense with /iux' do
          expect_no_offenses('foo = /[ ]/iux')
        end
      end
    end
  end
end
