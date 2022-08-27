# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::SpaceBeforeComma, :config do
  it 'registers an offense and corrects block argument with space before comma' do
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

  it 'registers an offense and corrects method call arg with space before comma' do
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

  context 'heredocs' do
    it 'registers an offense and corrects' do
      expect_offense(<<~RUBY)
        a(<<~STR , 2)
                ^ Space found before comma.
          text
        STR
      RUBY

      expect_correction(<<~RUBY)
        a(<<~STR, 2)
          text
        STR
      RUBY
    end
  end
end
