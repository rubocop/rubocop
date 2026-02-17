# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::ImplicitExceptionVars, :config do
  it 'registers an offense for $!' do
    expect_offense(<<~RUBY)
      begin
        do_something
      rescue
        puts $!
             ^^ Avoid implicit exception variable `$!`. Use explicit exception variable in rescue instead.
      end
    RUBY
  end

  it 'registers an offense for $@' do
    expect_offense(<<~RUBY)
      begin
        do_something
      rescue
        puts $@
             ^^ Avoid implicit backtrace variable `$@`. Use `.backtrace` in rescue instead.
      end
    RUBY
  end

  it 'registers an offense for $ERROR_INFO' do
    expect_offense(<<~RUBY)
      require 'English'
      begin
        do_something
      rescue
        puts $ERROR_INFO
             ^^^^^^^^^^^ Avoid implicit exception variable `$ERROR_INFO`. Use explicit exception variable in rescue instead.
      end
    RUBY
  end

  it 'registers an offense for $ERROR_POSITION' do
    expect_offense(<<~RUBY)
      require 'English'
      begin
        do_something
      rescue
        puts $ERROR_POSITION
             ^^^^^^^^^^^^^^^ Avoid implicit backtrace variable `$ERROR_POSITION`. Use `.backtrace` in rescue instead.
      end
    RUBY
  end

  it 'registers an offense when used in ensure block' do
    expect_offense(<<~RUBY)
      begin
        do_something
      rescue
        handle_error
      ensure
        log($!)
            ^^ Avoid implicit exception variable `$!`. Use explicit exception variable in rescue instead.
      end
    RUBY
  end

  it 'registers an offense when used outside rescue block' do
    expect_offense(<<~RUBY)
      if $!
         ^^ Avoid implicit exception variable `$!`. Use explicit exception variable in rescue instead.
        puts "error occurred"
      end
    RUBY
  end

  it 'registers an offense when used in string interpolation' do
    expect_offense(<<~RUBY)
      begin
        do_something
      rescue
        puts "Error: \#{$!}"
                       ^^ Avoid implicit exception variable `$!`. Use explicit exception variable in rescue instead.
      end
    RUBY
  end

  it 'does not register an offense for explicit exception variable' do
    expect_no_offenses(<<~RUBY)
      begin
        do_something
      rescue => e
        puts e
        puts e.backtrace
      end
    RUBY
  end

  it 'does not register an offense for named exception variable' do
    expect_no_offenses(<<~RUBY)
      begin
        do_something
      rescue StandardError => error
        puts error
        puts error.backtrace
      end
    RUBY
  end

  it 'does not register an offense for other global variables' do
    expect_no_offenses(<<~RUBY)
      puts $stdin
      puts $stdout
      puts $$
    RUBY
  end

  it 'registers an offense when assigning to $!' do
    expect_offense(<<~RUBY)
      begin
        do_something
      rescue
        $! = nil
        ^^^^^^^^ Avoid implicit exception variable `$!`. Use explicit exception variable in rescue instead.
      end
    RUBY
  end

  it 'registers an offense when assigning to $@' do
    expect_offense(<<~RUBY)
      begin
        do_something
      rescue
        $@ = []
        ^^^^^^^ Avoid implicit backtrace variable `$@`. Use `.backtrace` in rescue instead.
      end
    RUBY
  end

  it 'registers an offense when assigning to $ERROR_INFO' do
    expect_offense(<<~RUBY)
      require 'English'
      $ERROR_INFO = nil
      ^^^^^^^^^^^^^^^^^ Avoid implicit exception variable `$ERROR_INFO`. Use explicit exception variable in rescue instead.
    RUBY
  end

  it 'registers an offense when used inside defined?' do
    expect_offense(<<~RUBY)
      if defined?($!)
                  ^^ Avoid implicit exception variable `$!`. Use explicit exception variable in rescue instead.
        puts 'error present'
      end
    RUBY
  end

  it 'registers an offense when aliasing $!' do
    expect_offense(<<~RUBY)
      alias $my_error $!
                      ^^ Avoid implicit exception variable `$!`. Use explicit exception variable in rescue instead.
    RUBY
  end

  it 'registers an offense when aliasing $@' do
    expect_offense(<<~RUBY)
      alias $my_backtrace $@
                          ^^ Avoid implicit backtrace variable `$@`. Use `.backtrace` in rescue instead.
    RUBY
  end
end
