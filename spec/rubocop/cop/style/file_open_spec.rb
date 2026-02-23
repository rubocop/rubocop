# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::FileOpen, :config do
  it 'registers an offense when using `File.open` without a block' do
    expect_offense(<<~RUBY)
      File.open('file')
      ^^^^^^^^^^^^^^^^^ `File.open` without a block may leak a file descriptor; use the block form.
    RUBY
  end

  it 'registers an offense when assigning `File.open` to a variable' do
    expect_offense(<<~RUBY)
      f = File.open('file')
          ^^^^^^^^^^^^^^^^^ `File.open` without a block may leak a file descriptor; use the block form.
    RUBY
  end

  it 'registers an offense when using `::File.open` without a block' do
    expect_offense(<<~RUBY)
      ::File.open('file')
      ^^^^^^^^^^^^^^^^^^^ `File.open` without a block may leak a file descriptor; use the block form.
    RUBY
  end

  it 'registers an offense when chaining methods on `File.open`' do
    expect_offense(<<~RUBY)
      File.open('file').read
      ^^^^^^^^^^^^^^^^^ `File.open` without a block may leak a file descriptor; use the block form.
    RUBY
  end

  it 'registers an offense when using `File.open` with mode argument' do
    expect_offense(<<~RUBY)
      File.open('file', 'w')
      ^^^^^^^^^^^^^^^^^^^^^^ `File.open` without a block may leak a file descriptor; use the block form.
    RUBY
  end

  it 'registers an offense when passing `File.open` as an argument' do
    expect_offense(<<~RUBY)
      process(File.open('file'))
              ^^^^^^^^^^^^^^^^^ `File.open` without a block may leak a file descriptor; use the block form.
    RUBY
  end

  it 'does not register an offense when using `File.open` with a brace block' do
    expect_no_offenses(<<~RUBY)
      File.open('file') { |f| f.read }
    RUBY
  end

  it 'does not register an offense when using `File.open` with a do-end block' do
    expect_no_offenses(<<~RUBY)
      File.open('file') do |f|
        f.read
      end
    RUBY
  end

  it 'does not register an offense when using `File.open` with a block-pass' do
    expect_no_offenses(<<~RUBY)
      File.open('file', &:read)
    RUBY
  end

  it 'does not register an offense when using `File.open` with a block variable' do
    expect_no_offenses(<<~RUBY)
      File.open('file', &block)
    RUBY
  end

  it 'does not register an offense when using `File.read`' do
    expect_no_offenses(<<~RUBY)
      File.read('file')
    RUBY
  end

  it 'does not register an offense when calling `open` without a receiver' do
    expect_no_offenses(<<~RUBY)
      open('file')
    RUBY
  end

  it 'does not register an offense when calling `open` on a non-File constant' do
    expect_no_offenses(<<~RUBY)
      Foo.open('file')
    RUBY
  end

  it 'does not register an offense when calling `open` on a namespaced File' do
    expect_no_offenses(<<~RUBY)
      Foo::File.open('file')
    RUBY
  end
end
