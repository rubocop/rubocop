# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::PerlBackrefs do
  subject(:cop) { described_class.new }

  it 'registers an offense for $1' do
    expect_offense(<<~RUBY)
      puts $1
           ^^ Avoid the use of Perl-style backrefs.
    RUBY

    expect_correction(<<~RUBY)
      puts Regexp.last_match(1)
    RUBY
  end

  it 'registers an offense for $9' do
    expect_offense(<<~RUBY)
      $9
      ^^ Avoid the use of Perl-style backrefs.
    RUBY

    expect_correction(<<~RUBY)
      Regexp.last_match(9)
    RUBY
  end

  it 'auto-corrects #$1 to #{Regexp.last_match(1)}' do
    expect_offense(<<~'RUBY')
      "#$1"
        ^^ Avoid the use of Perl-style backrefs.
    RUBY

    expect_correction(<<~'RUBY')
      "#{Regexp.last_match(1)}"
    RUBY
  end
end
