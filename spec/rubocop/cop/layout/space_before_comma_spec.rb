# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::SpaceBeforeComma, :config do
  subject(:cop) { described_class.new(config) }

  let(:cop_config) { { 'EnforcedStyle' => enforced_style } }
  let(:enforced_style) { 'no_space' }

  it 'registers an offense and corrects block argument ' \
    'with space before comma' do
    expect_offense(<<~RUBY)
      each { |s , t| }
               ^ Space found before comma.
    RUBY

    expect_correction(<<~RUBY)
      each { |s, t| }
    RUBY
  end

  it 'registers an offense and corrects array index with space before comma' do
    expect_offense(<<~RUBY)
      formats[0 , 1]
               ^ Space found before comma.
    RUBY

    expect_correction(<<~RUBY)
      formats[0, 1]
    RUBY
  end

  it 'registers an offense and corrects method call arg ' \
    'with space before comma' do
    expect_offense(<<~RUBY)
      a(1 , 2)
         ^ Space found before comma.
    RUBY

    expect_correction(<<~RUBY)
      a(1, 2)
    RUBY
  end

  it 'does not register an offense for no spaces before comma' do
    expect_no_offenses('a(1, 2)')
  end

  context 'when EnforcedStyle is no_space' do
    let(:enforced_style) { 'no_space' }

    it 'registers an offense for a space after a colon' do
      expect_offense(<<~RUBY)
        def a(foo: , bar: nil); end
                  ^ Space found before comma.
      RUBY

      expect_correction(<<~RUBY)
        def a(foo:, bar: nil); end
      RUBY
    end

    it 'does not register an offense for no space after a colon' do
      expect_no_offenses('def a(foo:, bar: nil); end')
    end
  end

  context 'when EnforcedStyle is space_after_colon' do
    let(:enforced_style) { 'space_after_colon' }

    it 'registers an offense for no space after a colon' do
      expect_offense(<<~RUBY)
        def a(foo:, bar: nil); end
                 ^ No space found after colon.
      RUBY

      expect_correction(<<~RUBY)
        def a(foo: , bar: nil); end
      RUBY
    end

    it 'registers an offense for a space after a keyword arg with a value' do
      expect_offense(<<~RUBY)
        def a(foo: nil , bar: nil); end
                      ^ Space found before comma.
        a(foo: 1 , b: 2)
                ^ Space found before comma.
      RUBY

      expect_correction(<<~RUBY)
        def a(foo: nil, bar: nil); end
        a(foo: 1, b: 2)
      RUBY
    end

    it 'does not register an offense for a space after a colon' do
      expect_no_offenses('def a(foo: , bar: nil); end')
    end

    it 'does not register an offense for a newline after a colon' do
      expect_no_offenses(<<~RUBY)
        def a(foo:
          , bar: nil)
        end
      RUBY
    end
  end

  it 'handles more than one space before a comma' do
    expect_offense(<<~RUBY)
      each { |s  , t| a(1  , formats[0  , 1])}
                                      ^^ Space found before comma.
                         ^^ Space found before comma.
               ^^ Space found before comma.
    RUBY

    expect_correction(<<~RUBY)
      each { |s, t| a(1, formats[0, 1])}
    RUBY
  end
end
