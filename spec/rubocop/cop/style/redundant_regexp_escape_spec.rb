# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::RedundantRegexpEscape, :config do
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

    context 'with a line continuation' do
      it 'does not register an offense' do
        expect_no_offenses("foo = /a\\\nb/")
      end
    end

    context 'with a line continuation within a character class' do
      it 'does not register an offense' do
        expect_no_offenses("foo = /[a\\\nb]/")
      end
    end

    [
      ('a'..'z').to_a - %w[c g k n p u x],
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

    context "with an invalid \g escape" do
      it 'does not register an offense' do
        # See https://ruby-doc.org/core-2.7.1/Regexp.html#class-Regexp-label-Subexpression+Calls
        # \g should be \g<name>
        expect_no_offenses('foo = /\g/')
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

    context "with an escaped '+' inside a character class inside a group" do
      it 'registers an offense and corrects' do
        expect_offense(<<~'RUBY')
          foo = /([\+])/
                   ^^ Redundant escape inside regexp literal
        RUBY

        expect_correction(<<~RUBY)
          foo = /([+])/
        RUBY
      end
    end

    context 'with an escaped . inside a character class beginning with :' do
      it 'registers an offense and corrects' do
        expect_offense(<<~'RUBY')
          foo = /[:\.]/
                   ^^ Redundant escape inside regexp literal
        RUBY

        expect_correction(<<~RUBY)
          foo = /[:.]/
        RUBY
      end
    end

    context "with an escaped '-' character being the last character inside a character class" do
      context 'with a regexp %r{...} literal' do
        it 'registers an offense and corrects' do
          expect_offense(<<~'RUBY')
            foo = %r{[0-9\-]}
                         ^^ Redundant escape inside regexp literal
          RUBY

          expect_correction(<<~RUBY)
            foo = %r{[0-9-]}
          RUBY
        end
      end

      context 'with a regexp /.../ literal' do
        it 'registers an offense and corrects' do
          expect_offense(<<~'RUBY')
            foo = /[0-9\-]/
                       ^^ Redundant escape inside regexp literal
          RUBY

          expect_correction(<<~RUBY)
            foo = /[0-9-]/
          RUBY
        end
      end

      context "with an escaped opening square bracket before an escaped '-' character" do
        it 'registers an offense and corrects' do
          expect_offense(<<~'RUBY')
            foo = /[\[\-]/
                      ^^ Redundant escape inside regexp literal
          RUBY

          expect_correction(<<~'RUBY')
            foo = /[\[-]/
          RUBY
        end
      end
    end

    context "with an escaped '-' character being the first character inside a character class" do
      context 'with a regexp %r{...} literal' do
        it 'registers an offense and corrects' do
          expect_offense(<<~'RUBY')
            foo = %r{[\-0-9]}
                      ^^ Redundant escape inside regexp literal
          RUBY

          expect_correction(<<~RUBY)
            foo = %r{[-0-9]}
          RUBY
        end
      end

      context 'with a regexp /.../ literal' do
        it 'registers an offense and corrects' do
          expect_offense(<<~'RUBY')
            foo = /[\-0-9]/
                    ^^ Redundant escape inside regexp literal
          RUBY

          expect_correction(<<~RUBY)
            foo = /[-0-9]/
          RUBY
        end
      end
    end

    context "with an escaped '-' character being neither first nor last inside a character class" do
      it 'does not register an offense' do
        expect_no_offenses('foo = %r{[\w\-\#]}')
        expect_no_offenses('foo = /[\w\-\#]/')
        expect_no_offenses('foo = /[\[\-\]]/')
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

    context 'with a nested character class then allowed escape' do
      it 'does not register an offense' do
        expect_no_offenses('foo = /[a-w&&[^c-g]\-1-9]/')
      end
    end

    context 'with a nested character class containing redundant escape' do
      it 'registers an offense and corrects' do
        expect_offense(<<~'RUBY')
          foo = /[[:punct:]&&[^\.]]/
                               ^^ Redundant escape inside regexp literal
        RUBY

        expect_correction(<<~RUBY)
          foo = /[[:punct:]&&[^.]]/
        RUBY
      end
    end

    context 'with a POSIX character class then allowed escape inside a character class' do
      it 'does not register an offense' do
        expect_no_offenses('foo = /[[:alnum:]\-_]+/')
      end
    end

    context 'with a POSIX character class then disallowed escape inside a character class' do
      it 'registers an offense and corrects' do
        expect_offense(<<~'RUBY')
          foo = /[[:alnum:]\.]/
                           ^^ Redundant escape inside regexp literal
        RUBY

        expect_correction(<<~RUBY)
          foo = /[[:alnum:].]/
        RUBY
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

        expect_correction(<<~RUBY)
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

      # Avoid an empty character class
      next if char == "\n"

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
        it 'registers an offense and corrects' do
          expect_offense(<<~RUBY)
            foo = /a[\\#{char}]b/
                     ^^ Redundant escape inside regexp literal
          RUBY

          expect_correction(<<~RUBY)
            foo = /a[#{char}]b/
          RUBY
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

    context 'with an escaped { or } outside a character class' do
      it 'does not register an offense' do
        expect_no_offenses('foo = %r{\{\}}')
      end
    end

    context 'with an escaped { or } inside a character class' do
      it 'does not register an offense' do
        expect_no_offenses('foo = %r{[\{\}]}')
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

  [
    '!',
    '~',
    '@',
    '_',
    '^',
    '<>',
    '()'
  ].each do |delims|
    l, r = delims.chars
    r = l if r.nil?
    escaped_delims = "\\#{l}\\#{r}"

    context "with a single-line %r#{l}#{r} regexp" do
      context 'without escapes' do
        it 'does not register an offense' do
          expect_no_offenses("foo = %r#{l}a#{r}")
        end
      end

      context 'with escaped delimiters and regexp options' do
        it 'does not register an offense' do
          expect_no_offenses("foo = %r#{l}#{escaped_delims}#{r}i")
        end
      end

      context 'with escaped delimiters outside a character-class' do
        it 'does not register an offense' do
          expect_no_offenses("foo = %r#{l}#{escaped_delims}#{r}")
        end
      end

      context 'with escaped delimiters inside a character-class' do
        it 'does not register an offense' do
          expect_no_offenses("foo = %r#{l}a[#{escaped_delims}]b#{r}")
        end
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

    context 'with a # inside a character class' do
      it 'does not register an offense' do
        # See https://github.com/rubocop/rubocop/issues/8805 - the # inside the character class
        # must not be treated as starting a comment (which makes the following \. redundant)
        expect_no_offenses(<<~'RUBY')
          regexp = %r{
            \A[a-z#]            # letters or #
            \.[a-z]\z           # dot + letters
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

  context 'with multibyte characters' do
    it 'removes the escape character at the right position' do
      # The indicator should take character widths into account in the
      # future.
      expect_offense(<<~'RUBY')
        x = s[/[一二三四\.]+/]
                    ^^ Redundant escape inside regexp literal
        p x
      RUBY

      expect_correction(<<~RUBY)
        x = s[/[一二三四.]+/]
        p x
      RUBY
    end
  end
end
