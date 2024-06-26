# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::SuperArguments, :config do
  shared_examples 'offense' do |description, args, forwarded_args = args|
    it "registers and corrects an offense when using def`#{description} (#{args}) => (#{forwarded_args})`" do
      expect_offense(<<~RUBY, forwarded_args: forwarded_args)
        def method(#{args})
          super(#{forwarded_args})
          ^^^^^^^{forwarded_args}^ Call `super` without arguments and parentheses when the signature is identical.
        end
      RUBY

      expect_correction(<<~RUBY)
        def method(#{args})
          super
        end
      RUBY
    end

    it "registers and corrects an offense when using defs`#{description} (#{args}) => (#{forwarded_args})`" do
      expect_offense(<<~RUBY, forwarded_args: forwarded_args)
        def self.method(#{args})
          super(#{forwarded_args})
          ^^^^^^^{forwarded_args}^ Call `super` without arguments and parentheses when the signature is identical.
        end
      RUBY

      expect_correction(<<~RUBY)
        def self.method(#{args})
          super
        end
      RUBY
    end
  end

  shared_examples 'no offense' do |description, args, forwarded_args = args|
    it "registers no offense when using def `#{description} (#{args}) => (#{forwarded_args})`" do
      expect_no_offenses(<<~RUBY)
        def method(#{args})
          super(#{forwarded_args})
        end
      RUBY
    end

    it "registers no offense when using defs `#{description} (#{args}) => (#{forwarded_args})`" do
      expect_no_offenses(<<~RUBY)
        def self.method(#{args})
          super(#{forwarded_args})
        end
      RUBY
    end
  end

  it_behaves_like 'offense', 'no arguments', ''
  it_behaves_like 'offense', 'single positional argument', 'a'
  it_behaves_like 'offense', 'multiple positional arguments', 'a, b'
  it_behaves_like 'offense', 'multiple positional arguments with default', 'a, b, c = 1', 'a, b, c'
  it_behaves_like 'offense', 'positional/keyword argument', 'a, b:', 'a, b: b'
  it_behaves_like 'offense', 'positional/keyword argument with default', 'a, b: 1', 'a, b: b'
  it_behaves_like 'offense', 'positional/keyword argument both with default', 'a = 1, b: 2', 'a, b: b'
  it_behaves_like 'offense', 'named block argument', '&blk'
  it_behaves_like 'offense', 'positional splat arguments', '*args'
  it_behaves_like 'offense', 'keyword splat arguments', '**kwargs'
  it_behaves_like 'offense', 'positional/keyword splat arguments', '*args, **kwargs'
  it_behaves_like 'offense', 'positionalkeyword splat arguments with block', '*args, **kwargs, &blk'
  it_behaves_like 'offense', 'keyword arguments mixed with forwarding', 'a:, **kwargs', 'a: a, **kwargs'
  it_behaves_like 'offense', 'tripple dot forwarding', '...'
  it_behaves_like 'offense', 'tripple dot forwarding with extra arg', 'a, ...'

  it_behaves_like 'no offense', 'different amount of positional arguments', 'a, b', 'a'
  it_behaves_like 'no offense', 'positional arguments in different order', 'a, b', 'b, a'
  it_behaves_like 'no offense', 'keyword arguments in different order', 'a:, b:', 'b: b, a: a'
  it_behaves_like 'no offense', 'positional/keyword argument mixing', 'a, b', 'a, b: b'
  it_behaves_like 'no offense', 'positional/keyword argument mixing reversed', 'a, b:', 'a, b'
  it_behaves_like 'no offense', 'block argument with different name', '&blk', '&other_blk'
  it_behaves_like 'no offense', 'keyword arguments and hash', 'a:', '{ a: a }'
  it_behaves_like 'no offense', 'keyword arguments with send node', 'a:, b:', 'a: a, b: c'
  it_behaves_like 'no offense', 'tripple dot forwarding with extra param', '...', 'a, ...'
  it_behaves_like 'no offense', 'tripple dot forwarding with different param', 'a, ...', 'b, ...'
  it_behaves_like 'no offense', 'keyword forwarding with extra keyword', 'a, **kwargs', 'a: a, **kwargs'

  context 'Ruby >= 3.1', :ruby31 do
    it_behaves_like 'offense', 'hash value omission', 'a:'
    it_behaves_like 'offense', 'anonymous block forwarding', '&'
  end

  context 'Ruby >= 3.2', :ruby32 do
    it_behaves_like 'offense', 'anonymous positional forwarding', '*'
    it_behaves_like 'offense', 'anonymous keyword forwarding', '**'

    it_behaves_like 'no offense', 'mixed anonymous forwarding', '*, **', '*'
    it_behaves_like 'no offense', 'mixed anonymous forwarding', '*, **', '**'
  end

  it 'registers no offense when explicitly passing no arguments' do
    expect_no_offenses(<<~RUBY)
      def foo(a)
        super()
      end
    RUBY
  end

  it 'registers an offense when passign along no arguments' do
    expect_offense(<<~RUBY)
      def foo
        super()
        ^^^^^^^ Call `super` without arguments and parentheses when the signature is identical.
      end
    RUBY
  end

  it 'registers an offense for nested declarations' do
    expect_offense(<<~RUBY)
      def foo(a)
        def bar(b:)
          super(b: b)
          ^^^^^^^^^^^ Call `super` without arguments and parentheses when the signature is identical.
        end
        super(a)
        ^^^^^^^^ Call `super` without arguments and parentheses when the signature is identical.
      end
    RUBY
  end

  it 'registers an offense when the hash argument is or-assigned' do
    expect_offense(<<~RUBY)
      def foo(options, &block)
        options[:key] ||= default

        super(options, &block)
        ^^^^^^^^^^^^^^^^^^^^^^ Call `super` without arguments and parentheses when the signature is identical.
      end
    RUBY

    expect_correction(<<~RUBY)
      def foo(options, &block)
        options[:key] ||= default

        super
      end
    RUBY
  end

  it 'registers no offense when calling super in a dsl method' do
    expect_no_offenses(<<~RUBY)
      describe 'example' do
        subject { super() }
      end
    RUBY
  end

  context 'when calling super with an extra block argument' do
    it 'registers no offense when calling super with no arguments' do
      expect_no_offenses(<<~RUBY)
        def test
          super { x }
        end
      RUBY
    end

    it 'registers no offense when calling super with implicit positional arguments' do
      expect_no_offenses(<<~RUBY)
        def test(a)
          super { x }
        end
      RUBY
    end

    it 'registers no offense for a method with block when calling super with positional argument' do
      expect_no_offenses(<<~RUBY)
        def test(a, &blk)
          super(a) { x }
        end
      RUBY
    end
  end

  context 'scope changes' do
    it 'registers no offense when the scope changes because of a class definition with block' do
      expect_no_offenses(<<~RUBY)
        def foo(a)
          Class.new do
            def foo(a, b)
              super(a)
            end
          end
        end
      RUBY
    end
  end

  it 'does not register offense when calling super in a block' do
    expect_no_offenses(<<~RUBY)
      def foo(a)
        delegate_to_define_method do
          super(a)
        end
      end
    RUBY
  end

  it 'registers an offense when the scope changes because of a numblock' do
    expect_offense(<<~RUBY)
      def foo(a)
        bar do
          baz(_1)
          super(a)
          ^^^^^^^^ Call `super` without arguments and parentheses when the signature is identical.
        end
      end
    RUBY
  end

  it 'registers no offense when the scope changes because of sclass' do
    expect_no_offenses(<<~RUBY)
      def foo(a)
        class << self
          def foo(b)
            super(a)
          end
        end
      end
    RUBY
  end

  it 'registers no offense when calling super in define_singleton_method' do
    expect_no_offenses(<<~RUBY)
      def test(a)
        define_singleton_method(:test2) do |a|
          super(a)
        end
        b.define_singleton_method(:test2) do |a|
          super(a)
        end
      end
    RUBY
  end

  context 'block reassignment' do
    it 'registers no offense when the block argument is reassigned' do
      expect_no_offenses(<<~RUBY)
        def test(&blk)
          blk = proc {}
          super(&blk)
        end
      RUBY
    end

    it 'registers no offense when the block argument is reassigned in a nested block' do
      expect_no_offenses(<<~RUBY)
        def test(&blk)
          if foo
            blk = proc {} if bar
          end
          super(&blk)
        end
      RUBY
    end

    it 'registers no offense when the block argument is or-assigned' do
      expect_no_offenses(<<~RUBY)
        def test(&blk)
          blk ||= proc {}
          super(&blk)
        end
      RUBY
    end
  end
end
