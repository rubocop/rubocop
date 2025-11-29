# frozen_string_literal: true

# rubocop:disable Style/RedundantStringEscape
RSpec.describe RuboCop::Cop::Style::EscapedQuotes, :config do
  let(:cop_config) { { 'EnforcedStyle' => style } }
  let(:other_cops) do
    {
      'Style/PercentLiteralDelimiters' => {
        'Enabled' => true,
        'PreferredDelimiters' => {
          'default' => '()'
        }
      }
    }
  end

  shared_examples 'common' do
    it 'does not register an offense for a single quoted string without quotes' do
      expect_no_offenses(<<~RUBY)
        'foo'
      RUBY
    end

    it 'does not register an offense for a double quoted string without quotes' do
      expect_no_offenses(<<~RUBY)
        "foo"
      RUBY
    end

    it 'does not register an offense for a single quoted string that ends with an escaped slash' do
      expect_no_offenses(<<~RUBY)
        'foo\\\\'
      RUBY
    end

    it 'does not register an offense for a double quoted string that ends with an escaped slash' do
      expect_no_offenses(<<~RUBY)
        "foo\\\\"
      RUBY
    end

    it 'does not register an offense for a single quoted string that contains a slash that does not escape a quote' do
      expect_no_offenses(<<~RUBY)
        '\n'
      RUBY
    end

    it 'does not register an offense for a double quoted string that contains an escape sequence' do
      expect_no_offenses(<<~'RUBY')
        "\n"
      RUBY
    end

    it 'does not register an offense for a `%{}` literal' do
      expect_no_offenses(<<~RUBY)
        %{'foo'}
      RUBY
    end

    it 'does not register an offense for a `%()` literal containing an escape' do
      expect_no_offenses(<<~RUBY)
        %(foo\'bar)
      RUBY
    end

    it 'does not register an offense for a `%q()` literal' do
      expect_no_offenses(<<~RUBY)
        %q('foo')
      RUBY
    end

    it 'does not register an offense for a `%q()` literal containing an escape' do
      expect_no_offenses(<<~RUBY)
        %q(foo\'bar)
      RUBY
    end

    it 'does not register an offense for a `%q()` literal' do
      expect_no_offenses(<<~RUBY)
        %q('foo')
      RUBY
    end

    it 'does not register an offense for a `%q()` literal containing an escape' do
      expect_no_offenses(<<~RUBY)
        %q(foo\'bar)
      RUBY
    end

    it 'does not register an offense for a heredoc' do
      expect_no_offenses(<<~RUBY)
        <<~HEREDOC
          foo\'bar\"baz
        HEREDOC
      RUBY
    end

    it 'does not register an offense for a regexp literal' do
      expect_no_offenses(<<~RUBY)
        /foo'bar/
      RUBY
    end

    it 'does not register an offense for a regexp literal with escaping quotes' do
      expect_no_offenses(<<~RUBY)
        /foo\'bar/
      RUBY
    end

    it 'does not register an offense for __FILE__' do
      expect_no_offenses(<<~RUBY)
        __FILE__
      RUBY
    end

    context 'escaped double quote within interpolated string' do
      it 'registers an offense but does not correct' do
        expect_offense(<<~'RUBY')
          "#{foo}\"#{bar}"
          ^^^^^^^^^^^^^^^^ Avoid escaping quotes within quoted string literals.
        RUBY

        expect_no_corrections
      end
    end

    context 'when double quotes are necessary due to an escape sequence' do
      it 'registers an offense and corrects to a percent literal' do
        expect_offense(<<~'RUBY')
          "(x = \"\t\")"
          ^^^^^^^^^^^^^^ Avoid escaping quotes within quoted string literals.
        RUBY

        expect_correction(<<~'RUBY')
          %q((x = "\t"))
        RUBY
      end
    end

    context 'multiline string with interpolation and escaped double quote' do
      # There is no way to rewrite this without changing the string to not be
      # a multiline string, so ignore it.
      it 'does not register an offense' do
        expect_no_offenses(<<~'RUBY')
          "foo \"#{bar}\" " \
           "baz #{qux}"
        RUBY
      end
    end
  end

  context 'with `EnforcedStyle: prefer_quoted_strings`' do
    let(:style) { 'prefer_quoted_strings' }

    it_behaves_like 'common'

    context 'escaped single quote within single quoted string' do
      it 'registers an offense and corrects' do
        expect_offense(<<~'RUBY')
          'foo\'bar'
          ^^^^^^^^^^ Avoid escaping quotes within quoted string literals.
        RUBY

        expect_correction(<<~RUBY)
          "foo'bar"
        RUBY
      end
    end

    context 'escaped double quote within double quoted string' do
      it 'registers an offense and corrects' do
        expect_offense(<<~'RUBY')
          "foo\"bar"
          ^^^^^^^^^^ Avoid escaping quotes within quoted string literals.
        RUBY

        expect_correction(<<~RUBY)
          'foo"bar'
        RUBY
      end
    end

    context 'both quote types within single quoted string' do
      it 'registers an offense and corrects' do
        expect_offense(<<~'RUBY')
          'foo\'bar"baz'
          ^^^^^^^^^^^^^^ Avoid escaping quotes within quoted string literals.
        RUBY

        expect_correction(<<~RUBY)
          %q(foo'bar"baz)
        RUBY
      end
    end

    context 'within a multiline string' do
      it 'registers an offense and corrects an escaped single quote' do
        expect_offense(<<~'RUBY')
          "foo\n" \
            'bar\'baz'
            ^^^^^^^^^^ Avoid escaping quotes within quoted string literals.
        RUBY

        expect_correction(<<~'RUBY')
          "foo\n" \
            "bar'baz"
        RUBY
      end

      it 'registers an offense and corrects an escaped double quote' do
        expect_offense(<<~'RUBY')
          "foo\n" \
            "bar\"baz"
            ^^^^^^^^^^ Avoid escaping quotes within quoted string literals.
        RUBY

        expect_correction(<<~'RUBY')
          "foo\n" \
            'bar"baz'
        RUBY
      end

      it 'registers an offense but does not correct multiple quote types' do
        expect_offense(<<~'RUBY')
          "foo\n" \
            "bar\"baz'"
            ^^^^^^^^^^^ Avoid escaping quotes within quoted string literals.
        RUBY

        expect_no_corrections
      end
    end

    context 'with a single quoted string that contains an escaped single quote and also a slash' do
      it 'registers an offense and corrects' do
        expect_offense(<<~'RUBY')
          'foo\'bar\t'
          ^^^^^^^^^^^^ Avoid escaping quotes within quoted string literals.
        RUBY

        expect_correction(<<~'RUBY')
          "foo'bar\\t"
        RUBY
      end
    end
  end

  context 'with `EnforcedStyle: always_percent_literal`' do
    let(:style) { 'always_percent_literal' }

    it_behaves_like 'common'

    context 'escaped single quote within single quoted string' do
      it 'registers an offense and corrects' do
        expect_offense(<<~'RUBY')
          'foo\'bar'
          ^^^^^^^^^^ Avoid escaping quotes within quoted string literals.
        RUBY

        expect_correction(<<~RUBY)
          %q(foo'bar)
        RUBY
      end
    end

    context 'escaped double quote within double quoted string' do
      it 'registers an offense and corrects' do
        expect_offense(<<~'RUBY')
          "foo\"bar"
          ^^^^^^^^^^ Avoid escaping quotes within quoted string literals.
        RUBY

        expect_correction(<<~RUBY)
          %q(foo"bar)
        RUBY
      end
    end

    context 'both quote types within single quoted string' do
      it 'registers an offense and corrects' do
        expect_offense(<<~'RUBY')
          'foo\'bar"baz'
          ^^^^^^^^^^^^^^ Avoid escaping quotes within quoted string literals.
        RUBY

        expect_correction(<<~RUBY)
          %q(foo'bar"baz)
        RUBY
      end
    end

    context 'within a multiline string' do
      it 'registers an offense but does not correct an escaped single quote' do
        expect_offense(<<~'RUBY')
          "foo\n" \
            'bar\'baz'
            ^^^^^^^^^^ Avoid escaping quotes within quoted string literals.
        RUBY

        expect_no_corrections
      end

      it 'registers an offense but does not correct an escaped double quote' do
        expect_offense(<<~'RUBY')
          "foo\n" \
            "bar\"baz"
            ^^^^^^^^^^ Avoid escaping quotes within quoted string literals.
        RUBY

        expect_no_corrections
      end

      it 'registers an offense but does not correct multiple quote types' do
        expect_offense(<<~'RUBY')
          "foo\n" \
            "bar\"baz'"
            ^^^^^^^^^^^ Avoid escaping quotes within quoted string literals.
        RUBY

        expect_no_corrections
      end
    end

    context 'when `Style/PercentLiteralDelimiters` `PreferredDelimiters` is overridden' do
      let(:other_cops) do
        {
          'Style/PercentLiteralDelimiters' => {
            'Enabled' => true,
            'PreferredDelimiters' => {
              '%q' => '||'
            }
          }
        }
      end

      it 'registers an offense and corrects with the given delimiter' do
        expect_offense(<<~'RUBY')
          'foo\'bar'
          ^^^^^^^^^^ Avoid escaping quotes within quoted string literals.
        RUBY

        expect_correction(<<~RUBY)
          %q|foo'bar|
        RUBY
      end
    end

    context 'with a single quoted string that contains an escaped single quote and also a slash' do
      it 'registers an offense and corrects' do
        expect_offense(<<~'RUBY')
          'foo\'bar\t'
          ^^^^^^^^^^^^ Avoid escaping quotes within quoted string literals.
        RUBY

        expect_correction(<<~'RUBY')
          %q(foo'bar\\t)
        RUBY
      end
    end
  end
end
# rubocop:enable Style/RedundantStringEscape
