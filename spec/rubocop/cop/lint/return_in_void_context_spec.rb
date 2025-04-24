# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::ReturnInVoidContext, :config do
  context 'with an initialize method containing a return with a value' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        class A
          def initialize
            return :qux if bar?
            ^^^^^^ Do not return a value in `initialize`.
          end
        end
      RUBY
    end

    it 'registers an offense when the value is returned in a block' do
      expect_offense(<<~RUBY)
        class A
          def initialize
            foo do
              return :qux
              ^^^^^^ Do not return a value in `initialize`.
            end
          end
        end
      RUBY
    end

    it 'registers an offense when the value is returned in a numblock' do
      expect_offense(<<~RUBY)
        class A
          def initialize
            foo do
              _1
              return :qux
              ^^^^^^ Do not return a value in `initialize`.
            end
          end
        end
      RUBY
    end

    it 'registers an offense when the value is returned in an itblock', :ruby34 do
      expect_offense(<<~RUBY)
        class A
          def initialize
            foo do
              it
              return :qux
              ^^^^^^ Do not return a value in `initialize`.
            end
          end
        end
      RUBY
    end

    it 'registers no offense when return is used in `define_method`' do
      expect_no_offenses(<<~RUBY)
        class A
          def initialize
            define_method(:foo) do
              return bar
            end
          end
        end
      RUBY
    end

    it 'registers no offense when return is used in `define_method` with receiver' do
      expect_no_offenses(<<~RUBY)
        class A
          def initialize
            self.define_method(:foo) do
              return bar
            end
          end
        end
      RUBY
    end

    it 'registers no offense when return is used in `define_singleton_method`' do
      expect_no_offenses(<<~RUBY)
        class A
          def initialize
            define_singleton_method(:foo) do
              return bar
            end
          end
        end
      RUBY
    end

    it 'registers no offense when return is used in nested method definition' do
      expect_no_offenses(<<~RUBY)
        class A
          def initialize
            def foo
              return bar
            end
          end
        end
      RUBY
    end

    it 'registers no offense when return is used in nested singleton method definition' do
      expect_no_offenses(<<~RUBY)
        class A
          def initialize
            def self.foo
              return bar
            end
          end
        end
      RUBY
    end

    it 'registers an offense when the value is returned from inside a proc' do
      expect_offense(<<~RUBY)
        class A
          def initialize
            proc do
              return :qux
              ^^^^^^ Do not return a value in `initialize`.
            end
          end
        end
      RUBY
    end

    it 'registers no offense when the value is returned from inside a lamdba' do
      expect_no_offenses(<<~RUBY)
        class A
          def initialize
            lambda do
              return :qux
            end
          end
        end
      RUBY
    end
  end

  context 'with an initialize method containing a return without a value' do
    it 'accepts' do
      expect_no_offenses(<<~RUBY)
        class A
          def initialize
            return if bar?
          end
        end
      RUBY
    end

    it 'accepts when the return is in a block' do
      expect_no_offenses(<<~RUBY)
        class A
          def initialize
            foo do
              return if bar?
            end
          end
        end
      RUBY
    end
  end

  context 'with a setter method containing a return with a value' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        class A
          def foo=(bar)
            return 42
            ^^^^^^ Do not return a value in `foo=`.
          end
        end
      RUBY
    end
  end

  context 'with a setter method containing a return without a value' do
    it 'accepts' do
      expect_no_offenses(<<~RUBY)
        class A
          def foo=(bar)
            return
          end
        end
      RUBY
    end
  end

  context 'with a non initialize method containing a return' do
    it 'accepts' do
      expect_no_offenses(<<~RUBY)
        class A
          def bar
            foo
            return :qux if bar?
            foo
          end
        end
      RUBY
    end
  end

  context 'with a class method called initialize containing a return' do
    it 'accepts' do
      expect_no_offenses(<<~RUBY)
        class A
          def self.initialize
            foo
            return :qux if bar?
            foo
          end
        end
      RUBY
    end
  end

  context 'when return is in top scope' do
    it 'accepts' do
      expect_no_offenses(<<~RUBY)
        return if true
      RUBY
    end
  end
end
