# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::EvalWithLocation, :config do
  it 'registers an offense when using `#eval` without any arguments' do
    expect_offense(<<~RUBY)
      eval <<-CODE
      ^^^^^^^^^^^^ Pass a binding, `__FILE__` and `__LINE__` to `eval`.
        do_something
      CODE
    RUBY
  end

  it 'registers an offense when using `#eval` with `binding` only' do
    expect_offense(<<~RUBY)
      eval <<-CODE, binding
      ^^^^^^^^^^^^^^^^^^^^^ Pass a binding, `__FILE__` and `__LINE__` to `eval`.
        do_something
      CODE
    RUBY
  end

  it 'registers an offense when using `#eval` without lineno' do
    expect_offense(<<~RUBY)
      eval <<-CODE, binding, __FILE__
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Pass a binding, `__FILE__` and `__LINE__` to `eval`.
        do_something
      CODE
    RUBY
  end

  it 'registers an offense when using `#eval` with an incorrect line number' do
    expect_offense(<<~RUBY)
      eval 'do_something', binding, __FILE__, __LINE__ + 1
                                              ^^^^^^^^^^^^ Incorrect line number for `eval`; use `__LINE__` instead of `__LINE__ + 1`.
    RUBY
  end

  it 'registers an offense when using `#eval` with a heredoc and ' \
     'an incorrect line number' do
    expect_offense(<<~RUBY)
      eval <<-CODE, binding, __FILE__, __LINE__ + 2
                                       ^^^^^^^^^^^^ Incorrect line number for `eval`; use `__LINE__ + 1` instead of `__LINE__ + 2`.
        do_something
      CODE
    RUBY
  end

  it 'registers an offense when using `#eval` with a string on a new line ' do
    expect_offense(<<~RUBY)
      eval('puts 42',
           binding,
           __FILE__,
           __LINE__)
           ^^^^^^^^ Incorrect line number for `eval`; use `__LINE__ - 3` instead of `__LINE__`.
    RUBY
  end

  it 'registers an offense when using `#class_eval` without any arguments' do
    expect_offense(<<~RUBY)
      C.class_eval <<-CODE
      ^^^^^^^^^^^^^^^^^^^^ Pass `__FILE__` and `__LINE__` to `class_eval`.
        do_something
      CODE
    RUBY
  end

  it 'registers an offense when using `#module_eval` without any arguments' do
    expect_offense(<<~RUBY)
      M.module_eval <<-CODE
      ^^^^^^^^^^^^^^^^^^^^^ Pass `__FILE__` and `__LINE__` to `module_eval`.
        do_something
      CODE
    RUBY
  end

  it 'registers an offense when using `#instance_eval` without any arguments' do
    expect_offense(<<~RUBY)
      foo.instance_eval <<-CODE
      ^^^^^^^^^^^^^^^^^^^^^^^^^ Pass `__FILE__` and `__LINE__` to `instance_eval`.
        do_something
      CODE
    RUBY
  end

  it 'registers an offense when using `#class_eval` with an incorrect lineno' do
    expect_offense(<<~RUBY)
      C.class_eval <<-CODE, __FILE__, __LINE__
                                      ^^^^^^^^ Incorrect line number for `class_eval`; use `__LINE__ + 1` instead of `__LINE__`.
        do_something
      CODE
    RUBY
  end

  it 'accepts `eval` with a heredoc, a filename and `__LINE__ + 1`' do
    expect_no_offenses(<<~RUBY)
      eval <<-CODE, binding, __FILE__, __LINE__ + 1
        do_something
      CODE
    RUBY
  end

  it 'accepts `eval` with a code that is a variable' do
    expect_no_offenses(<<~RUBY)
      code = something
      eval code
    RUBY
  end

  it 'accepts `eval` with a string, a filename and `__LINE__`' do
    expect_no_offenses(<<~RUBY)
      eval 'do_something', binding, __FILE__, __LINE__
    RUBY
  end

  it 'accepts `eval` with a string, a filename and `__LINE__` on a new line' do
    expect_no_offenses(<<~RUBY)
      eval 'do_something', binding, __FILE__,
           __LINE__ - 1
    RUBY
  end
end
