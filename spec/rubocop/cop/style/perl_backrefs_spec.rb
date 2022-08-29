# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::PerlBackrefs, :config do
  it 'autocorrects puts $1 to puts Regexp.last_match(1)' do
    expect_offense(<<~RUBY)
      puts $1
           ^^ Prefer `Regexp.last_match(1)` over `$1`.
    RUBY

    expect_correction(<<~RUBY)
      puts Regexp.last_match(1)
    RUBY
  end

  it 'autocorrects $9 to Regexp.last_match(9)' do
    expect_offense(<<~RUBY)
      $9
      ^^ Prefer `Regexp.last_match(9)` over `$9`.
    RUBY

    expect_correction(<<~RUBY)
      Regexp.last_match(9)
    RUBY
  end

  it 'autocorrects $& to Regexp.last_match(0)' do
    expect_offense(<<~RUBY)
      $&
      ^^ Prefer `Regexp.last_match(0)` over `$&`.
    RUBY

    expect_correction(<<~RUBY)
      Regexp.last_match(0)
    RUBY
  end

  it 'autocorrects $` to Regexp.last_match.pre_match' do
    expect_offense(<<~RUBY)
      $`
      ^^ Prefer `Regexp.last_match.pre_match` over `$``.
    RUBY

    expect_correction(<<~RUBY)
      Regexp.last_match.pre_match
    RUBY
  end

  it 'autocorrects $\' to Regexp.last_match.post_match' do
    expect_offense(<<~RUBY)
      $'
      ^^ Prefer `Regexp.last_match.post_match` over `$'`.
    RUBY

    expect_correction(<<~RUBY)
      Regexp.last_match.post_match
    RUBY
  end

  it 'autocorrects $+ to Regexp.last_match(-1)' do
    expect_offense(<<~RUBY)
      $+
      ^^ Prefer `Regexp.last_match(-1)` over `$+`.
    RUBY

    expect_correction(<<~RUBY)
      Regexp.last_match(-1)
    RUBY
  end

  it 'autocorrects $MATCH to Regexp.last_match(0)' do
    expect_offense(<<~RUBY)
      $MATCH
      ^^^^^^ Prefer `Regexp.last_match(0)` over `$MATCH`.
    RUBY

    expect_correction(<<~RUBY)
      Regexp.last_match(0)
    RUBY
  end

  it 'autocorrects $PREMATCH to Regexp.last_match.pre_match' do
    expect_offense(<<~RUBY)
      $PREMATCH
      ^^^^^^^^^ Prefer `Regexp.last_match.pre_match` over `$PREMATCH`.
    RUBY

    expect_correction(<<~RUBY)
      Regexp.last_match.pre_match
    RUBY
  end

  it 'autocorrects $POSTMATCH to Regexp.last_match.post_match' do
    expect_offense(<<~RUBY)
      $POSTMATCH
      ^^^^^^^^^^ Prefer `Regexp.last_match.post_match` over `$POSTMATCH`.
    RUBY

    expect_correction(<<~RUBY)
      Regexp.last_match.post_match
    RUBY
  end

  it 'autocorrects $LAST_PAREN_MATCH to Regexp.last_match(-1)' do
    expect_offense(<<~RUBY)
      $LAST_PAREN_MATCH
      ^^^^^^^^^^^^^^^^^ Prefer `Regexp.last_match(-1)` over `$LAST_PAREN_MATCH`.
    RUBY

    expect_correction(<<~RUBY)
      Regexp.last_match(-1)
    RUBY
  end

  it 'autocorrects "#$1" to "#{Regexp.last_match(1)}"' do
    expect_offense(<<~'RUBY')
      "#$1"
        ^^ Prefer `Regexp.last_match(1)` over `$1`.
    RUBY

    expect_correction(<<~'RUBY')
      "#{Regexp.last_match(1)}"
    RUBY
  end

  it 'autocorrects `#$1` to `#{Regexp.last_match(1)}`' do
    expect_offense(<<~'RUBY')
      `#$1`
        ^^ Prefer `Regexp.last_match(1)` over `$1`.
    RUBY

    expect_correction(<<~'RUBY')
      `#{Regexp.last_match(1)}`
    RUBY
  end

  it 'autocorrects /#$1/ to /#{Regexp.last_match(1)}/' do
    expect_offense(<<~'RUBY')
      /#$1/
        ^^ Prefer `Regexp.last_match(1)` over `$1`.
    RUBY

    expect_correction(<<~'RUBY')
      /#{Regexp.last_match(1)}/
    RUBY
  end

  it 'autocorrects $1 to ::Regexp.last_match(1) in namespace' do
    expect_offense(<<~RUBY)
      module Foo
        class Regexp
        end

        puts $1
             ^^ Prefer `::Regexp.last_match(1)` over `$1`.
      end
    RUBY

    expect_correction(<<~RUBY)
      module Foo
        class Regexp
        end

        puts ::Regexp.last_match(1)
      end
    RUBY
  end
end
