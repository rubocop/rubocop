# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::UnsafeGlobalVariables, :config do
  it 'registers an offense when using `$!`' do
    expect_offense(<<~RUBY)
      $!
      ^^ Do not use unsafe global variable `$!`.
    RUBY
  end

  it 'registers an offense when using `$ERROR_INFO`' do
    expect_offense(<<~RUBY)
      $ERROR_INFO
      ^^^^^^^^^^^ Do not use unsafe global variable `$ERROR_INFO`.
    RUBY
  end

  it 'registers an offense when using `$@`' do
    expect_offense(<<~RUBY)
      $@
      ^^ Do not use unsafe global variable `$@`.
    RUBY
  end

  it 'registers an offense when using `$ERROR_POSITION`' do
    expect_offense(<<~RUBY)
      $ERROR_POSITION
      ^^^^^^^^^^^^^^^ Do not use unsafe global variable `$ERROR_POSITION`.
    RUBY
  end

  it 'does not register an offense when using a safe global variable' do
    expect_no_offenses(<<~RUBY)
      $0
    RUBY
  end
end
