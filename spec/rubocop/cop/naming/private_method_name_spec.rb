# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Naming::PrivateMethodName, :config do
  context 'when private method' do
    it 'registers an offense when naming `foo` as instance method.' do
      expect_offense(<<~RUBY)
        class MyClass
          private
          def foo
              ^^^ Use `_foo` instead of `foo`.
            # ...
          end
        end
      RUBY
    end

    it 'registers an offense when naming `foo` as class method.' do
      expect_offense(<<~RUBY)
        class MyClass
          def self.foo
              ^^^^^^^^ Use `_foo` instead of `foo`.
            # ...
          end

          private_class_method :foo
        end
      RUBY
    end

    it 'registers an offense when naming `foo`, `bar`, and `baz` as attr accessor.' do
      expect_offense(<<~RUBY)
        private
        attr :foo
             ^^^^ Use `_foo` instead of `foo`.
        attr_reader :bar
                    ^^^^ Use `_bar` instead of `bar`.
        attr_writer :baz
                    ^^^^ Use `_baz` instead of `baz`.
      RUBY
    end

    it 'does not register an offense when naming `_foo` as instance method.' do
      expect_no_offenses(<<~RUBY)
        class MyClass
          private
          def _foo
            # ...
          end
        end
      RUBY
    end

    it 'does not register an offense when naming `_foo` as class method.' do
      expect_no_offenses(<<~RUBY)
        class MyClass
          def self._foo
            # ...
          end

          private_class_method :_foo
        end
      RUBY
    end

    it 'does not register an offense when naming `_foo`, `_bar`, and `_baz` as attr accessor.' do
      expect_no_offenses(<<~RUBY)
        private
        attr :_foo
        attr_reader :_bar
        attr_writer :_baz
      RUBY
    end
  end

  context 'when public method' do
    it 'does not register an offense as instance method.' do
      expect_no_offenses(<<~RUBY)
        class MyClass
          public
          def foo
            # ...
          end
        end
      RUBY
    end

    it 'does not register an offense as class method.' do
      expect_no_offenses(<<~RUBY)
        class MyClass
          public
          def self.foo
            # ...
          end
        end
      RUBY
    end

    it 'does not register an offense as attr accessor.' do
      expect_no_offenses(<<~RUBY)
        public
        attr :foo
        attr_reader :bar
        attr_writer :baz
      RUBY
    end
  end

  context 'when protected method' do
    it 'does not register an offense as instance method.' do
      expect_no_offenses(<<~RUBY)
        class MyClass
          protected
          def foo
            # ...
          end
        end
      RUBY
    end

    it 'does not register an offense as class method.' do
      expect_no_offenses(<<~RUBY)
        class MyClass
          protected
          def self.foo
            # ...
          end
        end
      RUBY
    end

    it 'does not register an offense as attr accessor.' do
      expect_no_offenses(<<~RUBY)
        protected
        attr :foo
        attr_reader :bar
        attr_writer :baz
      RUBY
    end
  end
end
