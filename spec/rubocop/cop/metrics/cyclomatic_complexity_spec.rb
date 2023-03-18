# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Metrics::CyclomaticComplexity, :config do
  context 'when Max is 1' do
    let(:cop_config) { { 'Max' => 1 } }

    it 'accepts a method with no decision points' do
      expect_no_offenses(<<~RUBY)
        def method_name
          call_foo
        end
      RUBY
    end

    it 'accepts an empty method' do
      expect_no_offenses(<<~RUBY)
        def method_name
        end
      RUBY
    end

    it 'accepts an empty `define_method`' do
      expect_no_offenses(<<~RUBY)
        define_method :method_name do
        end
      RUBY
    end

    it 'accepts complex code outside of methods' do
      expect_no_offenses(<<~RUBY)
        def method_name
          call_foo
        end

        if first_condition then
          call_foo if second_condition && third_condition
          call_bar if fourth_condition || fifth_condition
        end
      RUBY
    end

    it 'registers an offense for an if modifier' do
      expect_offense(<<~RUBY)
        def self.method_name
        ^^^^^^^^^^^^^^^^^^^^ Cyclomatic complexity for method_name is too high. [2/1]
          call_foo if some_condition
        end
      RUBY
    end

    it 'registers an offense for an unless modifier' do
      expect_offense(<<~RUBY)
        def method_name
        ^^^^^^^^^^^^^^^ Cyclomatic complexity for method_name is too high. [2/1]
          call_foo unless some_condition
        end
      RUBY
    end

    it 'registers an offense for an elsif block' do
      expect_offense(<<~RUBY)
        def method_name
        ^^^^^^^^^^^^^^^ Cyclomatic complexity for method_name is too high. [3/1]
          if first_condition then
            call_foo
          elsif second_condition then
            call_bar
          else
            call_bam
          end
        end
      RUBY
    end

    it 'registers an offense for a ternary operator' do
      expect_offense(<<~RUBY)
        def method_name
        ^^^^^^^^^^^^^^^ Cyclomatic complexity for method_name is too high. [2/1]
          value = some_condition ? 1 : 2
        end
      RUBY
    end

    it 'registers an offense for a while block' do
      expect_offense(<<~RUBY)
        def method_name
        ^^^^^^^^^^^^^^^ Cyclomatic complexity for method_name is too high. [2/1]
          while some_condition do
            call_foo
          end
        end
      RUBY
    end

    it 'registers an offense for an until block' do
      expect_offense(<<~RUBY)
        def method_name
        ^^^^^^^^^^^^^^^ Cyclomatic complexity for method_name is too high. [2/1]
          until some_condition do
            call_foo
          end
        end
      RUBY
    end

    it 'registers an offense for a for block' do
      expect_offense(<<~RUBY)
        def method_name
        ^^^^^^^^^^^^^^^ Cyclomatic complexity for method_name is too high. [2/1]
          for i in 1..2 do
            call_method
          end
        end
      RUBY
    end

    it 'registers an offense for a rescue block' do
      expect_offense(<<~RUBY)
        def method_name
        ^^^^^^^^^^^^^^^ Cyclomatic complexity for method_name is too high. [2/1]
          begin
            call_foo
          rescue Exception
            call_bar
          end
        end
      RUBY
    end

    it 'registers an offense for a case/when block' do
      expect_offense(<<~RUBY)
        def method_name
        ^^^^^^^^^^^^^^^ Cyclomatic complexity for method_name is too high. [3/1]
          case value
          when 1
            call_foo
          when 2
            call_bar
          end
        end
      RUBY
    end

    it 'registers an offense for a case/in block', :ruby27 do
      expect_offense(<<~RUBY)
        def method_name
        ^^^^^^^^^^^^^^^ Cyclomatic complexity for method_name is too high. [3/1]
          case value
          in 1
            call_foo
          in 2
            call_bar
          end
        end
      RUBY
    end

    it 'registers an offense for &&' do
      expect_offense(<<~RUBY)
        def method_name
        ^^^^^^^^^^^^^^^ Cyclomatic complexity for method_name is too high. [2/1]
          call_foo && call_bar
        end
      RUBY
    end

    it 'registers an offense for &&=' do
      expect_offense(<<~RUBY)
        def method_name
        ^^^^^^^^^^^^^^^ Cyclomatic complexity for method_name is too high. [2/1]
          foo = nil
          foo &&= 42
        end
      RUBY
    end

    it 'registers an offense for and' do
      expect_offense(<<~RUBY)
        def method_name
        ^^^^^^^^^^^^^^^ Cyclomatic complexity for method_name is too high. [2/1]
          call_foo and call_bar
        end
      RUBY
    end

    it 'registers an offense for ||' do
      expect_offense(<<~RUBY)
        def method_name
        ^^^^^^^^^^^^^^^ Cyclomatic complexity for method_name is too high. [2/1]
          call_foo || call_bar
        end
      RUBY
    end

    it 'registers an offense for ||=' do
      expect_offense(<<~RUBY)
        def method_name
        ^^^^^^^^^^^^^^^ Cyclomatic complexity for method_name is too high. [2/1]
          foo = nil
          foo ||= 42
        end
      RUBY
    end

    it 'registers an offense for or' do
      expect_offense(<<~RUBY)
        def method_name
        ^^^^^^^^^^^^^^^ Cyclomatic complexity for method_name is too high. [2/1]
          call_foo or call_bar
        end
      RUBY
    end

    it 'deals with nested if blocks containing && and ||' do
      expect_offense(<<~RUBY)
        def method_name
        ^^^^^^^^^^^^^^^ Cyclomatic complexity for method_name is too high. [6/1]
          if first_condition then
            call_foo if second_condition && third_condition
            call_bar if fourth_condition || fifth_condition
          end
        end
      RUBY
    end

    it 'registers an offense for &.' do
      expect_offense(<<~RUBY)
        def method_name
        ^^^^^^^^^^^^^^^ Cyclomatic complexity for method_name is too high. [3/1]
          foo&.bar
          foo&.bar
        end
      RUBY
    end

    it 'counts repeated &. on same untouched local variable as 1' do
      expect_offense(<<~RUBY)
        def method_name
        ^^^^^^^^^^^^^^^ Cyclomatic complexity for method_name is too high. [3/1]
          var = 1
          var&.foo
          var&.dont_count_me
          var = 2
          var&.bar
          var&.dont_count_me_either
        end
      RUBY
    end

    it 'counts only a single method' do
      expect_offense(<<~RUBY)
        def method_name_1
        ^^^^^^^^^^^^^^^^^ Cyclomatic complexity for method_name_1 is too high. [2/1]
          call_foo if some_condition
        end

        def method_name_2
        ^^^^^^^^^^^^^^^^^ Cyclomatic complexity for method_name_2 is too high. [2/1]
          call_foo if some_condition
        end
      RUBY
    end

    it 'registers an offense for a `define_method`' do
      expect_offense(<<~RUBY)
        define_method :method_name do
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Cyclomatic complexity for method_name is too high. [2/1]
          call_foo if some_condition
        end
      RUBY
    end

    it 'counts enumerating methods with blocks as +1' do
      expect_offense(<<~RUBY)
        define_method :method_name do
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Cyclomatic complexity for method_name is too high. [3/1]
          (1..4).map do |i|                            # map: +1
            i * 2
          end.each.with_index { |val, i| puts val, i } # each: +0, with_index: +1
          return treasure.map
        end
      RUBY
    end

    context 'Ruby 2.7', :ruby27 do
      it 'counts enumerating methods with numblocks as +1' do
        expect_offense(<<~RUBY)
          define_method :method_name do
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Cyclomatic complexity for method_name is too high. [3/1]
            (_1.._2).map do |i|                          # map: +1
              i * 2
            end.each.with_index { |val, i| puts val, i } # each: +0, with_index: +1
            return treasure.map
          end
        RUBY
      end
    end

    it 'counts enumerating methods with block-pass as +1' do
      expect_offense(<<~RUBY)
        define_method :method_name do
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Cyclomatic complexity for method_name is too high. [2/1]
          [].map(&:to_s)
        end
      RUBY
    end

    it 'does not count blocks in general' do
      expect_no_offenses(<<~RUBY)
        define_method :method_name do
          Struct.new(:foo, :bar) do
            String.class_eval do
              [42].tap do |answer|
                foo { bar }
              end
            end
          end
        end
      RUBY
    end
  end

  context 'when AllowedMethods is enabled' do
    let(:cop_config) { { 'Max' => 0, 'AllowedMethods' => ['foo'] } }

    it 'does not register an offense when defining an instance method' do
      expect_no_offenses(<<~RUBY)
        def foo
          bar.baz(:qux)
        end
      RUBY
    end

    it 'does not register an offense when defining a class method' do
      expect_no_offenses(<<~RUBY)
        def self.foo
          bar.baz(:qux)
        end
      RUBY
    end

    it 'does not register an offense when using `define_method`' do
      expect_no_offenses(<<~RUBY)
        define_method :foo do
          bar.baz(:qux)
        end
      RUBY
    end
  end

  context 'when AllowedPatterns is enabled' do
    let(:cop_config) { { 'Max' => 0, 'AllowedPatterns' => [/foo/] } }

    it 'does not register an offense when defining an instance method' do
      expect_no_offenses(<<~RUBY)
        def foo
          bar.baz(:qux)
        end
      RUBY
    end

    it 'does not register an offense when defining a class method' do
      expect_no_offenses(<<~RUBY)
        def self.foo
          bar.baz(:qux)
        end
      RUBY
    end

    it 'does not register an offense when using `define_method`' do
      expect_no_offenses(<<~RUBY)
        define_method :foo do
          bar.baz(:qux)
        end
      RUBY
    end
  end

  context 'when Max is 2' do
    let(:cop_config) { { 'Max' => 2 } }

    it 'counts stupid nested if and else blocks' do
      expect_offense(<<~RUBY)
        def method_name
        ^^^^^^^^^^^^^^^ Cyclomatic complexity for method_name is too high. [5/2]
          if first_condition then
            call_foo
          else
            if second_condition then
              call_bar
            else
              call_bam if third_condition
            end
            call_baz if fourth_condition
          end
        end
      RUBY
    end
  end
end
