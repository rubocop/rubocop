# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Metrics::MethodLength, :config do
  let(:cop_config) { { 'Max' => 5, 'CountComments' => false } }

  context 'when method is an instance method' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        def m
        ^^^^^ Method has too many lines. [6/5]
          a = 1
          a = 2
          a = 3
          a = 4
          a = 5
          a = 6
        end
      RUBY
    end
  end

  context 'when method is defined with `define_method`' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        define_method(:m) do
        ^^^^^^^^^^^^^^^^^^^^ Method has too many lines. [6/5]
          a = 1
          a = 2
          a = 3
          a = 4
          a = 5
          a = 6
        end
      RUBY
    end
  end

  context 'when using numbered parameter', :ruby27 do
    context 'when method is defined with `define_method`' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          define_method(:m) do
          ^^^^^^^^^^^^^^^^^^^^ Method has too many lines. [6/5]
            a = _1
            a = _2
            a = _3
            a = _4
            a = _5
            a = _6
          end
        RUBY
      end
    end
  end

  context 'when method is a class method' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        def self.m
        ^^^^^^^^^^ Method has too many lines. [6/5]
          a = 1
          a = 2
          a = 3
          a = 4
          a = 5
          a = 6
        end
      RUBY
    end
  end

  context 'when method is defined on a singleton class' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        class K
          class << self
            def m
            ^^^^^ Method has too many lines. [6/5]
              a = 1
              a = 2
              a = 3
              a = 4
              a = 5
              a = 6
            end
          end
        end
      RUBY
    end
  end

  it 'accepts a method with less than 5 lines' do
    expect_no_offenses(<<~RUBY)
      def m
        a = 1
        a = 2
        a = 3
        a = 4
      end
    RUBY
  end

  it 'accepts a method with multiline arguments and less than 5 lines of body' do
    expect_no_offenses(<<~RUBY)
      def m(x,
            y,
            z)
        a = 1
        a = 2
        a = 3
        a = 4
      end
    RUBY
  end

  it 'does not count blank lines' do
    expect_no_offenses(<<~RUBY)
      def m()
        a = 1
        a = 2
        a = 3
        a = 4


        a = 7
      end
    RUBY
  end

  it 'accepts empty methods' do
    expect_no_offenses(<<~RUBY)
      def m()
      end
    RUBY
  end

  it 'is not fooled by one-liner methods, syntax #1' do
    expect_no_offenses(<<~RUBY)
      def one_line; 10 end
      def self.m()
        a = 1
        a = 2
        a = 4
        a = 5
        a = 6
      end
    RUBY
  end

  it 'is not fooled by one-liner methods, syntax #2' do
    expect_no_offenses(<<~RUBY)
      def one_line(test) 10 end
      def self.m()
        a = 1
        a = 2
        a = 4
        a = 5
        a = 6
      end
    RUBY
  end

  it 'properly counts lines when method ends with block' do
    expect_offense(<<~RUBY)
      def m
      ^^^^^ Method has too many lines. [6/5]
        something do
          a = 2
          a = 3
          a = 4
          a = 5
        end
      end
    RUBY
  end

  it 'does not count commented lines by default' do
    expect_no_offenses(<<~RUBY)
      def m()
        a = 1
        #a = 2
        a = 3
        #a = 4
        a = 5
        a = 6
      end
    RUBY
  end

  context 'when CountComments is enabled' do
    before { cop_config['CountComments'] = true }

    it 'also counts commented lines' do
      expect_offense(<<~RUBY)
        def m
        ^^^^^ Method has too many lines. [6/5]
          a = 1
          #a = 2
          a = 3
          #a = 4
          a = 5
          a = 6
        end
      RUBY
    end
  end

  context 'when methods to allow are defined' do
    context 'AllowedMethods is enabled' do
      before { cop_config['AllowedMethods'] = ['foo'] }

      it 'still rejects other methods with more than 5 lines' do
        expect_offense(<<~RUBY)
          def m
          ^^^^^ Method has too many lines. [6/5]
            a = 1
            a = 2
            a = 3
            a = 4
            a = 5
            a = 6
          end
        RUBY
      end

      it 'accepts the foo method with more than 5 lines' do
        expect_no_offenses(<<~RUBY)
          def foo
            a = 1
            a = 2
            a = 3
            a = 4
            a = 5
            a = 6
          end
        RUBY
      end
    end

    context 'AllowedPatterns is enabled' do
      before { cop_config['AllowedPatterns'] = [/_name/] }

      it 'accepts the user_name method' do
        expect_no_offenses(<<~RUBY)
          def user_name
            a = 1
            a = 2
            a = 3
            a = 4
            a = 5
            a = 6
          end
        RUBY
      end

      it 'raises offense for firstname' do
        expect_offense(<<~RUBY)
          def firstname
          ^^^^^^^^^^^^^ Method has too many lines. [6/5]
            a = 1
            a = 2
            a = 3
            a = 4
            a = 5
            a = 6
          end
        RUBY
      end
    end
  end

  context 'when `CountAsOne` is not empty' do
    before { cop_config['CountAsOne'] = ['array'] }

    it 'folds array into one line' do
      expect_no_offenses(<<~RUBY)
        def m
          a = 1
          a = [
            2,
            3,
            4,
            5
          ]
        end
      RUBY
    end
  end
end
