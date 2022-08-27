# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Security::Open, :config do
  it 'registers an offense for open' do
    expect_offense(<<~RUBY)
      open(something)
      ^^^^ The use of `Kernel#open` is a serious security risk.
    RUBY
  end

  it 'registers an offense for open with mode argument' do
    expect_offense(<<~RUBY)
      open(something, "r")
      ^^^^ The use of `Kernel#open` is a serious security risk.
    RUBY
  end

  it 'registers an offense for open with dynamic string that is not prefixed' do
    expect_offense(<<~'RUBY')
      open("#{foo}.txt")
      ^^^^ The use of `Kernel#open` is a serious security risk.
    RUBY
  end

  it 'registers an offense for open with string that starts with a pipe' do
    expect_offense(<<~'RUBY')
      open("| #{foo}")
      ^^^^ The use of `Kernel#open` is a serious security risk.
    RUBY
  end

  it 'registers an offense for open with a block' do
    expect_offense(<<~'RUBY')
      open("#{foo}.txt") do |f|
      ^^^^ The use of `Kernel#open` is a serious security risk.
        f.gets
      end
    RUBY
  end

  it 'registers an offense for `URI.open` with string that starts with a pipe' do
    expect_offense(<<~'RUBY')
      URI.open("| #{foo}")
          ^^^^ The use of `URI.open` is a serious security risk.
    RUBY
  end

  it 'registers an offense for `::URI.open` with string that starts with a pipe' do
    expect_offense(<<~'RUBY')
      ::URI.open("| #{foo}")
            ^^^^ The use of `::URI.open` is a serious security risk.
    RUBY
  end

  it 'registers an offense for `URI.open` with a block' do
    expect_offense(<<~'RUBY')
      ::URI.open("| #{foo}") do |f|
            ^^^^ The use of `::URI.open` is a serious security risk.
        f.gets
      end
    RUBY
  end

  it 'accepts open as variable' do
    expect_no_offenses('open = something')
  end

  it 'accepts File.open as method' do
    expect_no_offenses('File.open(something)')
  end

  it 'accepts open on a literal string' do
    expect_no_offenses('open("foo.txt")')
  end

  it 'accepts open with no arguments' do
    expect_no_offenses('open')
  end

  it 'accepts open with string that has a prefixed interpolation' do
    expect_no_offenses('open "prefix_#{foo}"')
  end

  it 'accepts open with prefix string literal plus something' do
    expect_no_offenses('open "prefix" + foo')
  end

  it 'accepts open with a string that interpolates a literal' do
    expect_no_offenses('open "foo#{2}.txt"')
  end

  it 'accepts open with a literal string starting with a pipe' do
    expect_no_offenses('open "| foo"')
  end
end
