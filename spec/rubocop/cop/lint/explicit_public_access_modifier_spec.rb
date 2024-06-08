# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::ExplicitPublicAccessModifier, :config do
  it 'registers an offense when using `public` access modifier in a module' do
    expect_offense(<<~RUBY)
      module Test
        public
        ^^^^^^ Avoid `public` access modifier.

        def test
          puts 'test'
        end
      end
    RUBY
  end

  it 'registers an offense when using `public` access modifier in a class' do
    expect_offense(<<~RUBY)
      class Test
        public
        ^^^^^^ Avoid `public` access modifier.

        def test
          puts 'test'
        end
      end
    RUBY
  end

  it 'registers an offense when using `public` access modifier with an argument' do
    expect_offense(<<~RUBY)
      class Test
        public def test
        ^^^^^^^^^^^^^^^ Avoid `public` access modifier.
          puts 'test'
        end

      end
    RUBY
  end

  it 'registers an offense when using `public` access modifier with arguments' do
    expect_offense(<<~RUBY)
      class Test
        def test_1
          puts 'test_1'
        end

        def test_2
          puts 'test_2'
        end

        def test_3
          puts 'test_3'
        end

        public :test_1, :test_2, :test_3
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid `public` access modifier.
      end
    RUBY
  end

  it 'does not register an offense for methods without `public`' do
    expect_no_offenses(<<~RUBY)
      module Test
        def test
          puts 'test'
        end
      end
    RUBY
  end

  it 'does not register an offense for defined public method' do
    expect_no_offenses(<<~RUBY)
      module Test
        def public
          puts 'public method'
        end

        def test
          public
        end
      end
    RUBY
  end
end
