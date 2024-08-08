# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::RedundantRegexpArgument, :config do
  described_class::RESTRICT_ON_SEND.each do |method|
    it "registers an offense and corrects when the method is `#{method}`" do
      expect_offense(<<~RUBY, method: method)
        'foo'.#{method}(/f/)
              _{method} ^^^ Use string `'f'` as argument instead of regexp `/f/`.
      RUBY

      expect_correction(<<~RUBY)
        'foo'.#{method}('f')
      RUBY
    end

    it "registers an offense and corrects when the method with safe navigation operator is `#{method}`" do
      expect_offense(<<~RUBY, method: method)
        'foo'&.#{method}(/f/)
               _{method} ^^^ Use string `'f'` as argument instead of regexp `/f/`.
      RUBY

      expect_correction(<<~RUBY)
        'foo'&.#{method}('f')
      RUBY
    end
  end

  it 'registers an offense and corrects when using double quote and single quote characters' do
    expect_offense(<<~RUBY)
      str.gsub(/"''/, '')
               ^^^^^ Use string `'"\\'\\''` as argument instead of regexp `/"''/`.
    RUBY

    expect_correction(<<~RUBY)
      str.gsub('"\\'\\'', '')
    RUBY
  end

  it 'registers an offense and corrects when using double quote character' do
    expect_offense(<<~RUBY)
      str.gsub(/"/)
               ^^^ Use string `'"'` as argument instead of regexp `/"/`.
    RUBY

    expect_correction(<<~RUBY)
      str.gsub('"')
    RUBY
  end

  it 'registers an offense and corrects when using escaped double quote character' do
    expect_offense(<<~'RUBY')
      str.gsub(/\\"/)
               ^^^^^ Use string `'\\"'` as argument instead of regexp `/\\"/`.
    RUBY

    expect_correction(<<~'RUBY')
      str.gsub('\\"')
    RUBY
  end

  it 'registers an offense and corrects when using escaping characters' do
    expect_offense(<<~'RUBY')
      'a,b,c'.split(/\./)
                    ^^^^ Use string `'.'` as argument instead of regexp `/\./`.
    RUBY

    expect_correction(<<~RUBY)
      'a,b,c'.split('.')
    RUBY
  end

  it 'registers an offense and corrects when using special string chars' do
    expect_offense(<<~'RUBY')
      "foo\nbar\nbaz\n".split(/\n/)
                              ^^^^ Use string `"\n"` as argument instead of regexp `/\n/`.
    RUBY

    expect_correction(<<~'RUBY')
      "foo\nbar\nbaz\n".split("\n")
    RUBY
  end

  it 'registers an offense and corrects when using consecutive special string chars' do
    expect_offense(<<~'RUBY')
      "foo\n\nbar\n\nbaz\n\n".split(/\n\n/)
                                    ^^^^^^ Use string `"\n\n"` as argument instead of regexp `/\n\n/`.
    RUBY

    expect_correction(<<~'RUBY')
      "foo\n\nbar\n\nbaz\n\n".split("\n\n")
    RUBY
  end

  it 'registers an offense and corrects when using unicode chars' do
    expect_offense(<<~'RUBY')
      "foo\nbar\nbaz\n".split(/\u3000/)
                              ^^^^^^^^ Use string `"\u3000"` as argument instead of regexp `/\u3000/`.
    RUBY

    expect_correction(<<~'RUBY')
      "foo\nbar\nbaz\n".split("\u3000")
    RUBY
  end

  it 'registers an offense and corrects when using consecutive backslash escape chars' do
    expect_offense(<<~'RUBY')
      "foo\\\.bar".split(/\\\./)
                         ^^^^^^ Use string `"\\."` as argument instead of regexp `/\\\./`.
    RUBY

    expect_correction(<<~'RUBY')
      "foo\\\.bar".split("\\.")
    RUBY
  end

  it 'registers an offense and corrects when using complex special string chars' do
    expect_offense(<<~'RUBY')
      "foo\nbar\nbaz\n".split(/foo\n\.\n/)
                              ^^^^^^^^^^^ Use string `"foo\n.\n"` as argument instead of regexp `/foo\n\.\n/`.
    RUBY

    expect_correction(<<~'RUBY')
      "foo\nbar\nbaz\n".split("foo\n.\n")
    RUBY
  end

  it 'registers an offense and corrects when using two or more spaces regexp' do
    expect_offense(<<~RUBY)
      'foo         bar'.split(/  /)
                              ^^^^ Use string `'  '` as argument instead of regexp `/  /`.
    RUBY

    expect_correction(<<~RUBY)
      'foo         bar'.split('  ')
    RUBY
  end

  it 'accepts methods other than pattern argument method' do
    expect_no_offenses("'a,b,c'.insert(2, 'a')")
  end

  it 'accepts when using `[]` method' do
    expect_no_offenses('hash[/regexp/]')
  end

  it 'accepts when using `[]=` method' do
    expect_no_offenses('hash[/regexp/] = value')
  end

  it 'accepts when not receiving a regexp' do
    expect_no_offenses("'a,b,c'.split(',')")
  end

  it 'accepts when not receiving a deterministic regexp' do
    expect_no_offenses("'a,b,c'.split(/,+/)")
  end

  it 'accepts when using regexp argument with ignorecase regexp option' do
    expect_no_offenses("'fooSplitbar'.split(/split/i)")
  end

  it 'accepts when using regexp argument with extended regexp option' do
    expect_no_offenses("'fooSplitbar'.split(/split/x)")
  end

  it 'accepts when using method argument is exactly one space regexp `/ /`' do
    expect_no_offenses(<<~RUBY)
      'foo         bar'.split(/ /)
    RUBY
  end

  context 'when `Style/StringLiterals` is configured with `single_quotes`' do
    let(:other_cops) { { 'Style/StringLiterals' => { 'EnforcedStyle' => 'single_quotes' } } }

    it 'registers an offense and corrects to single quoted string when using non-backquoted regexp' do
      expect_offense(<<~RUBY)
        'foo'.split(/f/)
                    ^^^ Use string `'f'` as argument instead of regexp `/f/`.
      RUBY

      expect_correction(<<~RUBY)
        'foo'.split('f')
      RUBY
    end

    it 'registers an offense and corrects to double quoted string when using backquoted regexp' do
      expect_offense(<<~'RUBY')
        'foo'.split(/\n/)
                    ^^^^ Use string `"\n"` as argument instead of regexp `/\n/`.
      RUBY

      expect_correction(<<~'RUBY')
        'foo'.split("\n")
      RUBY
    end
  end

  context 'when `Style/StringLiterals` is configured with `double_quotes`' do
    let(:other_cops) { { 'Style/StringLiterals' => { 'EnforcedStyle' => 'double_quotes' } } }

    it 'registers an offense and corrects to double quoted string when using non-backquoted regexp' do
      expect_offense(<<~RUBY)
        'foo'.split(/f/)
                    ^^^ Use string `"f"` as argument instead of regexp `/f/`.
      RUBY

      expect_correction(<<~RUBY)
        'foo'.split("f")
      RUBY
    end
  end
end
