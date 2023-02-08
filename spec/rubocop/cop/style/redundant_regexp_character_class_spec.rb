# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::RedundantRegexpCharacterClass, :config do
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

  context 'with a character class containing a single character inside a group' do
    it 'registers an offense and corrects' do
      expect_offense(<<~RUBY)
        foo = /([a])/
                ^^^ Redundant single-element character class, `[a]` can be replaced with `a`.
      RUBY

      expect_correction(<<~RUBY)
        foo = /(a)/
      RUBY
    end
  end

  context 'with a character class containing a single character before `+` quantifier' do
    it 'registers an offense and corrects' do
      expect_offense(<<~RUBY)
        foo = /[a]+/
               ^^^ Redundant single-element character class, `[a]` can be replaced with `a`.
      RUBY

      expect_correction(<<~RUBY)
        foo = /a+/
      RUBY
    end
  end

  context 'with a character class containing a single character before `{n,m}` quantifier' do
    it 'registers an offense and corrects' do
      expect_offense(<<~RUBY)
        foo = /[a]{2,10}/
               ^^^ Redundant single-element character class, `[a]` can be replaced with `a`.
      RUBY

      expect_correction(<<~RUBY)
        foo = /a{2,10}/
      RUBY
    end
  end

  context 'with %r{} regexp' do
    context 'with a character class containing a single character' do
      it 'registers an offense and corrects' do
        expect_offense(<<~RUBY)
          foo = %r{[a]}
                   ^^^ Redundant single-element character class, `[a]` can be replaced with `a`.
        RUBY

        expect_correction(<<~RUBY)
          foo = %r{a}
        RUBY
      end
    end

    context 'with multiple character classes containing single characters' do
      it 'registers an offense and corrects' do
        expect_offense(<<~RUBY)
          foo = %r{[a]b[c]d}
                   ^^^ Redundant single-element character class, `[a]` can be replaced with `a`.
                       ^^^ Redundant single-element character class, `[c]` can be replaced with `c`.
        RUBY

        expect_correction(<<~RUBY)
          foo = %r{abcd}
        RUBY
      end
    end

    context 'with a character class containing a single character inside a group' do
      it 'registers an offense and corrects' do
        expect_offense(<<~RUBY)
          foo = %r{([a])}
                    ^^^ Redundant single-element character class, `[a]` can be replaced with `a`.
        RUBY

        expect_correction(<<~RUBY)
          foo = %r{(a)}
        RUBY
      end
    end

    context 'with a character class containing a single character before `+` quantifier' do
      it 'registers an offense and corrects' do
        expect_offense(<<~RUBY)
          foo = %r{[a]+}
                   ^^^ Redundant single-element character class, `[a]` can be replaced with `a`.
        RUBY

        expect_correction(<<~RUBY)
          foo = %r{a+}
        RUBY
      end
    end

    context 'with a character class containing a single character before `{n,m}` quantifier' do
      it 'registers an offense and corrects' do
        expect_offense(<<~RUBY)
          foo = %r{[a]{2,10}}
                   ^^^ Redundant single-element character class, `[a]` can be replaced with `a`.
        RUBY

        expect_correction(<<~RUBY)
          foo = %r{a{2,10}}
        RUBY
      end
    end
  end

  context 'with a character class containing a single range' do
    it 'does not register an offense' do
      expect_no_offenses('foo = /[a-z]/')
    end
  end

  context 'with a character class containing a posix bracket expression' do
    it 'does not register an offense' do
      expect_no_offenses('foo = /[[:alnum:]]/')
    end
  end

  context 'with a character class containing a negated posix bracket expression' do
    it 'does not register an offense' do
      expect_no_offenses('foo = /[[:^alnum:]]/')
    end
  end

  context 'with a character class containing set intersection' do
    it 'does not register an offense' do
      expect_no_offenses('foo = /[[:alnum:]&&a-d]/')
    end
  end

  context "with a regexp containing invalid \g escape" do
    it 'registers an offense and corrects' do
      # See https://ruby-doc.org/core-2.7.1/Regexp.html#class-Regexp-label-Subexpression+Calls
      # \g should be \g<name>
      expect_offense(<<~'RUBY')
        foo = /[a]\g/
               ^^^ Redundant single-element character class, `[a]` can be replaced with `a`.
      RUBY

      expect_correction(<<~'RUBY')
        foo = /a\g/
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

  context 'with a character class containing multiple unicode code-points' do
    it 'does not register an offense and corrects' do
      expect_no_offenses(<<~'RUBY')
        foo = /[\u{0061 0062}]/
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

  context 'with a character class containing an unescaped-#' do
    it 'registers an offense and corrects' do
      expect_offense(<<~'RUBY')
        foo = /[#]{0}/
               ^^^ Redundant single-element character class, `[#]` can be replaced with `\#`.
      RUBY

      expect_correction(<<~'RUBY')
        foo = /\#{0}/
      RUBY
    end
  end

  context 'with a character class containing an escaped-b' do
    # See https://github.com/rubocop/rubocop/issues/8193 for details - in short \b != [\b] - the
    # former matches a word boundary, the latter a backspace character.
    it 'does not register an offense' do
      expect_no_offenses('foo = /[\b]/')
    end
  end

  context 'with a character class containing an octal escape sequence that also works outside' do
    # See https://github.com/rubocop/rubocop/issues/11067 for details - in short "\0" != "0" - the
    # former means an Unicode code point `"\u0000"`, the latter a number character `"0"`.
    # Similarly "\032" means "\u001A".
    # "\0" and "\" followed by *more* than one digit also work outside sets because they are
    # not treated as backreferences by Onigmo.
    it 'registers an offense for escapes that would work outside the class' do
      expect_offense(<<~'RUBY')
        foo = /[\032]/
               ^^^^^^ Redundant single-element character class, `[\032]` can be replaced with `\032`.
      RUBY

      expect_correction(<<~'RUBY')
        foo = /\032/
      RUBY
    end
  end

  context 'with a character class containing an octal escape sequence that does not work outside' do
    # The octal escapes \1 to \7 only work inside a character class
    # because they would be a backreference outside it.
    it 'does not register an offense' do
      expect_no_offenses('foo = /[\1]/')
    end
  end

  context 'with a character class containing a character requiring escape outside' do
    # Not implemented for now, since we would have to escape on autocorrect, and the cop message
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

  context 'with a redundant character class after an interpolation' do
    it 'registers an offense and corrects' do
      expect_offense(<<~'RUBY')
        foo = /#{x}[a]/
                   ^^^ Redundant single-element character class, `[a]` can be replaced with `a`.
      RUBY

      expect_correction(<<~'RUBY')
        foo = /#{x}a/
      RUBY
    end
  end

  context 'with a multi-line interpolation' do
    it 'ignores offenses in the interpolated expression' do
      expect_no_offenses(<<~'RUBY')
        /#{Regexp.union(
          %w"( ) { } [ ] < > $ ! ^ ` ... + * ? ,"
        )}/o
      RUBY
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
        expect_offense(<<~RUBY)
          foo = /
            a # This comment shouldn't affect the position of the offense
            [b]
            ^^^ Redundant single-element character class, `[b]` can be replaced with `b`.
          /x
        RUBY

        expect_correction(<<~RUBY)
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
