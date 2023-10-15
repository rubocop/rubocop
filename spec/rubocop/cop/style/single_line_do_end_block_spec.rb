# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::SingleLineDoEndBlock, :config do
  it 'registers an offense when using single line `do`...`end`' do
    expect_offense(<<~RUBY)
      foo do bar end
      ^^^^^^^^^^^^^^ Prefer multiline `do`...`end` block.
    RUBY

    expect_correction(<<~RUBY)
      foo do
       bar#{' '}
      end
    RUBY
  end

  it 'registers an offense when using single line `do`...`end` with no body' do
    expect_offense(<<~RUBY)
      foo do end
      ^^^^^^^^^^ Prefer multiline `do`...`end` block.
    RUBY

    expect_correction(<<~RUBY)
      foo do
      #{' '}
      end
    RUBY
  end

  it 'registers an offense when using single line `do`...`end` with block argument' do
    expect_offense(<<~RUBY)
      foo do |arg| bar(arg) end
      ^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer multiline `do`...`end` block.
    RUBY

    expect_correction(<<~RUBY)
      foo do |arg|
       bar(arg)#{' '}
      end
    RUBY
  end

  it 'registers an offense when using single line `do`...`end` with numbered block argument' do
    expect_offense(<<~RUBY)
      foo do bar(_1) end
      ^^^^^^^^^^^^^^^^^^ Prefer multiline `do`...`end` block.
    RUBY

    expect_correction(<<~RUBY)
      foo do
       bar(_1)#{' '}
      end
    RUBY
  end

  it 'registers an offense when using single line `do`...`end` with heredoc body' do
    expect_offense(<<~RUBY)
      foo do <<~EOS end
      ^^^^^^^^^^^^^^^^^ Prefer multiline `do`...`end` block.
        text
      EOS
    RUBY

    expect_correction(<<~RUBY)
      foo do
       <<~EOS#{' '}
        text
      EOS
      end
    RUBY
  end

  it 'registers an offense when using single line `do`...`end` with `->` block' do
    expect_offense(<<~RUBY)
      ->(arg) do foo arg end
      ^^^^^^^^^^^^^^^^^^^^^^ Prefer multiline `do`...`end` block.
    RUBY

    expect_correction(<<~RUBY)
      ->(arg) do
       foo arg#{' '}
      end
    RUBY
  end

  it 'registers an offense when using single line `do`...`end` with `lambda` block' do
    expect_offense(<<~RUBY)
      lambda do |arg| foo(arg) end
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer multiline `do`...`end` block.
    RUBY

    expect_correction(<<~RUBY)
      lambda do |arg|
       foo(arg)#{' '}
      end
    RUBY
  end

  it 'does not register an offense when using multiline `do`...`end`' do
    expect_no_offenses(<<~RUBY)
      foo do
        bar
      end
    RUBY
  end

  it 'does not register an offense when using single line `{`...`}`' do
    expect_no_offenses(<<~RUBY)
      foo { bar }
    RUBY
  end
end
