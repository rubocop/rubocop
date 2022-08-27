# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::TrivialAccessors, :config do
  let(:cop_config) { {} }

  it 'registers an offense on instance reader' do
    expect_offense(<<~RUBY)
      class Foo
        def foo
        ^^^ Use `attr_reader` to define trivial reader methods.
          @foo
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      class Foo
        attr_reader :foo
      end
    RUBY
  end

  it 'registers an offense on instance writer' do
    expect_offense(<<~RUBY)
      class Foo
        def foo=(val)
        ^^^ Use `attr_writer` to define trivial writer methods.
          @foo = val
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      class Foo
        attr_writer :foo
      end
    RUBY
  end

  it 'registers an offense on class reader' do
    expect_offense(<<~RUBY)
      class Foo
        def self.foo
        ^^^ Use `attr_reader` to define trivial reader methods.
          @foo
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      class Foo
        class << self
          attr_reader :foo
        end
      end
    RUBY
  end

  it 'registers an offense on class writer' do
    expect_offense(<<~RUBY)
      class Foo
        def self.foo=(val)
        ^^^ Use `attr_writer` to define trivial writer methods.
          @foo = val
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      class Foo
        class << self
          attr_writer :foo
        end
      end
    RUBY
  end

  it 'registers an offense on reader with braces' do
    expect_offense(<<~RUBY)
      class Foo
        def foo()
        ^^^ Use `attr_reader` to define trivial reader methods.
          @foo
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      class Foo
        attr_reader :foo
      end
    RUBY
  end

  it 'registers an offense on writer without braces' do
    expect_offense(<<~RUBY)
      class Foo
        def foo= val
        ^^^ Use `attr_writer` to define trivial writer methods.
          @foo = val
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      class Foo
        attr_writer :foo
      end
    RUBY
  end

  it 'registers an offense on one-liner reader' do
    expect_offense(<<~RUBY)
      class Foo
        def foo; @foo; end
        ^^^ Use `attr_reader` to define trivial reader methods.
      end
    RUBY

    expect_correction(<<~RUBY)
      class Foo
        attr_reader :foo
      end
    RUBY
  end

  it 'registers an offense on one-liner writer' do
    expect_offense(<<~RUBY)
      class Foo
        def foo=(val); @foo=val; end
        ^^^ Use `attr_writer` to define trivial writer methods.
      end
    RUBY

    expect_correction(<<~RUBY)
      class Foo
        attr_writer :foo
      end
    RUBY
  end

  it 'does not register an offense on DSL-style writer' do
    expect_no_offenses(<<~RUBY)
      class Foo
        def foo(val)
          @foo = val
        end
      end
    RUBY
  end

  it 'registers an offense on reader with `private`' do
    expect_offense(<<~RUBY)
      class Foo
        private def foo
                ^^^ Use `attr_reader` to define trivial reader methods.
          @foo
        end
      end
    RUBY

    expect_no_corrections
  end

  it 'accepts non-trivial reader' do
    expect_no_offenses(<<~RUBY)
      class Foo
        def test
          some_function_call
          @test
        end
      end
    RUBY
  end

  it 'accepts non-trivial writer' do
    expect_no_offenses(<<~RUBY)
      class Foo
        def test(val)
          some_function_call(val)
          @test = val
          log(val)
        end
      end
    RUBY
  end

  it 'accepts splats' do
    expect_no_offenses(<<~RUBY)
      class Foo
        def splatomatic(*values)
          @splatomatic = values
        end
      end
    RUBY
  end

  it 'accepts blocks' do
    expect_no_offenses(<<~RUBY)
      class Foo
        def something(&block)
          @b = block
        end
      end
    RUBY
  end

  it 'accepts expressions within reader' do
    expect_no_offenses(<<~RUBY)
      class Foo
        def bar
          @bar + foo
        end
      end
    RUBY
  end

  it 'accepts expressions within writer' do
    expect_no_offenses(<<~RUBY)
      class Foo
        def bar(val)
          @bar = val + foo
        end
      end
    RUBY
  end

  it 'accepts an initialize method looking like a writer' do
    expect_no_offenses(<<~RUBY)
      class Foo
         def initialize(value)
           @top = value
         end
       end
    RUBY
  end

  it 'accepts reader with different ivar name' do
    expect_no_offenses(<<~RUBY)
      class Foo
        def foo
          @fo
        end
      end
    RUBY
  end

  it 'accepts writer with different ivar name' do
    expect_no_offenses(<<~RUBY)
      class Foo
        def foo(val)
          @fo = val
        end
      end
    RUBY
  end

  it 'accepts writer in a module' do
    expect_no_offenses(<<~RUBY)
      module Foo
        def bar=(bar)
          @bar = bar
        end
      end
    RUBY
  end

  it 'accepts writer nested within a module' do
    expect_no_offenses(<<~RUBY)
      module Foo
        begin
          def bar=(bar)
            @bar = bar
          end
        end
      end
    RUBY
  end

  it 'accepts reader nested within a module' do
    expect_no_offenses(<<~RUBY)
      module Foo
        begin
          def bar
            @bar
          end
        end
      end
    RUBY
  end

  it 'accepts reader using top level' do
    expect_no_offenses(<<~RUBY)
      def bar
        @bar
      end
    RUBY
  end

  it 'accepts writer using top level' do
    expect_no_offenses(<<~RUBY)
      def bar=(bar)
        @bar = bar
      end
    RUBY
  end

  it 'accepts writer nested within an instance_eval call' do
    expect_no_offenses(<<~RUBY)
      something.instance_eval do
        begin
          def bar=(bar)
            @bar = bar
          end
        end
      end
    RUBY
  end

  it 'accepts reader nested within an instance_eval call' do
    expect_no_offenses(<<~RUBY)
      something.instance_eval do
        begin
          def bar
            @bar
          end
        end
      end
    RUBY
  end

  it 'flags a reader inside a class, inside an instance_eval call' do
    expect_offense(<<~RUBY)
      something.instance_eval do
        class << @blah
          begin
            def bar
            ^^^ Use `attr_reader` to define trivial reader methods.
              @bar
            end
          end
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      something.instance_eval do
        class << @blah
          begin
            attr_reader :bar
          end
        end
      end
    RUBY
  end

  context 'exact name match disabled' do
    let(:cop_config) { { 'ExactNameMatch' => false } }

    it 'registers an offense when names mismatch in writer' do
      expect_offense(<<~RUBY)
        class Foo
          def foo=(val)
          ^^^ Use `attr_writer` to define trivial writer methods.
            @f = val
          end
        end
      RUBY

      expect_no_corrections
    end

    it 'registers an offense when names mismatch in reader' do
      expect_offense(<<~RUBY)
        class Foo
          def foo
          ^^^ Use `attr_reader` to define trivial reader methods.
            @f
          end
        end
      RUBY

      expect_no_corrections
    end
  end

  context 'disallow predicates' do
    let(:cop_config) { { 'AllowPredicates' => false } }

    it 'does not accept predicate-like reader' do
      expect_offense(<<~RUBY)
        class Foo
          def foo?
          ^^^ Use `attr_reader` to define trivial reader methods.
            @foo
          end
        end
      RUBY

      expect_no_corrections
    end
  end

  context 'allow predicates' do
    let(:cop_config) { { 'AllowPredicates' => true } }

    it 'accepts predicate-like reader' do
      expect_no_offenses(<<~RUBY)
        class Foo
          def foo?
            @foo
          end
        end
      RUBY
    end
  end

  context 'with allowed methods' do
    let(:cop_config) { { 'AllowedMethods' => ['to_foo', 'bar='] } }

    it 'accepts allowed reader' do
      expect_no_offenses(<<~RUBY)
        class Foo
          def to_foo
            @foo
          end
        end
      RUBY
    end

    it 'accepts allowed writer' do
      expect_no_offenses(<<~RUBY)
        class Foo
          def bar=(bar)
            @bar = bar
          end
        end
      RUBY
    end

    context 'with AllowPredicates: false' do
      let(:cop_config) { { 'AllowPredicates' => false, 'AllowedMethods' => ['foo?'] } }

      it 'accepts allowed predicate' do
        expect_no_offenses(<<~RUBY)
          class Foo
            def foo?
              @foo
            end
          end
        RUBY
      end
    end
  end

  context 'with DSL denied' do
    let(:cop_config) { { 'AllowDSLWriters' => false } }

    it 'registers an offense on DSL-style writer' do
      expect_offense(<<~RUBY)
        class Foo
          def foo(val)
          ^^^ Use `attr_writer` to define trivial writer methods.
            @foo = val
          end
        end
      RUBY

      expect_no_corrections
    end
  end

  context 'ignore class methods' do
    let(:cop_config) { { 'IgnoreClassMethods' => true } }

    it 'accepts class reader' do
      expect_no_offenses(<<~RUBY)
        class Foo
          def self.foo
            @foo
          end
        end
      RUBY
    end

    it 'accepts class writer' do
      expect_no_offenses(<<~RUBY)
        class Foo
          def self.foo(val)
            @foo = val
          end
        end
      RUBY
    end
  end
end
