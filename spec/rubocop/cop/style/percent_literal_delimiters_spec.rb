# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::PercentLiteralDelimiters, :config do
  let(:cop_config) { { 'PreferredDelimiters' => { 'default' => '[]' } } }

  context '`default` override' do
    let(:cop_config) { { 'PreferredDelimiters' => { 'default' => '[]', '%' => '()' } } }

    it 'allows all preferred delimiters to be set with one key' do
      expect_no_offenses('%w[string] + %i[string]')
    end

    it 'allows individual preferred delimiters to override `default`' do
      expect_no_offenses('%w[string] + [%(string)]')
    end
  end

  context 'invalid cop config' do
    let(:cop_config) { { 'PreferredDelimiters' => { 'foobar' => '()' } } }

    it 'raises an error when invalid configuration is specified' do
      expect { expect_no_offenses('%w[string]') }.to raise_error(ArgumentError)
    end
  end

  context '`%` interpolated string' do
    it 'does not register an offense for preferred delimiters' do
      expect_no_offenses('%[string]')
    end

    it 'registers an offense for other delimiters' do
      expect_offense(<<~RUBY)
        %(string)
        ^^^^^^^^^ `%`-literals should be delimited by `[` and `]`.
      RUBY

      expect_correction(<<~RUBY)
        %[string]
      RUBY
    end

    it 'registers an offense for a string with no content' do
      expect_offense(<<~RUBY)
        %()
        ^^^ `%`-literals should be delimited by `[` and `]`.
      RUBY

      expect_correction(<<~RUBY)
        %[]
      RUBY
    end

    it 'does not register an offense for other delimiters ' \
       'when containing preferred delimiter characters' do
      expect_no_offenses(<<~RUBY)
        %([string])
      RUBY
    end

    it 'registers an offense for other delimiters ' \
       'when containing preferred delimiter characters in interpolation' do
      expect_offense(<<~'RUBY')
        %(#{[1].first})
        ^^^^^^^^^^^^^^^ `%`-literals should be delimited by `[` and `]`.
      RUBY

      expect_correction(<<~'RUBY')
        %[#{[1].first}]
      RUBY
    end

    it 'registers an offense when the source contains invalid characters' do
      expect_offense(<<~'RUBY')
        %{\x80}
        ^^^^^^^ `%`-literals should be delimited by `[` and `]`.
      RUBY

      expect_correction(<<~'RUBY')
        %[\x80]
      RUBY
    end
  end

  context '`%q` string' do
    it 'does not register an offense for preferred delimiters' do
      expect_no_offenses('%q[string]')
    end

    it 'registers an offense for other delimiters' do
      expect_offense(<<~RUBY)
        %q(string)
        ^^^^^^^^^^ `%q`-literals should be delimited by `[` and `]`.
      RUBY

      expect_correction(<<~RUBY)
        %q[string]
      RUBY
    end

    it 'does not register an offense for other delimiters ' \
       'when containing preferred delimiter characters' do
      expect_no_offenses(<<~RUBY)
        %q([string])
      RUBY
    end
  end

  context '`%Q` interpolated string' do
    it 'does not register an offense for preferred delimiters' do
      expect_no_offenses('%Q[string]')
    end

    it 'registers an offense for other delimiters' do
      expect_offense(<<~RUBY)
        %Q(string)
        ^^^^^^^^^^ `%Q`-literals should be delimited by `[` and `]`.
      RUBY

      expect_correction(<<~RUBY)
        %Q[string]
      RUBY
    end

    it 'does not register an offense for other delimiters ' \
       'when containing preferred delimiter characters' do
      expect_no_offenses(<<~RUBY)
        %Q([string])
      RUBY
    end

    it 'registers an offense for other delimiters ' \
       'when containing preferred delimiter characters in interpolation' do
      expect_offense(<<~'RUBY')
        %Q(#{[1].first})
        ^^^^^^^^^^^^^^^^ `%Q`-literals should be delimited by `[` and `]`.
      RUBY

      expect_correction(<<~'RUBY')
        %Q[#{[1].first}]
      RUBY
    end
  end

  context '`%w` string array' do
    it 'does not register an offense for preferred delimiters' do
      expect_no_offenses('%w[some words]')
    end

    it 'does not register an offense for preferred delimiters with a pairing delimiters' do
      expect_no_offenses('%w(\(some words\))')
    end

    it 'does not register an offense for preferred delimiters with only a closing delimiter' do
      expect_no_offenses('%w(only closing delimiter character\))')
    end

    it 'does not register an offense for preferred delimiters with not a pairing delimiter' do
      expect_no_offenses('%w|\|not pairing delimiter|')
    end

    it 'registers an offense for other delimiters' do
      expect_offense(<<~RUBY)
        %w(some words)
        ^^^^^^^^^^^^^^ `%w`-literals should be delimited by `[` and `]`.
      RUBY

      expect_correction(<<~RUBY)
        %w[some words]
      RUBY
    end

    it 'does not register an offense for other delimiters ' \
       'when containing preferred delimiter characters' do
      expect_no_offenses('%w([some] [words])')
    end
  end

  context '`%W` interpolated string array' do
    it 'does not register an offense for preferred delimiters' do
      expect_no_offenses('%W[some words]')
    end

    it 'registers an offense for other delimiters' do
      expect_offense(<<~RUBY)
        %W(some words)
        ^^^^^^^^^^^^^^ `%W`-literals should be delimited by `[` and `]`.
      RUBY

      expect_correction(<<~RUBY)
        %W[some words]
      RUBY
    end

    it 'does not register an offense for other delimiters ' \
       'when containing preferred delimiter characters' do
      expect_no_offenses('%W([some] [words])')
    end

    it 'registers an offense for other delimiters ' \
       'when containing preferred delimiter characters in interpolation' do
      expect_offense(<<~'RUBY')
        %W(#{[1].first})
        ^^^^^^^^^^^^^^^^ `%W`-literals should be delimited by `[` and `]`.
      RUBY

      expect_correction(<<~'RUBY')
        %W[#{[1].first}]
      RUBY
    end
  end

  context '`%r` interpolated regular expression' do
    it 'does not register an offense for preferred delimiters' do
      expect_no_offenses('%r[regexp]')
    end

    it 'registers an offense for other delimiters' do
      expect_offense(<<~RUBY)
        %r(regexp)
        ^^^^^^^^^^ `%r`-literals should be delimited by `[` and `]`.
      RUBY

      expect_correction(<<~RUBY)
        %r[regexp]
      RUBY
    end

    it 'does not register an offense for other delimiters ' \
       'when containing preferred delimiter characters' do
      expect_no_offenses('%r([regexp])')
    end

    it 'registers an offense for other delimiters ' \
       'when containing preferred delimiter characters in interpolation' do
      expect_offense(<<~'RUBY')
        %r(#{[1].first})
        ^^^^^^^^^^^^^^^^ `%r`-literals should be delimited by `[` and `]`.
      RUBY

      expect_correction(<<~'RUBY')
        %r[#{[1].first}]
      RUBY
    end

    it 'registers an offense for a regular expression with option' do
      expect_offense(<<~RUBY)
        %r(.*)i
        ^^^^^^^ `%r`-literals should be delimited by `[` and `]`.
      RUBY

      expect_correction(<<~RUBY)
        %r[.*]i
      RUBY
    end
  end

  context '`%i` symbol array' do
    it 'does not register an offense for preferred delimiters' do
      expect_no_offenses('%i[some symbols]')
    end

    it 'does not register an offense for non-preferred delimiters enclosing escaped delimiters' do
      expect_no_offenses('%i(\(\) each)')
    end

    it 'registers an offense for other delimiters' do
      expect_offense(<<~RUBY)
        %i(some symbols)
        ^^^^^^^^^^^^^^^^ `%i`-literals should be delimited by `[` and `]`.
      RUBY

      expect_correction(<<~RUBY)
        %i[some symbols]
      RUBY
    end
  end

  context '`%I` interpolated symbol array' do
    it 'does not register an offense for preferred delimiters' do
      expect_no_offenses('%I[some words]')
    end

    it 'registers an offense for other delimiters' do
      expect_offense(<<~RUBY)
        %I(some words)
        ^^^^^^^^^^^^^^ `%I`-literals should be delimited by `[` and `]`.
      RUBY

      expect_correction(<<~RUBY)
        %I[some words]
      RUBY
    end

    it 'registers an offense for other delimiters ' \
       'when containing preferred delimiter characters in interpolation' do
      expect_offense(<<~'RUBY')
        %I(#{[1].first})
        ^^^^^^^^^^^^^^^^ `%I`-literals should be delimited by `[` and `]`.
      RUBY

      expect_correction(<<~'RUBY')
        %I[#{[1].first}]
      RUBY
    end
  end

  context '`%s` symbol' do
    it 'does not register an offense for preferred delimiters' do
      expect_no_offenses('%s[symbol]')
    end

    it 'registers an offense for other delimiters' do
      expect_offense(<<~RUBY)
        %s(symbol)
        ^^^^^^^^^^ `%s`-literals should be delimited by `[` and `]`.
      RUBY

      expect_correction(<<~RUBY)
        %s[symbol]
      RUBY
    end
  end

  context '`%x` interpolated system call' do
    it 'does not register an offense for preferred delimiters' do
      expect_no_offenses('%x[command]')
    end

    it 'registers an offense for other delimiters' do
      expect_offense(<<~RUBY)
        %x(command)
        ^^^^^^^^^^^ `%x`-literals should be delimited by `[` and `]`.
      RUBY

      expect_correction(<<~RUBY)
        %x[command]
      RUBY
    end

    it 'does not register an offense for other delimiters ' \
       'when containing preferred delimiter characters' do
      expect_no_offenses('%x([command])')
    end

    it 'registers an offense for other delimiters ' \
       'when containing preferred delimiter characters in interpolation' do
      expect_offense(<<~'RUBY')
        %x(#{[1].first})
        ^^^^^^^^^^^^^^^^ `%x`-literals should be delimited by `[` and `]`.
      RUBY

      expect_correction(<<~'RUBY')
        %x[#{[1].first}]
      RUBY
    end
  end

  context 'autocorrect' do
    it 'fixes a string array in a scope' do
      expect_offense(<<~RUBY)
        module Foo
           class Bar
             def baz
               %(one two)
               ^^^^^^^^^^ `%`-literals should be delimited by `[` and `]`.
             end
           end
         end
      RUBY

      expect_correction(<<~RUBY)
        module Foo
           class Bar
             def baz
               %[one two]
             end
           end
         end
      RUBY
    end

    it 'preserves line breaks when fixing a multiline array' do
      expect_offense(<<~RUBY)
        %w(
        ^^^ `%w`-literals should be delimited by `[` and `]`.
        some
        words
        )
      RUBY

      expect_correction(<<~RUBY)
        %w[
        some
        words
        ]
      RUBY
    end

    it 'preserves indentation when correcting a multiline array' do
      expect_offense(<<-RUBY.strip_margin('|'))
        |  array = %w(
        |          ^^^ `%w`-literals should be delimited by `[` and `]`.
        |    first
        |    second
        |  )
      RUBY

      expect_correction(<<-RUBY.strip_margin('|'))
        |  array = %w[
        |    first
        |    second
        |  ]
      RUBY
    end

    it 'preserves irregular indentation when correcting a multiline array' do
      expect_offense(<<~RUBY)
          array = %w(
                  ^^^ `%w`-literals should be delimited by `[` and `]`.
            first
          second
        )
      RUBY

      expect_correction(<<~RUBY)
          array = %w[
            first
          second
        ]
      RUBY
    end

    shared_examples 'escape characters' do |percent_literal|
      let(:tab) { "\t" }

      it "corrects #{percent_literal} with \\n in it" do
        expect_offense(<<~RUBY, percent_literal: percent_literal)
          %{percent_literal}{
          ^{percent_literal}^ `#{percent_literal}`-literals should be delimited by `[` and `]`.
          }
        RUBY

        expect_correction(<<~RUBY)
          #{percent_literal}[
          ]
        RUBY
      end

      it "corrects #{percent_literal} with \\t in it" do
        expect_offense(<<~RUBY, percent_literal: percent_literal, tab: tab)
          %{percent_literal}{%{tab}}
          ^{percent_literal}^^{tab}^ `#{percent_literal}`-literals should be delimited by `[` and `]`.
        RUBY

        expect_correction(<<~RUBY)
          #{percent_literal}[\t]
        RUBY
      end
    end

    it_behaves_like('escape characters', '%')
    it_behaves_like('escape characters', '%q')
    it_behaves_like('escape characters', '%Q')
    it_behaves_like('escape characters', '%s')
    it_behaves_like('escape characters', '%w')
    it_behaves_like('escape characters', '%W')
    it_behaves_like('escape characters', '%x')
    it_behaves_like('escape characters', '%r')
    it_behaves_like('escape characters', '%i')
  end
end
