# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::RegexpAsCondition, :config do
  it 'registers an offense and corrects for a regexp literal in `if` condition' do
    expect_offense(<<~RUBY)
      if /foo/
         ^^^^^ Do not use regexp literal as a condition. The regexp literal matches `$_` implicitly.
      end
    RUBY

    expect_correction(<<~RUBY)
      if /foo/ =~ $_
      end
    RUBY
  end

  it 'registers an offense and corrects for a regexp literal with bang in `if` condition' do
    expect_offense(<<~RUBY)
      if !/foo/
          ^^^^^ Do not use regexp literal as a condition. The regexp literal matches `$_` implicitly.
      end
    RUBY

    expect_correction(<<~RUBY)
      if !(/foo/ =~ $_)
      end
    RUBY
  end

  it 'registers an offense and corrects for a regexp literal in a `while` condition' do
    expect_offense(<<~RUBY)
      while /foo/
            ^^^^^ Do not use regexp literal as a condition. The regexp literal matches `$_` implicitly.
        bar
      end
    RUBY

    expect_correction(<<~RUBY)
      while /foo/ =~ $_
        bar
      end
    RUBY
  end

  it 'registers an offense and corrects for a regexp literal in an `until` condition' do
    expect_offense(<<~RUBY)
      until /foo/
            ^^^^^ Do not use regexp literal as a condition. The regexp literal matches `$_` implicitly.
        bar
      end
    RUBY

    expect_correction(<<~RUBY)
      until /foo/ =~ $_
        bar
      end
    RUBY
  end

  it 'registers an offense and corrects for a regexp literal in a ternary condition' do
    expect_offense(<<~RUBY)
      /foo/ ? a : b
      ^^^^^ Do not use regexp literal as a condition. The regexp literal matches `$_` implicitly.
    RUBY

    expect_correction(<<~RUBY)
      /foo/ =~ $_ ? a : b
    RUBY
  end

  it 'does not register an offense for a regexp literal outside conditions' do
    expect_no_offenses(<<~RUBY)
      /foo/
    RUBY
  end

  it 'does not register an offense for a regexp literal with bang outside conditions' do
    expect_no_offenses(<<~RUBY)
      !/foo/
    RUBY
  end

  it 'does not register an offense for a regexp literal with `=~` operator' do
    expect_no_offenses(<<~RUBY)
      if /foo/ =~ str
      end
    RUBY
  end
end
