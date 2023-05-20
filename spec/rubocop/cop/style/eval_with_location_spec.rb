# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::EvalWithLocation, :config do
  it 'registers an offense when using `#eval` without any arguments' do
    expect_offense(<<~RUBY)
      eval <<-CODE
      ^^^^^^^^^^^^ Pass a binding, `__FILE__`, and `__LINE__` to `eval`.
        do_something
      CODE
    RUBY

    expect_no_corrections
  end

  it 'registers an offense when using `Kernel.eval` without any arguments' do
    expect_offense(<<~RUBY)
      Kernel.eval <<-CODE
      ^^^^^^^^^^^^^^^^^^^ Pass a binding, `__FILE__`, and `__LINE__` to `eval`.
        do_something
      CODE
    RUBY

    expect_no_corrections
  end

  it 'registers an offense when using `::Kernel.eval` without any arguments' do
    expect_offense(<<~RUBY)
      ::Kernel.eval <<-CODE
      ^^^^^^^^^^^^^^^^^^^^^ Pass a binding, `__FILE__`, and `__LINE__` to `eval`.
        do_something
      CODE
    RUBY

    expect_no_corrections
  end

  it 'does not register an offense if `eval` is called on another object' do
    expect_no_offenses(<<~RUBY)
      foo.eval "CODE"
    RUBY
  end

  it 'registers an offense when using `#eval` with `binding` only' do
    expect_offense(<<~RUBY)
      eval <<-CODE, binding
      ^^^^^^^^^^^^^^^^^^^^^ Pass a binding, `__FILE__`, and `__LINE__` to `eval`.
        do_something
      CODE
    RUBY

    expect_correction(<<~RUBY)
      eval <<-CODE, binding, __FILE__, __LINE__ + 1
        do_something
      CODE
    RUBY
  end

  it 'registers an offense when using `#eval` without lineno' do
    expect_offense(<<~RUBY)
      eval <<-CODE, binding, __FILE__
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Pass a binding, `__FILE__`, and `__LINE__` to `eval`.
        do_something
      CODE
    RUBY

    expect_correction(<<~RUBY)
      eval <<-CODE, binding, __FILE__, __LINE__ + 1
        do_something
      CODE
    RUBY
  end

  it 'registers an offense when using `#eval` without lineno and with parenthesized method call' do
    expect_offense(<<~RUBY)
      eval(<<-CODE, binding, __FILE__)
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Pass a binding, `__FILE__`, and `__LINE__` to `eval`.
        do_something
      CODE
    RUBY

    expect_correction(<<~RUBY)
      eval(<<-CODE, binding, __FILE__, __LINE__ + 1)
        do_something
      CODE
    RUBY
  end

  it 'registers an offense when using `#eval` with an incorrect line number' do
    expect_offense(<<~RUBY)
      eval 'do_something', binding, __FILE__, __LINE__ + 1
                                              ^^^^^^^^^^^^ Incorrect line number for `eval`; use `__LINE__` instead of `__LINE__ + 1`.
    RUBY

    expect_correction(<<~RUBY)
      eval 'do_something', binding, __FILE__, __LINE__
    RUBY
  end

  it 'registers an offense when using `#eval` with a heredoc and an incorrect line number' do
    expect_offense(<<~RUBY)
      eval <<-CODE, binding, __FILE__, __LINE__ + 2
                                       ^^^^^^^^^^^^ Incorrect line number for `eval`; use `__LINE__ + 1` instead of `__LINE__ + 2`.
        do_something
      CODE
    RUBY

    expect_correction(<<~RUBY)
      eval <<-CODE, binding, __FILE__, __LINE__ + 1
        do_something
      CODE
    RUBY
  end

  it 'registers an offense when using `#eval` with a string on a new line' do
    expect_offense(<<~RUBY)
      eval('puts 42',
           binding,
           __FILE__,
           __LINE__)
           ^^^^^^^^ Incorrect line number for `eval`; use `__LINE__ - 3` instead of `__LINE__`.
    RUBY

    expect_correction(<<~RUBY)
      eval('puts 42',
           binding,
           __FILE__,
           __LINE__ - 3)
    RUBY
  end

  it 'registers an offense when using `#class_eval` without any arguments' do
    expect_offense(<<~RUBY)
      C.class_eval <<-CODE
      ^^^^^^^^^^^^^^^^^^^^ Pass `__FILE__` and `__LINE__` to `class_eval`.
        do_something
      CODE
    RUBY

    expect_correction(<<~RUBY)
      C.class_eval <<-CODE, __FILE__, __LINE__ + 1
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

    expect_correction(<<~RUBY)
      M.module_eval <<-CODE, __FILE__, __LINE__ + 1
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

    expect_correction(<<~RUBY)
      foo.instance_eval <<-CODE, __FILE__, __LINE__ + 1
        do_something
      CODE
    RUBY
  end

  it 'registers an offense when using `#instance_eval` with a string argument in parentheses' do
    expect_offense(<<~RUBY)
      instance_eval('@foo = foo')
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Pass `__FILE__` and `__LINE__` to `instance_eval`.
    RUBY

    expect_correction(<<~RUBY)
      instance_eval('@foo = foo', __FILE__, __LINE__)
    RUBY
  end

  it 'registers an offense when using `#class_eval` with an incorrect lineno' do
    expect_offense(<<~RUBY)
      C.class_eval <<-CODE, __FILE__, __LINE__
                                      ^^^^^^^^ Incorrect line number for `class_eval`; use `__LINE__ + 1` instead of `__LINE__`.
        do_something
      CODE
    RUBY

    expect_correction(<<~RUBY)
      C.class_eval <<-CODE, __FILE__, __LINE__ + 1
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

  it 'registers an offense when using `eval` with improper arguments' do
    expect_offense(<<~RUBY)
      eval <<-CODE, binding, 'foo', 'bar'
                                    ^^^^^ Incorrect line number for `eval`; use `__LINE__ + 1` instead of `'bar'`.
                             ^^^^^ Incorrect file for `eval`; use `__FILE__` instead of `'foo'`.
        do_something
      CODE
    RUBY

    expect_correction(<<~RUBY)
      eval <<-CODE, binding, __FILE__, __LINE__ + 1
        do_something
      CODE
    RUBY
  end

  it 'registers an offense when using `instance_eval` with improper arguments' do
    expect_offense(<<~RUBY)
      instance_eval <<-CODE, 'foo', 'bar'
                                    ^^^^^ Incorrect line number for `instance_eval`; use `__LINE__ + 1` instead of `'bar'`.
                             ^^^^^ Incorrect file for `instance_eval`; use `__FILE__` instead of `'foo'`.
        do_something
      CODE
    RUBY

    expect_correction(<<~RUBY)
      instance_eval <<-CODE, __FILE__, __LINE__ + 1
        do_something
      CODE
    RUBY
  end

  it 'registers an offense when using `class_eval` with improper arguments' do
    expect_offense(<<~RUBY)
      class_eval <<-CODE, 'foo', 'bar'
                                 ^^^^^ Incorrect line number for `class_eval`; use `__LINE__ + 1` instead of `'bar'`.
                          ^^^^^ Incorrect file for `class_eval`; use `__FILE__` instead of `'foo'`.
        do_something
      CODE
    RUBY

    expect_correction(<<~RUBY)
      class_eval <<-CODE, __FILE__, __LINE__ + 1
        do_something
      CODE
    RUBY
  end

  it 'registers an offense when using `module_eval` with improper arguments' do
    expect_offense(<<~RUBY)
      module_eval <<-CODE, 'foo', 'bar'
                                  ^^^^^ Incorrect line number for `module_eval`; use `__LINE__ + 1` instead of `'bar'`.
                           ^^^^^ Incorrect file for `module_eval`; use `__FILE__` instead of `'foo'`.
        do_something
      CODE
    RUBY

    expect_correction(<<~RUBY)
      module_eval <<-CODE, __FILE__, __LINE__ + 1
        do_something
      CODE
    RUBY
  end

  it 'registers an offense when using correct file argument but incorrect line' do
    expect_offense(<<~RUBY)
      module_eval <<-CODE, __FILE__, 'bar'
                                     ^^^^^ Incorrect line number for `module_eval`; use `__LINE__ + 1` instead of `'bar'`.
        do_something
      CODE
    RUBY

    expect_correction(<<~RUBY)
      module_eval <<-CODE, __FILE__, __LINE__ + 1
        do_something
      CODE
    RUBY
  end

  it 'does not register an offense when using eval with block argument' do
    expect_no_offenses(<<~RUBY)
      def self.included(base)
        base.class_eval do
          include OtherModule
        end
      end
    RUBY
  end
end
