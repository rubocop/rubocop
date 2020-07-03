# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::RedundantAssignment do
  subject(:cop) { described_class.new }

  it 'reports an offense for def ending with assignment and returning' do
    expect_offense(<<~RUBY)
      def func
        some_preceding_statements
        x = something
        ^^^^^^^^^^^^^ Redundant assignment before returning detected.
        x
      end
    RUBY

    expect_correction(<<~RUBY)
      def func
        some_preceding_statements
        something
        
      end
    RUBY
  end

  context 'when inside begin-end body' do
    it 'registers an offense and auto-corrects' do
      expect_offense(<<~RUBY)
        def func
          some_preceding_statements
          begin
            x = something
            ^^^^^^^^^^^^^ Redundant assignment before returning detected.
            x
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        def func
          some_preceding_statements
          begin
            something
            
          end
        end
      RUBY
    end
  end

  context 'when rescue blocks present' do
    it 'does register an offense and auto-corrects when inside function or rescue block' do
      expect_offense(<<~RUBY)
        def func
          1
          x = 2
          ^^^^^ Redundant assignment before returning detected.
          x
        rescue SomeException
          3
          x = 4
          ^^^^^ Redundant assignment before returning detected.
          x
        rescue AnotherException
          5
        end
      RUBY

      expect_correction(<<~RUBY)
        def func
          1
          2
          
        rescue SomeException
          3
          4
          
        rescue AnotherException
          5
        end
      RUBY
    end
  end

  it 'does not register an offense when ensure block present' do
    expect_no_offenses(<<~RUBY)
      def func
        1
        x = 2
        x
      ensure
        3
      end
    RUBY
  end

  context 'when inside an if-branch' do
    it 'registers an offense and auto-corrects' do
      expect_offense(<<~RUBY)
        def func
          some_preceding_statements
          if x
            z = 1
            ^^^^^ Redundant assignment before returning detected.
            z
          elsif y
            2
          else
            z = 3
            ^^^^^ Redundant assignment before returning detected.
            z
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

  context 'when inside a when-branch' do
    it 'registers an offense and auto-corrects' do
      expect_offense(<<~RUBY)
        def func
          some_preceding_statements
          case x
          when y
            res = 1
            ^^^^^^^ Redundant assignment before returning detected.
            res
          when z
            2
          when q
          else
            res = 3
            ^^^^^^^ Redundant assignment before returning detected.
            res
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        def func
          some_preceding_statements
          case x
          when y
            1
            
          when z
            2
          when q
          else
            3
            
          end
        end
      RUBY
    end
  end

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

  it 'accepts empty method body' do
    expect_no_offenses(<<~RUBY)
      def func
      end
    RUBY
  end

  it 'accepts empty if body' do
    expect_no_offenses(<<~RUBY)
      def func
        if x
        elsif y
        else
        end
      end
    RUBY
  end
end
