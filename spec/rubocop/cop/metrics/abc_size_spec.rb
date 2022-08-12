# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Metrics::AbcSize, :config do
  context 'when Max is 0' do
    let(:cop_config) { { 'Max' => 0 } }

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

    it 'registers an offense for an if modifier' do
      expect_offense(<<~RUBY)
        def method_name
        ^^^^^^^^^^^^^^^ Assignment Branch Condition size for method_name is too high. [<0, 2, 1> 2.24/0]
          call_foo if some_condition # 0 + 2*2 + 1*1
        end
      RUBY
    end

    it 'registers an offense for an assignment of a local variable' do
      expect_offense(<<~RUBY)
        def method_name
        ^^^^^^^^^^^^^^^ Assignment Branch Condition size for method_name is too high. [<1, 0, 0> 1/0]
          x = 1
        end
      RUBY
    end

    it 'registers an offense for an assignment of an element' do
      expect_offense(<<~RUBY)
        def method_name
        ^^^^^^^^^^^^^^^ Assignment Branch Condition size for method_name is too high. [<1, 2, 0> 2.24/0]
          x[0] = 1
        end
      RUBY
    end

    it 'registers an offense for complex content including A, B, and C scores' do
      expect_offense(<<~RUBY)
        def method_name
        ^^^^^^^^^^^^^^^ Assignment Branch Condition size for method_name is too high. [<3, 4, 5> 7.07/0]
          my_options = Hash.new if 1 == 1 || 2 == 2 # 1, 1, 4
          my_options.each do |key, value|           # 2, 1, 1
            p key                                   # 0, 1, 0
            p value                                 # 0, 1, 0
          end
        end
      RUBY
    end

    it 'registers an offense for a `define_method`' do
      expect_offense(<<~RUBY)
        define_method :method_name do
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Assignment Branch Condition size for method_name is too high. [<1, 0, 0> 1/0]
          x = 1
        end
      RUBY
    end

    context 'Ruby 2.7', :ruby27 do
      it 'registers an offense for a `define_method` with numblock' do
        expect_offense(<<~RUBY)
          define_method :method_name do
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Assignment Branch Condition size for method_name is too high. [<1, 0, 0> 1/0]
            x = _1
          end
        RUBY
      end
    end

    it 'treats safe navigation method calls like regular method calls + a condition' do
      expect_offense(<<~RUBY)
        def method_name
        ^^^^^^^^^^^^^^^ Assignment Branch Condition size for method_name is too high. [<0, 2, 1> 2.24/0]
          object&.do_something
        end
      RUBY
    end

    context 'when method is in list of allowed methods' do
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
    end

    context 'when CountRepeatedAttributes is `false`' do
      let(:cop_config) { { 'Max' => 0, 'CountRepeatedAttributes' => false } }

      it 'does not count repeated attributes' do
        expect_offense(<<~RUBY)
          def foo
          ^^^^^^^ Assignment Branch Condition size for foo is too high. [<0, 1, 0> 1/0]
            bar
            self.bar
            bar
          end
        RUBY
      end
    end

    context 'when CountRepeatedAttributes is `true`' do
      let(:cop_config) { { 'Max' => 0, 'CountRepeatedAttributes' => true } }

      it 'counts repeated attributes' do
        expect_offense(<<~RUBY)
          def foo
          ^^^^^^^ Assignment Branch Condition size for foo is too high. [<0, 3, 0> 3/0]
            bar
            self.bar
            bar
          end
        RUBY
      end
    end
  end

  context 'when Max is 2' do
    let(:cop_config) { { 'Max' => 2 } }

    it 'accepts two assignments' do
      expect_no_offenses(<<~RUBY)
        def method_name
          x = 1
          y = 2
        end
      RUBY
    end
  end

  context 'when Max is 2.3' do
    let(:cop_config) { { 'Max' => 2.3 } }

    it 'accepts a total score of 2.24' do
      expect_no_offenses(<<~RUBY)
        def method_name
          y = 1 if y == 1
        end
      RUBY
    end
  end

  {
    1.3     => '<1, 1, 4> 4.24/1.3', # no more than 2 decimals reported
    10.3    => '<10, 10, 40> 42.43/10.3',
    100.321 => '<100, 100, 400> 424.3/100.3', # 4 significant digits,
    #                                         so only 1 decimal here
    1000.3  => '<1000, 1000, 4000> 4243/1000'
  }.each do |max, presentation|
    context "when Max is #{max}" do
      let(:cop_config) { { 'Max' => max } }

      it "reports size and max as #{presentation}" do
        # Build an amount of code large enough to register an offense.
        code = ['  x = Hash.new if 1 == 1 || 2 == 2'] * max

        expect_offense(<<~RUBY)
          def method_name
          ^^^^^^^^^^^^^^^ Assignment Branch Condition size for method_name is too high. [#{presentation}]
            #{code.join("\n  ")}
          end
        RUBY

        expect_no_corrections
      end
    end
  end
end
