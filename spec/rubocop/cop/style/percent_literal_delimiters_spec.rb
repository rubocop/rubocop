# frozen_string_literal: true

describe RuboCop::Cop::Style::PercentLiteralDelimiters, :config do
  subject(:cop) { described_class.new(config) }

  let(:cop_config) do
    { 'PreferredDelimiters' => { 'default' => '[]' } }
  end

  context '`default` override' do
    let(:cop_config) do
      {
        'PreferredDelimiters' => {
          'default' => '[]',
          '%'       => '()'
        }
      }
    end

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
      expect { inspect_source('%w[string]') }.to raise_error(ArgumentError)
    end
  end

  context '`%` interpolated string' do
    it 'does not register an offense for preferred delimiters' do
      expect_no_offenses('%[string]')
    end

    it 'registers an offense for other delimiters' do
      expect_offense(<<-RUBY.strip_indent)
        %(string)
        ^^^^^^^^^ `%`-literals should be delimited by `[` and `]`.
      RUBY
    end

    it 'does not register an offense for other delimiters ' \
       'when containing preferred delimiter characters' do
      inspect_source('%([string])')
      expect(cop.offenses).to be_empty
    end

    it 'registers an offense for other delimiters ' \
       'when containing preferred delimiter characters in interpolation' do
      inspect_source('%(#{[1].first})')
      expect(cop.messages.size).to eq(1)
    end
  end

  context '`%q` string' do
    it 'does not register an offense for preferred delimiters' do
      expect_no_offenses('%q[string]')
    end

    it 'registers an offense for other delimiters' do
      expect_offense(<<-RUBY.strip_indent)
        %q(string)
        ^^^^^^^^^^ `%q`-literals should be delimited by `[` and `]`.
      RUBY
    end

    it 'does not register an offense for other delimiters ' \
       'when containing preferred delimiter characters' do
      inspect_source('%q([string])')
      expect(cop.offenses).to be_empty
    end
  end

  context '`%Q` interpolated string' do
    it 'does not register an offense for preferred delimiters' do
      expect_no_offenses('%Q[string]')
    end

    it 'registers an offense for other delimiters' do
      expect_offense(<<-RUBY.strip_indent)
        %Q(string)
        ^^^^^^^^^^ `%Q`-literals should be delimited by `[` and `]`.
      RUBY
    end

    it 'does not register an offense for other delimiters ' \
       'when containing preferred delimiter characters' do
      inspect_source('%Q([string])')
      expect(cop.offenses).to be_empty
    end

    it 'registers an offense for other delimiters ' \
       'when containing preferred delimiter characters in interpolation' do
      inspect_source('%Q(#{[1].first})')
      expect(cop.messages.size).to eq(1)
    end
  end

  context '`%w` string array' do
    it 'does not register an offense for preferred delimiters' do
      expect_no_offenses('%w[some words]')
    end

    it 'registers an offense for other delimiters' do
      expect_offense(<<-RUBY.strip_indent)
        %w(some words)
        ^^^^^^^^^^^^^^ `%w`-literals should be delimited by `[` and `]`.
      RUBY
    end

    it 'does not register an offense for other delimiters ' \
       'when containing preferred delimiter characters' do
      inspect_source('%w([some] [words])')
      expect(cop.offenses).to be_empty
    end
  end

  context '`%W` interpolated string array' do
    it 'does not register an offense for preferred delimiters' do
      expect_no_offenses('%W[some words]')
    end

    it 'registers an offense for other delimiters' do
      expect_offense(<<-RUBY.strip_indent)
        %W(some words)
        ^^^^^^^^^^^^^^ `%W`-literals should be delimited by `[` and `]`.
      RUBY
    end

    it 'does not register an offense for other delimiters ' \
       'when containing preferred delimiter characters' do
      inspect_source('%W([some] [words])')
      expect(cop.offenses).to be_empty
    end

    it 'registers an offense for other delimiters ' \
       'when containing preferred delimiter characters in interpolation' do
      inspect_source('%W(#{[1].first})')
      expect(cop.messages.size).to eq(1)
    end
  end

  context '`%r` interpolated regular expression' do
    it 'does not register an offense for preferred delimiters' do
      expect_no_offenses('%r[regexp]')
    end

    it 'registers an offense for other delimiters' do
      expect_offense(<<-RUBY.strip_indent)
        %r(regexp)
        ^^^^^^^^^^ `%r`-literals should be delimited by `[` and `]`.
      RUBY
    end

    it 'does not register an offense for other delimiters ' \
       'when containing preferred delimiter characters' do
      inspect_source('%r([regexp])')
      expect(cop.offenses).to be_empty
    end

    it 'registers an offense for other delimiters ' \
       'when containing preferred delimiter characters in interpolation' do
      inspect_source('%r(#{[1].first})')
      expect(cop.messages.size).to eq(1)
    end
  end

  context '`%i` symbol array' do
    it 'does not register an offense for preferred delimiters' do
      expect_no_offenses('%i[some symbols]')
    end

    it 'registers an offense for other delimiters' do
      expect_offense(<<-RUBY.strip_indent)
        %i(some symbols)
        ^^^^^^^^^^^^^^^^ `%i`-literals should be delimited by `[` and `]`.
      RUBY
    end
  end

  context '`%I` interpolated symbol array' do
    it 'does not register an offense for preferred delimiters' do
      expect_no_offenses('%I[some words]')
    end

    it 'registers an offense for other delimiters' do
      expect_offense(<<-RUBY.strip_indent)
        %I(some words)
        ^^^^^^^^^^^^^^ `%I`-literals should be delimited by `[` and `]`.
      RUBY
    end

    it 'registers an offense for other delimiters ' \
       'when containing preferred delimiter characters in interpolation' do
      inspect_source('%I(#{[1].first})')
      expect(cop.messages).to eq(
        ['`%I`-literals should be delimited by `[` and `]`.']
      )
    end
  end

  context '`%s` symbol' do
    it 'does not register an offense for preferred delimiters' do
      expect_no_offenses('%s[symbol]')
    end

    it 'registers an offense for other delimiters' do
      expect_offense(<<-RUBY.strip_indent)
        %s(symbol)
        ^^^^^^^^^^ `%s`-literals should be delimited by `[` and `]`.
      RUBY
    end
  end

  context '`%x` interpolated system call' do
    it 'does not register an offense for preferred delimiters' do
      expect_no_offenses('%x[command]')
    end

    it 'registers an offense for other delimiters' do
      expect_offense(<<-RUBY.strip_indent)
        %x(command)
        ^^^^^^^^^^^ `%x`-literals should be delimited by `[` and `]`.
      RUBY
    end

    it 'does not register an offense for other delimiters ' \
       'when containing preferred delimiter characters' do
      inspect_source('%x([command])')
      expect(cop.offenses).to be_empty
    end

    it 'registers an offense for other delimiters ' \
       'when containing preferred delimiter characters in interpolation' do
      inspect_source('%x(#{[1].first})')
      expect(cop.messages.size).to eq(1)
    end
  end

  context 'auto-correct' do
    it 'fixes a string' do
      new_source = autocorrect_source('%(string)')
      expect(new_source).to eq('%[string]')
    end

    it 'fixes a string with no content' do
      new_source = autocorrect_source('%()')
      expect(new_source).to eq('%[]')
    end

    it 'fixes a string array' do
      new_source = autocorrect_source('%w(some words)')
      expect(new_source).to eq('%w[some words]')
    end

    it 'fixes a string array in a scope' do
      new_source = autocorrect_source(<<-RUBY.strip_indent)
        module Foo
           class Bar
             def baz
               %(one two)
             end
           end
         end
      RUBY
      expect(new_source).to eq(<<-RUBY.strip_indent)
        module Foo
           class Bar
             def baz
               %[one two]
             end
           end
         end
      RUBY
    end

    it 'fixes a regular expression' do
      original_source = '%r(.*)'
      new_source = autocorrect_source(original_source)
      expect(new_source).to eq('%r[.*]')
    end

    it 'fixes a string with interpolation' do
      original_source = '%Q|#{with_interpolation}|'
      new_source = autocorrect_source(original_source)
      expect(new_source).to eq('%Q[#{with_interpolation}]')
    end

    it 'fixes a regular expression with interpolation' do
      original_source = '%r|#{with_interpolation}|'
      new_source = autocorrect_source(original_source)
      expect(new_source).to eq('%r[#{with_interpolation}]')
    end

    it 'fixes a regular expression with option' do
      original_source = '%r(.*)i'
      new_source = autocorrect_source(original_source)
      expect(new_source).to eq('%r[.*]i')
    end

    it 'preserves line breaks when fixing a multiline array' do
      new_source = autocorrect_source(<<-RUBY.strip_indent)
        %w(
        some
        words
        )
      RUBY
      expect(new_source).to eq(<<-RUBY.strip_indent)
        %w[
        some
        words
        ]
      RUBY
    end

    it 'preserves indentation when correcting a multiline array' do
      original_source = <<-RUBY.strip_margin('|')
        |  array = %w(
        |    first
        |    second
        |  )
      RUBY
      corrected_source = <<-RUBY.strip_margin('|')
        |  array = %w[
        |    first
        |    second
        |  ]
      RUBY
      new_source = autocorrect_source(original_source)
      expect(new_source).to eq(corrected_source)
    end

    it 'preserves irregular indentation when correcting a multiline array' do
      original_source = <<-RUBY.strip_indent
          array = %w(
            first
          second
        )
      RUBY
      corrected_source = <<-RUBY.strip_indent
          array = %w[
            first
          second
        ]
      RUBY
      new_source = autocorrect_source(original_source)
      expect(new_source).to eq(corrected_source)
    end

    shared_examples :escape_characters do |percent_literal|
      it "corrects #{percent_literal} with \\n in it" do
        new_source = autocorrect_source("#{percent_literal}{\n}")

        expect(new_source).to eq("#{percent_literal}[\n]")
      end

      it "corrects #{percent_literal} with \\t in it" do
        new_source = autocorrect_source("#{percent_literal}{\t}")

        expect(new_source).to eq("#{percent_literal}[\t]")
      end
    end

    it_behaves_like(:escape_characters, '%')
    it_behaves_like(:escape_characters, '%q')
    it_behaves_like(:escape_characters, '%Q')
    it_behaves_like(:escape_characters, '%s')
    it_behaves_like(:escape_characters, '%w')
    it_behaves_like(:escape_characters, '%W')
    it_behaves_like(:escape_characters, '%x')
    it_behaves_like(:escape_characters, '%r')
    it_behaves_like(:escape_characters, '%i')
  end
end
