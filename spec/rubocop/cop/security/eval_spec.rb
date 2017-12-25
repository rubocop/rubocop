# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Security::Eval do
  subject(:cop) { described_class.new }

  it 'registers an offense for eval as function' do
    expect_offense(<<-RUBY.strip_indent)
      eval(something)
      ^^^^ The use of `eval` is a serious security risk.
    RUBY
  end

  it 'registers an offense for eval as command' do
    expect_offense(<<-RUBY.strip_indent)
      eval something
      ^^^^ The use of `eval` is a serious security risk.
    RUBY
  end

  it 'registers an offense `Binding#eval`' do
    expect_offense(<<-RUBY.strip_indent)
      binding.eval something
              ^^^^ The use of `eval` is a serious security risk.
    RUBY
  end

  it 'registers an offense for eval with string that has an interpolation' do
    expect_offense(<<-'RUBY'.strip_indent)
      eval "something#{foo}"
      ^^^^ The use of `eval` is a serious security risk.
    RUBY
  end

  it 'accepts eval as variable' do
    expect_no_offenses('eval = something')
  end

  it 'accepts eval as method' do
    expect_no_offenses('something.eval')
  end

  it 'accepts eval on a literal string' do
    expect_no_offenses('eval("puts 1")')
  end

  it 'accepts eval with no arguments' do
    expect_no_offenses('eval')
  end

  it 'accepts eval with a multiline string' do
    expect_no_offenses('eval "something\nsomething2"')
  end

  it 'accepts eval with a string that interpolates a literal' do
    expect_no_offenses('eval "something#{2}"')
  end

  context 'with an explicit binding, filename, and line number' do
    it 'registers an offense for eval as function' do
      expect_offense(<<-RUBY.strip_indent)
        eval(something, binding, "test.rb", 1)
        ^^^^ The use of `eval` is a serious security risk.
      RUBY
    end

    it 'registers an offense for eval as command' do
      expect_offense(<<-RUBY.strip_indent)
        eval something, binding, "test.rb", 1
        ^^^^ The use of `eval` is a serious security risk.
      RUBY
    end

    it 'accepts eval on a literal string' do
      expect_no_offenses('eval("puts 1", binding, "test.rb", 1)')
    end
  end
end
