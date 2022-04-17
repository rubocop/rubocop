# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::CharacterLiteral, :config do
  it 'registers an offense for character literals' do
    expect_offense(<<~RUBY)
      x = ?x
          ^^ Do not use the character literal - use string literal instead.
    RUBY

    expect_correction(<<~RUBY)
      x = 'x'
    RUBY
  end

  it 'registers an offense for literals like \n' do
    expect_offense(<<~'RUBY')
      x = ?\n
          ^^^ Do not use the character literal - use string literal instead.
    RUBY

    expect_correction(<<~'RUBY')
      x = "\n"
    RUBY
  end

  it 'accepts literals like ?\C-\M-d' do
    expect_no_offenses('x = ?\C-\M-d')
  end

  it 'accepts ? in a %w literal' do
    expect_no_offenses('%w{? A}')
  end

  it 'autocorrects ?\' to "\'"' do
    expect_offense(<<~RUBY)
      x = ?'
          ^^ Do not use the character literal - use string literal instead.
    RUBY

    expect_correction(<<~RUBY)
      x = "'"
    RUBY
  end
end
