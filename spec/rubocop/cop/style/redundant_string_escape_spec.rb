# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::RedundantStringEscape, :config do
  def wrap(contents)
    [l, contents, r].join
  end

  RSpec.shared_examples 'common no offenses' do |l, r|
    let(:l) { l }
    let(:r) { r }

    it 'does not register an offense without escapes' do
      expect_no_offenses(wrap('a'))
    end

    it 'does not register an offense for an escaped backslash' do
      expect_no_offenses(wrap('\\\\foo\\\\'))
    end

    it 'does not register an offense for an escaped gvar interpolation' do
      expect_no_offenses(wrap('\#$foo'))
    end

    it 'does not register an offense for a $-escaped gvar interpolation' do
      expect_no_offenses(wrap('#\$foo'))
    end

    it 'does not register an offense for an escaped ivar interpolation' do
      expect_no_offenses(wrap('\#@foo'))
    end

    it 'does not register an offense for a @-escaped ivar interpolation' do
      expect_no_offenses(wrap('#\@foo'))
    end

    it 'does not register an offense for an escaped cvar interpolation' do
      expect_no_offenses(wrap('\#@@foo'))
    end

    it 'does not register an offense for a @-escaped cvar interpolation' do
      expect_no_offenses(wrap('#\@@foo'))
    end

    it 'does not register an offense for an escaped interpolation' do
      expect_no_offenses(wrap('\#{my_var}'))
    end

    it 'does not register an offense for a bracket-escaped interpolation' do
      expect_no_offenses(wrap('#\{my_var}'))
    end

    it 'does not register an offense for an escaped # followed {' do
      expect_no_offenses(wrap('\#{my_lvar}'))
    end

    it 'does not register a bracket-escaped lvar interpolation' do
      expect_no_offenses(wrap('#\{my_lvar}'))
    end

    it 'does not register an offense for an escaped newline' do
      expect_no_offenses(wrap("foo\\\nbar"))
    end

    it 'does not register an offense for a newline' do
      expect_no_offenses(wrap('foo\n'))
    end

    it 'does not register an offense for a technically-unnecessary escape' do
      expect_no_offenses(wrap('\d'))
    end

    it 'does not register an offense for an octal escape' do
      expect_no_offenses(wrap('fo\157'))
    end

    it 'does not register an offense for a hex escape' do
      expect_no_offenses(wrap('fo\x6f'))
    end

    it 'does not register an offense for a unicode escape' do
      expect_no_offenses(wrap('fo\u006f'))
    end

    it 'does not register an offense for multiple unicode escapes' do
      expect_no_offenses(wrap('f\u{006f 006f}'))
    end

    it 'does not register an offense for control characters' do
      expect_no_offenses(wrap('\cc \C-c'))
    end

    it 'does not register an offense for a meta character' do
      expect_no_offenses(wrap('\M-c'))
    end

    it 'does not register an offense for meta control characters' do
      expect_no_offenses(wrap('\M-\C-c \M-\cc \c\M-c'))
    end

    it 'does not register an offense for an ascii DEL' do
      expect_no_offenses(wrap('\c? \C-?'))
    end

    unless l.include?('<<') # HEREDOC delimiters can't be escaped
      it 'does not register an offense for an escaped delimiter' do
        expect_no_offenses(wrap("\\#{r}a\\#{r}"))
      end

      it 'does not register an offense for an escaped delimiter before interpolation' do
        expect_no_offenses(wrap("\\#{r}\#{my_lvar}"))
      end
    end
  end

  RSpec.shared_examples 'a literal with interpolation' do |l, r|
    include_examples 'common no offenses', l, r

    it 'registers an offense and corrects an escaped # before interpolation' do
      expect_offense(<<~'RUBY', l: l, r: r)
        %{l}\##{whatever}%{r}
        _{l}^^ Redundant escape of # inside string literal.
      RUBY

      expect_correction(<<~RUBY)
        #{l}#\#{whatever}#{r}
      RUBY
    end

    it 'registers an offense and corrects an escaped # without following {' do
      expect_offense(<<~'RUBY', l: l, r: r)
        %{l}\#whatever%{r}
        _{l}^^ Redundant escape of # inside string literal.
      RUBY

      expect_correction(<<~RUBY)
        #{l}#whatever#{r}
      RUBY
    end

    it 'registers an offense and corrects an escaped } when escaping both brackets to avoid interpolation' do
      expect_offense(<<~'RUBY', l: l, r: r)
        %{l}#\{whatever\}%{r}
        _{l}           ^^ Redundant escape of } inside string literal.
      RUBY

      expect_correction(<<~RUBY)
        #{l}#\\{whatever}#{r}
      RUBY
    end

    it 'registers an offense and corrects an escaped `\{` when escaping `\#\{` to avoid interpolation' do
      expect_offense(<<~'RUBY', l: l, r: r)
        %{l}\#\{whatever}%{r}
        _{l}  ^^ Redundant escape of { inside string literal.
      RUBY

      expect_correction(<<~RUBY)
        #{l}\\\#{whatever}#{r}
      RUBY
    end

    it 'registers an offense and corrects an escaped # at end-of-string' do
      expect_offense(<<~'RUBY', l: l, r: r)
        %{l}\#%{r}
        _{l}^^ Redundant escape of # inside string literal.
      RUBY

      expect_correction(<<~RUBY)
        #{l}##{r}
      RUBY
    end

    it 'registers an offense and corrects an escaped single quote' do
      expect_offense(<<~'RUBY', l: l, r: r)
        %{l}\'%{r}
        _{l}^^ Redundant escape of ' inside string literal.
      RUBY

      expect_correction(<<~RUBY)
        #{l}'#{r}
      RUBY
    end

    if r != '"'
      it 'registers an offense and corrects a escaped nested delimiter in a double quoted string' do
        expect_offense(<<~'RUBY', l: l, r: r)
          %{l}#{"\%{r}"}%{r}
          _{l}   ^^ Redundant escape of %{r} inside string literal.
        RUBY

        expect_correction(<<~RUBY)
          #{l}\#{"#{r}"}#{r}
        RUBY
      end

      it 'registers an offense and corrects an escaped double quote' do
        expect_offense(<<~'RUBY', l: l, r: r)
          %{l}\"%{r}
          _{l}^^ Redundant escape of " inside string literal.
        RUBY

        expect_correction(<<~RUBY)
          #{l}"#{r}
        RUBY
      end
    end
  end

  RSpec.shared_examples 'a literal without interpolation' do |l, r|
    include_examples 'common no offenses', l, r

    it 'does not register an offense for an escaped # with following {' do
      expect_no_offenses(wrap('\#{my_lvar}'))
    end

    it 'does not register an offense with escaped # without following {' do
      expect_no_offenses(wrap('\#whatever'))
    end

    it 'does not register an offense with escaped # at end-of-string' do
      expect_no_offenses(wrap('\#'))
    end

    it 'does not register an offense with escaped single quote' do
      expect_no_offenses(wrap("\\'"))
    end

    it 'does not register an offense with escaped double quote' do
      expect_no_offenses(wrap('\"'))
    end

    it 'does not register an offense for an allowed escape inside multi-line literal' do
      expect_no_offenses(wrap("foo\\!\nbar"))
    end
  end

  it 'does not register an offense for a regexp literal' do
    expect_no_offenses('/\#/')
  end

  it 'does not register an offense for a x-str literal' do
    expect_no_offenses('%x{\#}')
  end

  it 'does not register an offense for a __FILE__ literal' do
    expect_no_offenses('"__FILE__"')
  end

  it 'does not register an offense for a __dir__ literal' do
    expect_no_offenses('"__dir__"')
  end

  context 'with a double quoted string' do
    it_behaves_like 'a literal with interpolation', '"', '"'

    it 'does not register an offense with multiple escaped backslashes' do
      expect_no_offenses(<<~'RUBY')
        "\\\\ \\'foo\\' \\\\"
      RUBY
    end

    it 'does not register an offense when escaping a quote in multi-line broken string' do
      expect_no_offenses(<<~'RUBY')
        "\""\
          "\""
      RUBY
    end

    it 'registers an offense and corrects an unnecessary escape in multi-line broken string' do
      expect_offense(<<~'RUBY')
        "\'"\
         ^^ Redundant escape of ' inside string literal.
          "\'"
           ^^ Redundant escape of ' inside string literal.
      RUBY

      expect_correction(<<~'RUBY')
        "'"\
          "'"
      RUBY
    end

    it 'does not register an offense with escaped double quote' do
      expect_no_offenses('"\""')
    end
  end

  context 'with a single quoted string' do
    it_behaves_like 'a literal without interpolation', "'", "'"
  end

  context 'with a %q(...) literal' do
    it_behaves_like 'a literal without interpolation', '%q(', ')'
  end

  context 'with a %Q(...) literal' do
    it_behaves_like 'a literal with interpolation', '%Q(', ')'
  end

  context 'with a %Q!...! literal' do
    it_behaves_like 'a literal with interpolation', '%Q!', '!'
  end

  context 'with a %(...) literal' do
    it_behaves_like 'a literal with interpolation', '%(', ')'
  end

  context 'with a %w(...) literal' do
    it_behaves_like 'a literal without interpolation', '%w(', ')'

    it 'does not register an offense for escaped spaces' do
      expect_no_offenses('%w[foo\  bar\  baz]')
    end
  end

  context 'with a %W(...) literal' do
    it_behaves_like 'a literal with interpolation', '%W[', ']'

    it 'does not register an offense for escaped spaces' do
      expect_no_offenses('%W[foo\  bar\  baz]')
    end
  end

  context 'when using character literals' do
    it 'does not register an offense for `?a`' do
      expect_no_offenses(<<~RUBY)
        ?a
      RUBY
    end

    it 'does not register an offense for `?\n`' do
      expect_no_offenses(<<~'RUBY')
        ?\n
      RUBY
    end
  end

  context 'with an interpolation-enabled HEREDOC' do
    include_examples 'common no offenses', "<<~MYHEREDOC\n", "\nMYHEREDOC"

    it 'does not register an offense for a heredoc interpolating a string with an allowed escape' do
      expect_no_offenses(<<~'RUBY')
        <<~MYHEREDOC
          #{foo.gsub(/[a-z]+/, '\"')}
        MYHEREDOC
      RUBY
    end

    it 'does not register an offense for a nested heredoc without interpolation' do
      expect_no_offenses(<<~'RUBY')
        <<~MYHEREDOC
          #{
            <<~'OTHERHEREDOC'
              \#
            OTHERHEREDOC
          }
        MYHEREDOC
      RUBY
    end

    it 'registers an offense and corrects an escaped # before interpolation' do
      expect_offense(<<~'RUBY')
        <<~MYHEREDOC
          \##{whatever}
          ^^ Redundant escape of # inside string literal.
        MYHEREDOC
      RUBY

      expect_correction(<<~'RUBY')
        <<~MYHEREDOC
          ##{whatever}
        MYHEREDOC
      RUBY
    end

    it 'registers an offense and corrects an escaped # without following {' do
      expect_offense(<<~'RUBY')
        <<~MYHEREDOC
          \#whatever
          ^^ Redundant escape of # inside string literal.
        MYHEREDOC
      RUBY

      expect_correction(<<~RUBY)
        <<~MYHEREDOC
          #whatever
        MYHEREDOC
      RUBY
    end

    it 'registers an offense and corrects an escaped # at end-of-string' do
      expect_offense(<<~'RUBY')
        <<~MYHEREDOC
          \#
          ^^ Redundant escape of # inside string literal.
        MYHEREDOC
      RUBY

      expect_correction(<<~RUBY)
        <<~MYHEREDOC
          #
        MYHEREDOC
      RUBY
    end

    it 'registers an offense and corrects an escaped single quote' do
      expect_offense(<<~'RUBY')
        <<~MYHEREDOC
          \'
          ^^ Redundant escape of ' inside string literal.
        MYHEREDOC
      RUBY

      expect_correction(<<~RUBY)
        <<~MYHEREDOC
          '
        MYHEREDOC
      RUBY
    end

    it 'does register an offense an escaped space' do
      expect_no_offenses(<<~'RUBY')
        <<~MYHEREDOC
          \ text
        MYHEREDOC
      RUBY
    end
  end

  context 'with an interpolation-disabled HEREDOC' do
    it_behaves_like 'a literal without interpolation', "<<~'MYHEREDOC'\n", "\nMYHEREDOC"
  end
end
