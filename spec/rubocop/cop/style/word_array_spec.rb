# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::WordArray, :config do
  before do
    # Reset data which is shared by all instances of WordArray
    described_class.largest_brackets = -Float::INFINITY
  end

  let(:other_cops) do
    {
      'Style/PercentLiteralDelimiters' => {
        'PreferredDelimiters' => {
          'default' => '()'
        }
      }
    }
  end

  context 'when EnforcedStyle is percent' do
    let(:cop_config) do
      { 'MinSize' => 0,
        'WordRegex' => /\A(?:\p{Word}|\p{Word}-\p{Word}|\n|\t)+\z/,
        'EnforcedStyle' => 'percent' }
    end

    it 'registers an offense for arrays of single quoted strings' do
      expect_offense(<<~RUBY)
        ['one', 'two', 'three']
        ^^^^^^^^^^^^^^^^^^^^^^^ Use `%w` or `%W` for an array of words.
      RUBY

      expect_correction(<<~RUBY)
        %w(one two three)
      RUBY
    end

    it 'registers an offense for arrays of double quoted strings' do
      expect_offense(<<~RUBY)
        ["one", "two", "three"]
        ^^^^^^^^^^^^^^^^^^^^^^^ Use `%w` or `%W` for an array of words.
      RUBY

      expect_correction(<<~RUBY)
        %w(one two three)
      RUBY
    end

    it 'registers an offense for arrays of strings containing hyphens' do
      expect_offense(<<~RUBY)
        ['foo', 'bar', 'foo-bar']
        ^^^^^^^^^^^^^^^^^^^^^^^^^ Use `%w` or `%W` for an array of words.
      RUBY

      expect_correction(<<~RUBY)
        %w(foo bar foo-bar)
      RUBY
    end

    context 'when the default external encoding is UTF-8' do
      around do |example|
        orig_encoding = Encoding.default_external
        Encoding.default_external = Encoding::UTF_8
        example.run
        Encoding.default_external = orig_encoding
      end

      it 'registers an offense for arrays of unicode word characters' do
        expect_offense(<<~RUBY, wide: '中文网')
          ["ВУЗ", "вуз", "%{wide}"]
          ^^^^^^^^^^^^^^^^^{wide}^^ Use `%w` or `%W` for an array of words.
        RUBY

        expect_correction(<<~RUBY)
          %w(ВУЗ вуз 中文网)
        RUBY
      end
    end

    context 'when the default external encoding is US-ASCII' do
      around do |example|
        orig_encoding = Encoding.default_external
        Encoding.default_external = Encoding::US_ASCII
        example.run
        Encoding.default_external = orig_encoding
      end

      it 'registers an offense for arrays of unicode word characters' do
        expect_offense(<<~RUBY, wide: '中文网')
          ["ВУЗ", "вуз", "%{wide}"]
          ^^^^^^^^^^^^^^^^^{wide}^^ Use `%w` or `%W` for an array of words.
        RUBY

        expect_correction(<<~'RUBY')
          %W(\u0412\u0423\u0417 \u0432\u0443\u0437 \u4E2D\u6587\u7F51)
        RUBY
      end
    end

    it 'registers an offense for arrays with character constants' do
      expect_offense(<<~'RUBY')
        ["one", ?\n]
        ^^^^^^^^^^^^ Use `%w` or `%W` for an array of words.
      RUBY

      expect_correction(<<~'RUBY')
        %W(one \n)
      RUBY
    end

    it 'uses %W when autocorrecting strings with embedded newlines and tabs' do
      expect_offense(<<~RUBY)
        ["one
        ^^^^^ Use `%w` or `%W` for an array of words.
        ", "hi\tthere"]
      RUBY

      expect_correction(<<~'RUBY')
        %W(one\n hi\tthere)
      RUBY
    end

    it 'registers an offense for strings with newline and tab escapes' do
      expect_offense(<<~'RUBY')
        ["one\n", "hi\tthere"]
        ^^^^^^^^^^^^^^^^^^^^^^ Use `%w` or `%W` for an array of words.
      RUBY

      expect_correction(<<~'RUBY')
        %W(one\n hi\tthere)
      RUBY
    end

    it 'does not register an offense for array of non-words' do
      expect_no_offenses('["one space", "two", "three"]')
    end

    it 'does not register an offense for array containing non-string' do
      expect_no_offenses('["one", "two", 3]')
    end

    it 'does not register an offense for array starting with %w' do
      expect_no_offenses('%w(one two three)')
    end

    it 'does not register an offense for array with empty strings' do
      expect_no_offenses('["", "two", "three"]')
    end

    it 'does not register an offense on non-word strings' do
      expect_no_offenses("['-', '----']")
    end

    # Bug: https://github.com/rubocop-hq/rubocop/issues/4481
    it 'does not register an offense in an ambiguous block context' do
      expect_no_offenses('foo ["bar", "baz"] { qux }')
    end

    it 'registers an offense in a non-ambiguous block context' do
      expect_offense(<<~RUBY)
        foo(['bar', 'baz']) { qux }
            ^^^^^^^^^^^^^^ Use `%w` or `%W` for an array of words.
      RUBY

      expect_correction(<<~RUBY)
        foo(%w(bar baz)) { qux }
      RUBY
    end

    it 'does not register offense for array with allowed number of strings' do
      cop_config['MinSize'] = 4
      expect_no_offenses('["one", "two", "three"]')
    end

    it 'does not register an offense for an array with comments in it' do
      expect_no_offenses(<<~RUBY)
        [
        "foo", # comment here
        "bar", # this thing was done because of a bug
        "baz" # do not delete this line
        ]
      RUBY
    end

    it 'registers an offense for an array with comments outside of it' do
      expect_offense(<<~RUBY)
        [
        ^ Use `%w` or `%W` for an array of words.
        "foo",
        "bar",
        "baz"
        ] # test
      RUBY

      expect_correction(<<~RUBY)
        %w(
        foo
        bar
        baz
        ) # test
      RUBY
    end

    it 'auto-corrects an array of words' do
      expect_offense(<<~RUBY)
        ['one', %q(two), 'three']
        ^^^^^^^^^^^^^^^^^^^^^^^^^ Use `%w` or `%W` for an array of words.
      RUBY

      expect_correction(<<~RUBY)
        %w(one two three)
      RUBY
    end

    it 'auto-corrects an array with one element' do
      expect_offense(<<~RUBY)
        ['one']
        ^^^^^^^ Use `%w` or `%W` for an array of words.
      RUBY

      expect_correction(<<~RUBY)
        %w(one)
      RUBY
    end

    it 'auto-corrects an array of words and character constants' do
      expect_offense(<<~'RUBY')
        [%|one|, %Q(two), ?\n, ?\t]
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `%w` or `%W` for an array of words.
      RUBY

      expect_correction(<<~'RUBY')
        %W(one two \n \t)
      RUBY
    end

    it 'keeps the line breaks in place after auto-correct' do
      expect_offense(<<~RUBY)
        ['one',
        ^^^^^^^ Use `%w` or `%W` for an array of words.
        'two', 'three']
      RUBY

      expect_correction(<<~RUBY)
        %w(one
        two three)
      RUBY
    end

    it 'auto-corrects an array of words in multiple lines' do
      expect_offense(<<-RUBY)
        [
        ^ Use `%w` or `%W` for an array of words.
        "foo",
        "bar",
        "baz"
        ]
      RUBY

      expect_correction(<<-RUBY)
        %w(
        foo
        bar
        baz
        )
      RUBY
    end

    it 'auto-corrects an array of words using partial newlines' do
      expect_offense(<<-RUBY)
        ["foo", "bar", "baz",
        ^^^^^^^^^^^^^^^^^^^^^ Use `%w` or `%W` for an array of words.
        "boz", "buz",
        "biz"]
      RUBY

      expect_correction(<<-RUBY)
        %w(foo bar baz
        boz buz
        biz)
      RUBY
    end

    it 'detects right value of MinSize to use for --auto-gen-config' do
      expect_offense(<<~RUBY)
        ['one', 'two', 'three']
        ^^^^^^^^^^^^^^^^^^^^^^^ Use `%w` or `%W` for an array of words.
        %w(a b c d)
      RUBY

      expect_correction(<<~RUBY)
        %w(one two three)
        %w(a b c d)
      RUBY

      expect(cop.config_to_allow_offenses).to eq('EnforcedStyle' => 'percent',
                                                 'MinSize' => 4)
    end

    it 'detects when the cop must be disabled to avoid offenses' do
      expect_offense(<<~RUBY)
        ['one', 'two', 'three']
        ^^^^^^^^^^^^^^^^^^^^^^^ Use `%w` or `%W` for an array of words.
        %w(a b)
      RUBY

      expect_correction(<<~RUBY)
        %w(one two three)
        %w(a b)
      RUBY

      expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
    end

    it "doesn't fail in wacky ways when multiple cop instances are used" do
      # Regression test for GH issue #2740
      cop1 = described_class.new(config)
      cop2 = described_class.new(config)
      RuboCop::Formatter::DisabledConfigFormatter.config_to_allow_offenses = {}
      RuboCop::Formatter::DisabledConfigFormatter.detected_styles = {}
      # Don't use `expect_offense`; it resets `config_to_allow_offenses` each
      #   time, which suppresses the bug we are checking for
      _investigate(cop1, parse_source("['g', 'h']"))
      _investigate(cop2, parse_source('%w(a b c)'))
      expect(cop2.config_to_allow_offenses).to eq('EnforcedStyle' => 'percent',
                                                  'MinSize' => 3)
    end
  end

  context 'when EnforcedStyle is array' do
    let(:cop_config) do
      { 'MinSize' => 0,
        'WordRegex' => /\A(?:\p{Word}|\p{Word}-\p{Word}|\n|\t)+\z/,
        'EnforcedStyle' => 'brackets' }
    end

    it 'does not register an offense for arrays of single quoted strings' do
      expect_no_offenses("['one', 'two', 'three']")
    end

    it 'does not register an offense for arrays of double quoted strings' do
      expect_no_offenses('["one", "two", "three"]')
    end

    it 'does not register an offense for arrays of strings with hyphens' do
      expect_no_offenses("['foo', 'bar', 'foo-bar']")
    end

    it 'registers an offense for a %w() array' do
      expect_offense(<<~RUBY)
        %w(one two three)
        ^^^^^^^^^^^^^^^^^ Use `[]` for an array of words.
      RUBY

      expect_correction(<<~RUBY)
        ['one', 'two', 'three']
      RUBY
    end

    it 'autocorrects a %w() array which uses single quotes' do
      expect_offense(<<~RUBY)
        %w(one's two's three's)
        ^^^^^^^^^^^^^^^^^^^^^^^ Use `[]` for an array of words.
      RUBY

      expect_correction(<<~RUBY)
        ["one's", "two's", "three's"]
      RUBY
    end

    it 'autocorrects a %W() array which uses escapes' do
      expect_offense(<<~'RUBY')
        %W(\n \t \b \v \f)
        ^^^^^^^^^^^^^^^^^^ Use `[]` for an array of words.
      RUBY

      expect_correction(<<~'RUBY')
        ["\n", "\t", "\b", "\v", "\f"]
      RUBY
    end

    it 'autocorrects a %w() array which uses string with hyphen' do
      expect_offense(<<~RUBY)
        %w(foo bar foo-bar)
        ^^^^^^^^^^^^^^^^^^^ Use `[]` for an array of words.
      RUBY

      expect_correction(<<~RUBY)
        ['foo', 'bar', 'foo-bar']
      RUBY
    end

    it 'autocorrects a %W() array which uses string with hyphen' do
      expect_offense(<<~'RUBY')
        %W(foo bar #{foo}-bar)
        ^^^^^^^^^^^^^^^^^^^^^^ Use `[]` for an array of words.
      RUBY

      expect_correction(<<~'RUBY')
        ['foo', 'bar', "#{foo}-bar"]
      RUBY
    end

    it 'autocorrects a %W() array which uses string interpolation' do
      expect_offense(<<~'RUBY')
        %W(#{foo}bar baz)
        ^^^^^^^^^^^^^^^^^ Use `[]` for an array of words.
      RUBY

      expect_correction(<<~'RUBY')
        ["#{foo}bar", 'baz']
      RUBY
    end

    it "doesn't fail on strings which are not valid UTF-8" do
      # Regression test, see GH issue 2671
      expect_no_offenses(<<~'RUBY')
        ["\xC0",
         "\xC2\x4a",
         "\xC2\xC2",
         "\x4a\x82",
         "\x82\x82",
         "\xe1\x82\x4a",
        ]
      RUBY
    end

    it "doesn't fail with `encoding: binary" do
      expect_no_offenses(<<~'RUBY')
        # -*- encoding: binary -*-
        ["\xC0"] # Invalid as UTF-8
        ['a']    # Valid as UTF-8 and ASCII
        ["あ"]   # Valid as UTF-8
      RUBY
    end
  end

  context 'with a custom WordRegex configuration' do
    let(:cop_config) { { 'MinSize' => 0, 'WordRegex' => /\A[\w@.]+\z/ } }

    it 'registers an offense for arrays of email addresses' do
      expect_offense(<<~RUBY)
        ['a@example.com', 'b@example.com']
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `%w` or `%W` for an array of words.
      RUBY

      expect_correction(<<~RUBY)
        %w(a@example.com b@example.com)
      RUBY
    end
  end

  context 'when the WordRegex configuration is not a Regexp' do
    let(:cop_config) { { 'WordRegex' => 'just_a_string' } }

    it 'still parses the code without raising an error' do
      expect { expect_no_offenses('') }.not_to raise_error
    end
  end

  context 'with a WordRegex configuration which accepts almost anything' do
    let(:cop_config) { { 'MinSize' => 0, 'WordRegex' => /\S+/ } }

    it 'uses %W when autocorrecting strings with non-printable chars' do
      expect_offense(<<~'RUBY')
        ["\x1f\x1e", "hello"]
        ^^^^^^^^^^^^^^^^^^^^^ Use `%w` or `%W` for an array of words.
      RUBY

      expect_correction(<<~'RUBY')
        %W(\u001F\u001E hello)
      RUBY
    end

    it 'uses %w for strings which only appear to have an escape' do
      expect_offense(<<~'RUBY')
        ['hi\tthere', 'again\n']
        ^^^^^^^^^^^^^^^^^^^^^^^^ Use `%w` or `%W` for an array of words.
      RUBY

      expect_correction(<<~'RUBY')
        %w(hi\tthere again\n)
      RUBY
    end
  end

  context 'with a treacherous WordRegex configuration' do
    let(:cop_config) { { 'MinSize' => 0, 'WordRegex' => /[\w \[\]()]/ } }

    it "doesn't break when words contain whitespace" do
      expect_no_offenses(<<~RUBY)
        ['hi there', 'something\telse']
      RUBY
    end

    it "doesn't break when words contain delimiters" do
      expect_offense(<<~RUBY)
        [')', ']', '(']
        ^^^^^^^^^^^^^^^ Use `%w` or `%W` for an array of words.
      RUBY

      expect_correction(<<~'RUBY')
        %w(\) ] \()
      RUBY
    end

    context 'when PreferredDelimiters is specified' do
      let(:other_cops) do
        {
          'Style/PercentLiteralDelimiters' => {
            'PreferredDelimiters' => {
              'default' => '[]'
            }
          }
        }
      end

      it 'autocorrects an array with delimiters' do
        expect_offense(<<~RUBY)
          [')', ']', '(', '[']
          ^^^^^^^^^^^^^^^^^^^^ Use `%w` or `%W` for an array of words.
        RUBY

        expect_correction(<<~'RUBY')
          %w[) \] ( \[]
        RUBY
      end
    end
  end

  context 'with non-default MinSize' do
    let(:cop_config) do
      { 'MinSize' => 2,
        'WordRegex' => /\A(?:\p{Word}|\p{Word}-\p{Word}|\n|\t)+\z/,
        'EnforcedStyle' => 'percent' }
    end

    it 'does not autocorrects arrays of one symbol if MinSize > 1' do
      expect_no_offenses('["one"]')
    end
  end
end
