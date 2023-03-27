# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::NestedMethodDefinition, :config do
  it 'registers an offense for a nested method definition' do
    expect_offense(<<~RUBY)
      def x; def y; end; end
             ^^^^^^^^^^ Method definitions must not be nested. Use `lambda` instead.
    RUBY
  end

  it 'registers an offense for a nested singleton method definition' do
    expect_offense(<<~RUBY)
      class Foo
      end
      foo = Foo.new
      def foo.bar
        def baz
        ^^^^^^^ Method definitions must not be nested. Use `lambda` instead.
        end
      end
    RUBY
  end

  it 'registers an offense for a nested method definition inside lambda' do
    expect_offense(<<~RUBY)
      def foo
        bar = -> { def baz; puts; end }
                   ^^^^^^^^^^^^^^^^^^ Method definitions must not be nested. Use `lambda` instead.
      end
    RUBY
  end

  it 'registers an offense for a nested class method definition' do
    expect_offense(<<~RUBY)
      class Foo
        def self.x
          def self.y
          ^^^^^^^^^^ Method definitions must not be nested. Use `lambda` instead.
          end
        end
      end
    RUBY
  end

  it 'does not register an offense for a lambda definition inside method' do
    expect_no_offenses(<<~RUBY)
      def foo
        bar = -> { puts  }
        bar.call
      end
    RUBY
  end

  it 'does not register offense for nested definition inside instance_eval' do
    expect_no_offenses(<<~RUBY)
      class Foo
        def x(obj)
          obj.instance_eval do
            def y
            end
          end
        end
      end
    RUBY
  end

  it 'does not register offense for nested definition inside instance_exec' do
    expect_no_offenses(<<~RUBY)
      class Foo
        def x(obj)
          obj.instance_exec do
            def y
            end
          end
        end
      end
    RUBY
  end

  it 'does not register offense for definition of method on local var' do
    expect_no_offenses(<<~RUBY)
      class Foo
        def x(obj)
          def obj.y
          end
        end
      end
    RUBY
  end

  it 'does not register offense for nested definition inside class_eval' do
    expect_no_offenses(<<~RUBY)
      class Foo
        def x(klass)
          klass.class_eval do
            def y
            end
          end
        end
      end
    RUBY
  end

  it 'does not register offense for nested definition inside class_exec' do
    expect_no_offenses(<<~RUBY)
      class Foo
        def x(klass)
          klass.class_exec do
            def y
            end
          end
        end
      end
    RUBY
  end

  it 'does not register offense for nested definition inside module_eval' do
    expect_no_offenses(<<~RUBY)
      class Foo
        def self.define(mod)
          mod.module_eval do
            def y
            end
          end
        end
      end
    RUBY
  end

  it 'does not register offense for nested definition inside module_exec' do
    expect_no_offenses(<<~RUBY)
      class Foo
        def self.define(mod)
          mod.module_exec do
            def y
            end
          end
        end
      end
    RUBY
  end

  it 'does not register offense for nested definition inside class shovel' do
    expect_no_offenses(<<~RUBY)
      class Foo
        def bar
          class << self
            def baz
            end
          end
        end
      end
    RUBY
  end

  it 'does not register offense for nested definition inside Class.new' do
    expect_no_offenses(<<~RUBY)
      class Foo
        def self.define
          Class.new(S) do
            def y
            end
          end
        end
      end

      class Foo
        def self.define
          Class.new do
            def y
            end
          end
        end
      end
    RUBY
  end

  it 'does not register offense for nested definition inside ::Class.new' do
    expect_no_offenses(<<~RUBY)
      class Foo
        def self.define
          ::Class.new(S) do
            def y
            end
          end
        end
      end

      class Foo
        def self.define
          ::Class.new do
            def y
            end
          end
        end
      end
    RUBY
  end

  it 'does not register offense for nested definition inside Module.new' do
    expect_no_offenses(<<~RUBY)
      class Foo
        def self.define
          Module.new do
            def y
            end
          end
        end
      end
    RUBY
  end

  it 'does not register offense for nested definition inside ::Module.new' do
    expect_no_offenses(<<~RUBY)
      class Foo
        def self.define
          ::Module.new do
            def y
            end
          end
        end
      end
    RUBY
  end

  it 'does not register offense for nested definition inside Struct.new' do
    expect_no_offenses(<<~RUBY)
      class Foo
        def self.define
          Struct.new(:name) do
            def y
            end
          end
        end
      end

      class Foo
        def self.define
          Struct.new do
            def y
            end
          end
        end
      end
    RUBY
  end

  it 'does not register offense for nested definition inside ::Struct.new' do
    expect_no_offenses(<<~RUBY)
      class Foo
        def self.define
          ::Struct.new(:name) do
            def y
            end
          end
        end
      end

      class Foo
        def self.define
          ::Struct.new do
            def y
            end
          end
        end
      end
    RUBY
  end

  it 'does not register offense for nested definition inside `Module.new` with block' do
    expect_no_offenses(<<~RUBY)
      class Foo
        def self.define
          Module.new do |m|
            def y
            end

            do_something(m)
          end
        end
      end
    RUBY
  end

  context 'when Ruby >= 2.7', :ruby27 do
    it 'does not register offense for nested definition inside `Module.new` with numblock' do
      expect_no_offenses(<<~RUBY)
        class Foo
          def self.define
            Module.new do
              def y
              end

              do_something(_1)
            end
          end
        end
      RUBY
    end

    it 'does not register offense for nested definition inside instance_eval with a numblock' do
      expect_no_offenses(<<~RUBY)
        class Foo
          def x(obj)
            obj.instance_eval do
              @bar = _1
              def y
              end
            end
          end
        end
      RUBY
    end

    it 'does not register offense for nested definition inside instance_exec with a numblock' do
      expect_no_offenses(<<~RUBY)
        class Foo
          def x(obj)
            obj.instance_exec(3) do
              @bar = _1
              def y
              end
            end
          end
        end
      RUBY
    end
  end

  context 'when Ruby >= 3.2', :ruby32 do
    it 'does not register offense for nested definition inside `Data.define`' do
      expect_no_offenses(<<~RUBY)
        class Foo
          def self.define
            Data.define(:name) do
              def y
              end
            end
          end
        end

        class Foo
          def self.define
            Data.define do
              def y
              end
            end
          end
        end
      RUBY
    end

    it 'does not register offense for nested definition inside `::Data.define`' do
      expect_no_offenses(<<~RUBY)
        class Foo
          def self.define
            ::Data.define(:name) do
              def y
              end
            end
          end
        end

        class Foo
          def self.define
            ::Data.define do
              def y
              end
            end
          end
        end
      RUBY
    end
  end

  context 'when `AllowedMethods: [has_many]`' do
    let(:cop_config) do
      { 'AllowedMethods' => ['has_many'] }
    end

    it 'does not register offense for nested definition inside `has_many`' do
      expect_no_offenses(<<~RUBY)
        def do_something
          has_many :articles do
            def find_or_create_by_name(name)
            end
          end
        end
      RUBY
    end

    it 'registers offense for nested definition inside `denied_method`' do
      expect_offense(<<~RUBY)
        def do_something
          denied_method :articles do
            def find_or_create_by_name(name)
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Method definitions must not be nested. Use `lambda` instead.
            end
          end
        end
      RUBY
    end
  end

  context 'when `AllowedPatterns: [baz]`' do
    let(:cop_config) do
      { 'AllowedPatterns' => ['baz'] }
    end

    it 'does not register offense for nested definition inside `do_baz`' do
      expect_no_offenses(<<~RUBY)
        def foo(obj)
          obj.do_baz do
            def bar
            end
          end
        end
      RUBY
    end

    it 'registers offense for nested definition inside `do_qux`' do
      expect_offense(<<~RUBY)
        def foo(obj)
          obj.do_qux do
            def bar
            ^^^^^^^ Method definitions must not be nested. Use `lambda` instead.
            end
          end
        end
      RUBY
    end
  end
end
