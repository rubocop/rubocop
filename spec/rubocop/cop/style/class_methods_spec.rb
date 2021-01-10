# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::ClassMethods, :config do
  it 'registers an offense for methods using a class name' do
    expect_offense(<<~RUBY)
      class Test
        def Test.some_method
            ^^^^ Use `self.some_method` instead of `Test.some_method`.
          do_something
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      class Test
        def self.some_method
          do_something
        end
      end
    RUBY
  end

  it 'registers an offense for methods using a module name' do
    expect_offense(<<~RUBY)
      module Test
        def Test.some_method
            ^^^^ Use `self.some_method` instead of `Test.some_method`.
          do_something
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      module Test
        def self.some_method
          do_something
        end
      end
    RUBY
  end

  it 'does not register an offense for methods using self' do
    expect_no_offenses(<<~RUBY)
      module Test
        def self.some_method
          do_something
        end
      end
    RUBY
  end

  it 'does not register an offense for other top-level singleton methods' do
    expect_no_offenses(<<~RUBY)
      class Test
        X = Something.new

        def X.some_method
          do_something
        end
      end
    RUBY
  end

  it 'does not register an offense outside class/module bodies' do
    expect_no_offenses(<<~RUBY)
      def Test.some_method
        do_something
      end
    RUBY
  end
end
