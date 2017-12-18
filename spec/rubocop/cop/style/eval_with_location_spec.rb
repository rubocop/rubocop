# frozen_string_literal: true

describe RuboCop::Cop::Style::EvalWithLocation do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  it 'registers an offense when using `#eval` without any arguments' do
    expect_offense(<<-RUBY.strip_indent)
      eval <<-CODE
      ^^^^^^^^^^^^ Pass `__FILE__` and `__LINE__` to `eval` method, as they are used by backtraces.
        do_something
      CODE
    RUBY
  end

  it 'registers an offense when using `#eval` with `binding` only' do
    expect_offense(<<-RUBY.strip_indent)
      eval <<-CODE, binding
      ^^^^^^^^^^^^^^^^^^^^^ Pass `__FILE__` and `__LINE__` to `eval` method, as they are used by backtraces.
        do_something
      CODE
    RUBY
  end

  it 'registers an offense when using `#eval` without lineno' do
    expect_offense(<<-RUBY.strip_indent)
      eval <<-CODE, binding, __FILE__
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Pass `__FILE__` and `__LINE__` to `eval` method, as they are used by backtraces.
        do_something
      CODE
    RUBY
  end

  it 'registers an offense when using `#eval` with an incorrect line number' do
    expect_offense(<<-RUBY.strip_indent)
      eval 'do_something', binding, __FILE__, __LINE__ + 1
                                              ^^^^^^^^^^^^ Use `__LINE__` instead of `__LINE__ + 1`, as they are used by backtraces.
    RUBY
  end

  it 'registers an offense when using `#eval` with a heredoc and ' \
     'an incorrect line number' do
    expect_offense(<<-RUBY.strip_indent)
      eval <<-CODE, binding, __FILE__, __LINE__ + 2
                                       ^^^^^^^^^^^^ Use `__LINE__ + 1` instead of `__LINE__ + 2`, as they are used by backtraces.
        do_something
      CODE
    RUBY
  end

  it 'registers an offense when using `#eval` with a string on a new line ' do
    expect_offense(<<-RUBY.strip_indent)
      eval('puts 42',
           binding,
           __FILE__,
           __LINE__)
           ^^^^^^^^ Use `__LINE__ - 3` instead of `__LINE__`, as they are used by backtraces.
    RUBY
  end

  it 'registers an offense when using `#class_eval` without any arguments' do
    expect_offense(<<-RUBY.strip_indent)
      C.class_eval <<-CODE
      ^^^^^^^^^^^^^^^^^^^^ Pass `__FILE__` and `__LINE__` to `eval` method, as they are used by backtraces.
        do_something
      CODE
    RUBY
  end

  it 'registers an offense when using `#module_eval` without any arguments' do
    expect_offense(<<-RUBY.strip_indent)
      M.module_eval <<-CODE
      ^^^^^^^^^^^^^^^^^^^^^ Pass `__FILE__` and `__LINE__` to `eval` method, as they are used by backtraces.
        do_something
      CODE
    RUBY
  end

  it 'registers an offense when using `#instance_eval` without any arguments' do
    expect_offense(<<-RUBY.strip_indent)
      foo.instance_eval <<-CODE
      ^^^^^^^^^^^^^^^^^^^^^^^^^ Pass `__FILE__` and `__LINE__` to `eval` method, as they are used by backtraces.
        do_something
      CODE
    RUBY
  end

  it 'registers an offense when using `#class_eval` with an incorrect lineno' do
    expect_offense(<<-RUBY.strip_indent)
      C.class_eval <<-CODE, __FILE__, __LINE__
                                      ^^^^^^^^ Use `__LINE__ + 1` instead of `__LINE__`, as they are used by backtraces.
        do_something
      CODE
    RUBY
  end

  it 'accepts `eval` with a heredoc, a filename and `__LINE__ + 1`' do
    expect_no_offenses(<<-RUBY.strip_indent)
      eval <<-CODE, binding, __FILE__, __LINE__ + 1
        do_something
      CODE
    RUBY
  end

  it 'accepts `eval` with a code that is a variable' do
    expect_no_offenses(<<-RUBY.strip_indent)
      code = something
      eval code
    RUBY
  end

  it 'accepts `eval` with a string, a filename and `__LINE__`' do
    expect_no_offenses(<<-RUBY.strip_indent)
      eval 'do_something', binding, __FILE__, __LINE__
    RUBY
  end

  it 'accepts `eval` with a string, a filename and `__LINE__` on a new line' do
    expect_no_offenses(<<-RUBY.strip_indent)
      eval 'do_something', binding, __FILE__,
           __LINE__ - 1
    RUBY
  end
end
