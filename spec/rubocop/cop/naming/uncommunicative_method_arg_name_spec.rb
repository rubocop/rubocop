# frozen_string_literal: true

describe RuboCop::Cop::Naming::UncommunicativeMethodArgName, :config do
  subject(:cop) { described_class.new(config) }

  let(:cop_config) { { 'MinParamNameLength' => 3 } }

  it 'does not register for method without arguments' do
    expect_no_offenses(<<-RUBY.strip_indent)
      def something
        do_stuff
      end
    RUBY
  end

  it 'does not register offense for valid argument names' do
    expect_no_offenses(<<-RUBY.strip_indent)
      def something(foo, bar)
        do_stuff
      end
    RUBY
  end

  it 'does not register offense for valid argument names on self.method' do
    expect_no_offenses(<<-RUBY.strip_indent)
      def self.something(foo, bar)
        do_stuff
      end
    RUBY
  end

  it 'does not register offense for valid default arguments' do
    expect_no_offenses(<<-RUBY.strip_indent)
      def self.something(foo = Pwd.dir, bar = 1)
        do_stuff
      end
    RUBY
  end

  it 'does not register offense for valid keyword arguments' do
    expect_no_offenses(<<-RUBY.strip_indent)
      def self.something(foo: Pwd.dir, bar: 1)
        do_stuff
      end
    RUBY
  end

  it 'registers offense when argument ends in number' do
    expect_offense(<<-RUBY.strip_indent)
      def something(foo1, bar)
                    ^^^^ Do not end method argument with a number.
        do_stuff
       end
    RUBY
  end

  it 'registers offense when argument ends in number on class method' do
    expect_offense(<<-RUBY.strip_indent)
      def self.something(foo, bar1)
                              ^^^^ Do not end method argument with a number.
        do_stuff
       end
    RUBY
  end

  it 'registers offense when argument is less than minimum length' do
    expect_offense(<<-RUBY.strip_indent)
      def something(ab)
                    ^^ Method argument must be longer than 3 characters.
        do_stuff
      end
    RUBY
  end

  it 'registers offense when argument contains uppercase characters' do
    expect_offense(<<-RUBY.strip_indent)
      def something(number_One)
                    ^^^^^^^^^^ Only use lowercase characters for method argument.
        do_stuff
      end
    RUBY
  end

  it 'registers offense for offensive default argument' do
    expect_offense(<<-RUBY.strip_indent)
      def self.something(foo1 = Pwd.dir)
                         ^^^^ Do not end method argument with a number.
        do_stuff
      end
    RUBY
  end

  it 'registers offense for offensive keyword arguments' do
    expect_offense(<<-RUBY.strip_indent)
      def something(fooBar:)
                    ^^^^^^ Only use lowercase characters for method argument.
        do_stuff
      end
    RUBY
  end

  it 'can register multiple offenses in one method definition' do
    inspect_source(<<-RUBY.strip_indent)
      def self.something(y, num1, oFo)
        do_stuff
      end
    RUBY
    expect(cop.offenses.size).to eq(3)
    expect(cop.messages).to eq [
      'Method argument must be longer than 3 characters.',
      'Do not end method argument with a number.',
      'Only use lowercase characters for method argument.'
    ]
  end
end
