# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Naming::MethodParameterName, :config do
  let(:cop_config) { { 'MinNameLength' => 3, 'AllowNamesEndingInNumbers' => false } }

  context 'when using argument forwarding', :ruby27 do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        def foo(...); end
      RUBY
    end
  end

  it 'does not register for method without parameters' do
    expect_no_offenses(<<~RUBY)
      def something
        do_stuff
      end
    RUBY
  end

  it 'does not register offense for valid parameter names' do
    expect_no_offenses(<<~RUBY)
      def something(foo, bar)
        do_stuff
      end
    RUBY
  end

  it 'does not register offense for valid parameter names on self.method' do
    expect_no_offenses(<<~RUBY)
      def self.something(foo, bar)
        do_stuff
      end
    RUBY
  end

  it 'does not register offense for valid default parameters' do
    expect_no_offenses(<<~RUBY)
      def self.something(foo = Pwd.dir, bar = 1)
        do_stuff
      end
    RUBY
  end

  it 'does not register offense for valid keyword parameters' do
    expect_no_offenses(<<~RUBY)
      def self.something(foo: Pwd.dir, bar: 1)
        do_stuff
      end
    RUBY
  end

  it 'does not register offense for empty restarg' do
    expect_no_offenses(<<~RUBY)
      def qux(*)
        stuff!
      end
    RUBY
  end

  it 'does not register offense for empty kwrestarg' do
    expect_no_offenses(<<~RUBY)
      def qux(**)
        stuff!
      end
    RUBY
  end

  it 'registers offense when parameter ends in number' do
    expect_offense(<<~RUBY)
      def something(foo1, bar)
                    ^^^^ Do not end method parameter with a number.
        do_stuff
       end
    RUBY
  end

  it 'registers offense when parameter ends in number on class method' do
    expect_offense(<<~RUBY)
      def self.something(foo, bar1)
                              ^^^^ Do not end method parameter with a number.
        do_stuff
       end
    RUBY
  end

  it 'registers offense when parameter is less than minimum length' do
    expect_offense(<<~RUBY)
      def something(ab)
                    ^^ Method parameter must be at least 3 characters long.
        do_stuff
      end
    RUBY
  end

  it 'registers offense when parameter with prefix is less than minimum length' do
    expect_offense(<<~RUBY)
      def something(_a, __b, *c, **__d)
                    ^^ Method parameter must be at least 3 characters long.
                        ^^^ Method parameter must be at least 3 characters long.
                             ^^ Method parameter must be at least 3 characters long.
                                 ^^^^^ Method parameter must be at least 3 characters long.
        do_stuff
      end
    RUBY
  end

  it 'registers offense when parameter contains uppercase characters' do
    expect_offense(<<~RUBY)
      def something(number_One)
                    ^^^^^^^^^^ Only use lowercase characters for method parameter.
        do_stuff
      end
    RUBY
  end

  it 'registers offense for offensive default parameter' do
    expect_offense(<<~RUBY)
      def self.something(foo1 = Pwd.dir)
                         ^^^^ Do not end method parameter with a number.
        do_stuff
      end
    RUBY
  end

  it 'registers offense for offensive keyword parameters' do
    expect_offense(<<~RUBY)
      def something(fooBar:)
                    ^^^^^^ Only use lowercase characters for method parameter.
        do_stuff
      end
    RUBY
  end

  it 'can register multiple offenses in one method definition' do
    expect_offense(<<~RUBY)
      def self.something(y, num1, oFo)
                         ^ Method parameter must be at least 3 characters long.
                            ^^^^ Do not end method parameter with a number.
                                  ^^^ Only use lowercase characters for method parameter.
        do_stuff
      end
    RUBY
  end

  context 'with AllowedNames' do
    let(:cop_config) do
      {
        'AllowedNames' => %w[foo1 foo2],
        'AllowNamesEndingInNumbers' => false
      }
    end

    it 'accepts specified block param names' do
      expect_no_offenses(<<~RUBY)
        def quux(foo1, foo2)
          do_stuff
        end
      RUBY
    end

    it 'accepts param names prefixed with underscore' do
      expect_no_offenses(<<~RUBY)
        def quux(_foo1, _foo2)
          do_stuff
        end
      RUBY
    end

    it 'accepts underscore param names' do
      expect_no_offenses(<<~RUBY)
        def quux(_)
          do_stuff
        end
      RUBY
    end

    it 'registers unlisted offensive names' do
      expect_offense(<<~RUBY)
        def quux(bar, bar1)
                      ^^^^ Do not end method parameter with a number.
          do_stuff
        end
      RUBY
    end
  end

  context 'with ForbiddenNames' do
    let(:cop_config) { { 'ForbiddenNames' => %w[arg] } }

    it 'registers offense for parameter listed as forbidden' do
      expect_offense(<<~RUBY)
        def baz(arg)
                ^^^ Do not use arg as a name for a method parameter.
          arg.do_things
        end
      RUBY
    end

    it "accepts parameter that uses a forbidden name's letters" do
      expect_no_offenses(<<~RUBY)
        def baz(foo_parameter)
          foo_parameter.do_things
        end
      RUBY
    end
  end

  context 'with AllowNamesEndingInNumbers' do
    let(:cop_config) { { 'AllowNamesEndingInNumbers' => true } }

    it 'accept parameters that end in numbers' do
      expect_no_offenses(<<~RUBY)
        def something(foo1, bar2, qux3)
          do_stuff
        end
      RUBY
    end
  end
end
