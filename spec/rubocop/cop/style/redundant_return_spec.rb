# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::RedundantReturn, :config do
  let(:cop_config) { { 'AllowMultipleReturnValues' => false } }

  it 'reports an offense for def with only a return' do
    expect_offense(<<~RUBY)
      def func
        return something
        ^^^^^^ Redundant `return` detected.
      ensure
        2
      end
    RUBY

    expect_correction(<<~RUBY)
      def func
        something
      ensure
        2
      end
    RUBY
  end

  it 'reports an offense for defs with only a return' do
    expect_offense(<<~RUBY)
      def Test.func
        return something
        ^^^^^^ Redundant `return` detected.
      end
    RUBY

    expect_correction(<<~RUBY)
      def Test.func
        something
      end
    RUBY
  end

  it 'reports an offense for def ending with return' do
    expect_offense(<<~RUBY)
      def func
        some_preceding_statements
        return something
        ^^^^^^ Redundant `return` detected.
      end
    RUBY

    expect_correction(<<~RUBY)
      def func
        some_preceding_statements
        something
      end
    RUBY
  end

  it 'reports an offense for define_method with only a return' do
    expect_offense(<<~RUBY)
      define_method(:foo) do
        return something
        ^^^^^^ Redundant `return` detected.
      end
    RUBY

    expect_correction(<<~RUBY)
      define_method(:foo) do
        something
      end
    RUBY
  end

  it 'reports an offense for define_singleton_method with only a return' do
    expect_offense(<<~RUBY)
      define_singleton_method(:foo) do
        return something
        ^^^^^^ Redundant `return` detected.
      end
    RUBY

    expect_correction(<<~RUBY)
      define_singleton_method(:foo) do
        something
      end
    RUBY
  end

  it 'reports an offense for define_method ending with return' do
    expect_offense(<<~RUBY)
      define_method(:foo) do
        some_preceding_statements
        return something
        ^^^^^^ Redundant `return` detected.
      end
    RUBY

    expect_correction(<<~RUBY)
      define_method(:foo) do
        some_preceding_statements
        something
      end
    RUBY
  end

  it 'reports an offense for define_singleton_method ending with return' do
    expect_offense(<<~RUBY)
      define_singleton_method(:foo) do
        some_preceding_statements
        return something
        ^^^^^^ Redundant `return` detected.
      end
    RUBY

    expect_correction(<<~RUBY)
      define_singleton_method(:foo) do
        some_preceding_statements
        something
      end
    RUBY
  end

  it 'reports an offense for def ending with return with splat argument' do
    expect_offense(<<~RUBY)
      def func
        some_preceding_statements
        return *something
        ^^^^^^ Redundant `return` detected.
      end
    RUBY

    expect_correction(<<~RUBY)
      def func
        some_preceding_statements
        something
      end
    RUBY
  end

  it 'reports an offense for defs ending with return' do
    expect_offense(<<~RUBY)
      def self.func
        some_preceding_statements
        return something
        ^^^^^^ Redundant `return` detected.
      end
    RUBY

    expect_correction(<<~RUBY)
      def self.func
        some_preceding_statements
        something
      end
    RUBY
  end

  it 'accepts return in a non-final position' do
    expect_no_offenses(<<~RUBY)
      def func
        return something if something_else
      end
    RUBY
  end

  it 'does not blow up on empty method body' do
    expect_no_offenses(<<~RUBY)
      def func
      end
    RUBY
  end

  it 'does not blow up on empty if body' do
    expect_no_offenses(<<~RUBY)
      def func
        if x
        elsif y
        else
        end
      end
    RUBY
  end

  it 'autocorrects by removing redundant returns' do
    expect_offense(<<~RUBY)
      def func
        one
        two
        return something
        ^^^^^^ Redundant `return` detected.
      end
    RUBY

    expect_correction(<<~RUBY)
      def func
        one
        two
        something
      end
    RUBY
  end

  context 'when return has no arguments' do
    shared_examples 'common behavior' do |ret|
      it "registers an offense for #{ret} and autocorrects replacing #{ret} with nil" do
        expect_offense(<<~RUBY, ret: ret)
          def func
            one
            two
            %{ret}
            ^^^^^^ Redundant `return` detected.
            # comment
          end
        RUBY

        expect_correction(<<~RUBY)
          def func
            one
            two
            nil
            # comment
          end
        RUBY
      end
    end

    it_behaves_like 'common behavior', 'return'
    it_behaves_like 'common behavior', 'return()'
  end

  context 'when multi-value returns are not allowed' do
    it 'reports an offense for def with only a return' do
      expect_offense(<<~RUBY)
        def func
          return something, test
          ^^^^^^ Redundant `return` detected. To return multiple values, use an array.
        end
      RUBY

      expect_correction(<<~RUBY)
        def func
          [something, test]
        end
      RUBY
    end

    it 'reports an offense for defs with only a return' do
      expect_offense(<<~RUBY)
        def Test.func
          return something, test
          ^^^^^^ Redundant `return` detected. To return multiple values, use an array.
        end
      RUBY

      expect_correction(<<~RUBY)
        def Test.func
          [something, test]
        end
      RUBY
    end

    it 'reports an offense for def ending with return' do
      expect_offense(<<~RUBY)
        def func
          one
          two
          return something, test
          ^^^^^^ Redundant `return` detected. To return multiple values, use an array.
        end
      RUBY

      expect_correction(<<~RUBY)
        def func
          one
          two
          [something, test]
        end
      RUBY
    end

    it 'reports an offense for defs ending with return' do
      expect_offense(<<~RUBY)
        def self.func
          one
          two
          return something, test
          ^^^^^^ Redundant `return` detected. To return multiple values, use an array.
        end
      RUBY

      expect_correction(<<~RUBY)
        def self.func
          one
          two
          [something, test]
        end
      RUBY
    end

    it 'autocorrects by removing return when using an explicit hash' do
      expect_offense(<<~RUBY)
        def func
          return {:a => 1, :b => 2}
          ^^^^^^ Redundant `return` detected.
        end
      RUBY

      # :a => 1, :b => 2 is not valid Ruby
      expect_correction(<<~RUBY)
        def func
          {:a => 1, :b => 2}
        end
      RUBY
    end

    it 'autocorrects by making an implicit hash explicit' do
      expect_offense(<<~RUBY)
        def func
          return :a => 1, :b => 2
          ^^^^^^ Redundant `return` detected.
        end
      RUBY

      # :a => 1, :b => 2 is not valid Ruby
      expect_correction(<<~RUBY)
        def func
          {:a => 1, :b => 2}
        end
      RUBY
    end

    it 'reports an offense when multiple return values have a parenthesized return value' do
      expect_offense(<<~RUBY)
        def do_something
          return (foo && bar), 42
          ^^^^^^ Redundant `return` detected. To return multiple values, use an array.
        end
      RUBY

      expect_correction(<<~RUBY)
        def do_something
          [(foo && bar), 42]
        end
      RUBY
    end
  end

  context 'when multi-value returns are allowed' do
    let(:cop_config) { { 'AllowMultipleReturnValues' => true } }

    it 'accepts def with only a return' do
      expect_no_offenses(<<~RUBY)
        def func
          return something, test
        end
      RUBY
    end

    it 'accepts defs with only a return' do
      expect_no_offenses(<<~RUBY)
        def Test.func
          return something, test
        end
      RUBY
    end

    it 'accepts def ending with return' do
      expect_no_offenses(<<~RUBY)
        def func
          one
          two
          return something, test
        end
      RUBY
    end

    it 'accepts defs ending with return' do
      expect_no_offenses(<<~RUBY)
        def self.func
          one
          two
          return something, test
        end
      RUBY
    end
  end

  context 'when return is inside begin-end body' do
    it 'registers an offense and autocorrects' do
      expect_offense(<<~RUBY)
        def func
          some_preceding_statements
          begin
            return 1
            ^^^^^^ Redundant `return` detected.
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        def func
          some_preceding_statements
          begin
            1
          end
        end
      RUBY
    end
  end

  context 'when rescue and return blocks present' do
    it 'registers an offense and autocorrects when inside function or rescue block' do
      expect_offense(<<~RUBY)
        def func
          1
          2
          return 3
          ^^^^^^ Redundant `return` detected.
        rescue SomeException
          4
          return 5
          ^^^^^^ Redundant `return` detected.
        rescue AnotherException
          return 6
          ^^^^^^ Redundant `return` detected.
        ensure
          return 7
        end
      RUBY

      expect_correction(<<~RUBY)
        def func
          1
          2
          3
        rescue SomeException
          4
          5
        rescue AnotherException
          6
        ensure
          return 7
        end
      RUBY
    end

    it 'registers an offense and autocorrects when rescue has else clause' do
      expect_offense(<<~RUBY)
        def func
          return 3
        rescue SomeException
        else
          return 4
          ^^^^^^ Redundant `return` detected.
        end
      RUBY

      expect_correction(<<~RUBY)
        def func
          return 3
        rescue SomeException
        else
          4
        end
      RUBY
    end
  end

  context 'when return is inside an if-branch' do
    it 'registers an offense and autocorrects' do
      expect_offense(<<~RUBY)
        def func
          some_preceding_statements
          if x
            return 1
            ^^^^^^ Redundant `return` detected.
          elsif y
            return 2
            ^^^^^^ Redundant `return` detected.
          else
            return 3
            ^^^^^^ Redundant `return` detected.
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        def func
          some_preceding_statements
          if x
            1
          elsif y
            2
          else
            3
          end
        end
      RUBY
    end
  end

  context 'when return is inside a when-branch' do
    it 'registers an offense and autocorrects' do
      expect_offense(<<~RUBY)
        def func
          some_preceding_statements
          case x
          when y then return 1
                      ^^^^^^ Redundant `return` detected.
          when z then return 2
                      ^^^^^^ Redundant `return` detected.
          when q
          else
            return 3
            ^^^^^^ Redundant `return` detected.
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        def func
          some_preceding_statements
          case x
          when y then 1
          when z then 2
          when q
          else
            3
          end
        end
      RUBY
    end
  end

  context 'when case nodes are empty' do
    it 'accepts empty when nodes' do
      expect_no_offenses(<<~RUBY)
        def func
          case x
          when y then 1
          when z # do nothing
          else
            3
          end
        end
      RUBY
    end
  end
end
