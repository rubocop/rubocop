# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::RedundantRegexpEscape do
  subject(:cop) { described_class.new }

  context 'with a single-line `//` regexp' do
    context 'without escapes' do
      it 'does not register an offense' do
        expect_no_offenses('foo = /a/')
      end
    end

    context 'with escaped slashes' do
      it 'does not register an offense' do
        expect_no_offenses('foo = /\/a\//')
      end
    end

    [
      ('a'..'z').to_a - %w[c n p u x],
      ('A'..'Z').to_a - %w[C M P],
      %w[n101 x41 u0041 u{0041} cc C-c p{alpha} P{alpha}]
    ].flatten.each do |escape|
      context "with an escaped '#{escape}' outside a character class" do
        it 'does not register an offense' do
          expect_no_offenses("foo = /\\#{escape}/")
        end
      end

      context "with an escaped '#{escape}' inside a character class" do
        it 'does not register an offense' do
          expect_no_offenses("foo = /[\\#{escape}]/")
        end
      end
    end

    context "with an escaped 'M-a' outside a character class" do
      it 'does not register an offense' do
        expect_no_offenses('foo = /\\M-a/n')
      end
    end

    context "with an escaped 'M-a' inside a character class" do
      it 'does not register an offense' do
        expect_no_offenses('foo = /[\\M-a]/n')
      end
    end

    described_class::ALLOWED_OUTSIDE_CHAR_CLASS_METACHAR_ESCAPES.each do |char|
      context "with an escaped '#{char}' outside a character class" do
        it 'does not register an offense' do
          expect_no_offenses("foo = /\\#{char}/")
        end
      end

      context "with an escaped '#{char}' inside a character class" do
        it 'registers an offense and corrects' do
          expect_offense(<<~RUBY)
            foo = /[\\#{char}]/
                    ^^ Redundant escape inside regexp literal
          RUBY

          expect_correction(<<~RUBY)
            foo = /[#{char}]/
          RUBY
        end
      end
    end

    context 'with an escaped character class and following escaped char' do
      it 'does not register an offense' do
        expect_no_offenses('foo = /\[\+/')
      end
    end

    context 'with a character class and following escaped char' do
      it 'does not register an offense' do
        expect_no_offenses('foo = /[a]\+/')
      end
    end

    context 'with a POSIX character class inside a character class' do
      it 'does not register an offense' do
        expect_no_offenses('foo = /[[:alnum:]\-_]+/')
      end
    end

    context 'with a backreference' do
      it 'does not register an offense' do
        expect_no_offenses('foo = /([a-z])\s*\1/')
      end
    end

    context 'with an interpolated unnecessary-escape regexp' do
      it 'registers an offense and corrects' do
        expect_offense(<<~'RUBY')
          foo = /a#{/\-/}c/
                     ^^ Redundant escape inside regexp literal
        RUBY

        expect_correction(<<~'RUBY')
          foo = /a#{/-/}c/
        RUBY
      end
    end

    context 'with an escape inside an interpolated string' do
      it 'does not register an offense' do
        expect_no_offenses('foo = /#{"\""}/')
      end
    end

    context 'with an escaped interpolation outside a character class' do
      it 'does not register an offense' do
        expect_no_offenses('foo = /\#\{[a-z_]+\}/')
      end
    end

    context 'with an escaped interpolation inside a character class' do
      it 'does not register an offense' do
        expect_no_offenses('foo = /[\#{}]/')
      end
    end

    context 'with an uppercase metacharacter inside a character class' do
      it 'does not register an offense' do
        expect_no_offenses('foo = /[\H]/')
      end
    end

    context 'with an uppercase metacharacter outside a character class' do
      it 'does not register an offense' do
        expect_no_offenses('foo = /\H/')
      end
    end

    context 'with a free-spaced mode regex' do
      context 'with a commented [ and ]' do
        it 'does not register an offense' do
          expect_no_offenses(<<~'RUBY')
            r = /
              foo # shouldn't start a char class: [
              \+  # escape is only redundant inside a char class, so not redundant here
              bar # shouldn't end a char class: ]
            /x
          RUBY
        end
      end

      context 'with a commented redundant escape' do
        it 'does not register an offense' do
          expect_no_offenses(<<~'RUBY')
            r = /
              foo # redundant unless commented: \-
            /x
          RUBY
        end
      end

      context 'with a commented redundant escape on a single line' do
        it 'does not register an offense' do
          expect_no_offenses('r = /foo # redundant unless commented: \-/x')
        end
      end

      context 'with redundant escape preceded by an escaped comment' do
        it 'registers offenses and corrects' do
          expect_offense(<<~'RUBY')
            r = /
              foo \# \-
                     ^^ Redundant escape inside regexp literal
            /x
          RUBY

          expect_correction(<<~'RUBY')
            r = /
              foo \# -
            /x
          RUBY
        end
      end
    end

    context 'with regexp options and a redundant escape' do
      it 'registers offenses and corrects' do
        expect_offense(<<~'RUBY')
          r = /\-/i
               ^^ Redundant escape inside regexp literal
        RUBY

        expect_correction(<<~'RUBY')
          r = /-/i
        RUBY
      end
    end

    context 'with an interpolation followed by redundant escapes' do
      it 'registers offenses and corrects' do
        expect_offense(<<~'RUBY')
          METHOD_NAME  = /\#?#{IDENTIFIER}[\!\?]?\(?/.freeze
                                           ^^ Redundant escape inside regexp literal
                                             ^^ Redundant escape inside regexp literal
        RUBY

        expect_correction(<<~'RUBY')
          METHOD_NAME  = /\#?#{IDENTIFIER}[!?]?\(?/.freeze
        RUBY
      end
    end

    context 'with multiple escaped metachars inside a character class' do
      it 'registers offenses and corrects' do
        expect_offense(<<~'RUBY')
          foo = /[\s\(\|\{\[;,\*\=]/
                    ^^ Redundant escape inside regexp literal
                      ^^ Redundant escape inside regexp literal
                        ^^ Redundant escape inside regexp literal
                              ^^ Redundant escape inside regexp literal
                                ^^ Redundant escape inside regexp literal
        RUBY

        expect_correction(<<~'RUBY')
          foo = /[\s(|{\[;,*=]/
        RUBY
      end
    end

    described_class::ALLOWED_ALWAYS_ESCAPES.each do |char|
      context "with an escaped '#{char}' outside a character class" do
        it 'does not register an offense' do
          expect_no_offenses("foo = /\\#{char}/")
        end
      end

      context "with an escaped '#{char}' inside a character class" do
        it 'does not register an offense' do
          expect_no_offenses("foo = /[\\#{char}]/")
        end
      end
    end

    described_class::ALLOWED_WITHIN_CHAR_CLASS_METACHAR_ESCAPES.each do |char|
      context "with an escaped '#{char}' outside a character class" do
        it 'registers an offense and corrects' do
          expect_offense(<<~RUBY)
            foo = /a\\#{char}b/
                    ^^ Redundant escape inside regexp literal
          RUBY

          expect_correction(<<~RUBY)
            foo = /a#{char}b/
          RUBY
        end
      end

      context "with an escaped '#{char}' inside a character class" do
        it 'does not register an offense' do
          expect_no_offenses("foo = /a[\\#{char}]b/")
        end
      end
    end
  end

  context 'with a single-line %r{} regexp' do
    context 'without escapes' do
      it 'does not register an offense' do
        expect_no_offenses('foo = %r{a}')
      end
    end

    context 'with redundantly-escaped slashes' do
      it 'registers an offense and corrects' do
        expect_offense(<<~'RUBY')
          foo = %r{\/a\/}
                   ^^ Redundant escape inside regexp literal
                      ^^ Redundant escape inside regexp literal
        RUBY

        expect_correction(<<~RUBY)
          foo = %r{/a/}
        RUBY
      end
    end
  end

  context 'with a single-line %r// regexp' do
    context 'without escapes' do
      it 'does not register an offense' do
        expect_no_offenses('foo = %r/a/')
      end
    end

    context 'with escaped slashes' do
      it 'does not register an offense' do
        expect_no_offenses('foo = %r/\/a\//')
      end
    end
  end

  context 'with a multi-line %r{} regexp' do
    context 'without escapes' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          foo = %r{
            a
            b
          }x
        RUBY
      end
    end

    context 'with redundantly-escaped slashes' do
      it 'registers an offense and corrects' do
        expect_offense(<<~'RUBY')
          foo = %r{
            \/a
            ^^ Redundant escape inside regexp literal
            b\/
             ^^ Redundant escape inside regexp literal
          }x
        RUBY

        expect_correction(<<~RUBY)
          foo = %r{
            /a
            b/
          }x
        RUBY
      end
    end

    context 'with a redundant escape after a line with comment' do
      it 'registers an offense and corrects' do
        expect_offense(<<~'RUBY')
          foo = %r{
            foo # this should not affect the position of the escape below
            \-
            ^^ Redundant escape inside regexp literal
          }x
        RUBY

        expect_correction(<<~RUBY)
          foo = %r{
            foo # this should not affect the position of the escape below
            -
          }x
        RUBY
      end
    end
  end

  context 'with a multi-line %r// regexp' do
    context 'without escapes' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          foo = %r/
            a
            b
          /x
        RUBY
      end
    end

    context 'with escaped slashes' do
      it 'does not register an offense' do
        expect_no_offenses(<<~'RUBY')
          foo = %r/
            \/a
            b\/
          /x
        RUBY
      end
    end
  end
end
