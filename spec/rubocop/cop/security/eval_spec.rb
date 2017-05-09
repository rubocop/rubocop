# frozen_string_literal: true

describe RuboCop::Cop::Security::Eval do
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
    inspect_source(cop, 'eval = something')
    expect(cop.offenses).to be_empty
  end

  it 'accepts eval as method' do
    inspect_source(cop, 'something.eval')
    expect(cop.offenses).to be_empty
  end

  it 'accepts eval on a literal string' do
    inspect_source(cop, 'eval("puts 1")')
    expect(cop.offenses).to be_empty
  end

  it 'accepts eval with no arguments' do
    inspect_source(cop, 'eval')
    expect(cop.offenses).to be_empty
  end

  it 'accepts eval with a multiline string' do
    inspect_source(cop, <<-END)
      eval "something
      something2"
    END
    expect(cop.offenses).to be_empty
  end

  it 'accepts eval with a string that is interpolated a literal' do
    inspect_source(cop, 'eval "something#{2}"')
    expect(cop.offenses).to be_empty
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
      inspect_source(cop, 'eval("puts 1", binding, "test.rb", 1)')
      expect(cop.offenses).to be_empty
    end
  end
end
