# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::PublicAccessModifier, :config do
  it 'registers an offense for a bare public modifier' do
    expect_offense(<<~RUBY)
      class Foo
        private

        def bar; end

        public
        ^^^^^^ Do not use the explicit `public` access modifier.

        def baz; end
      end
    RUBY
  end

  it 'registers an offense for an inline public method definition' do
    expect_offense(<<~RUBY)
      class Foo
        public def foo; end
        ^^^^^^ Do not use the explicit `public` access modifier.
      end
    RUBY
  end

  it 'registers an offense for a public modifier with method names' do
    expect_offense(<<~RUBY)
      class Foo
        public :foo
        ^^^^^^ Do not use the explicit `public` access modifier.
      end
    RUBY
  end

  it 'does not register an offense for implicit public methods' do
    expect_no_offenses(<<~RUBY)
      class Foo
        def foo; end

        private

        def bar; end
      end
    RUBY
  end

  it 'does not register an offense for protected or private modifiers' do
    expect_no_offenses(<<~RUBY)
      class Foo
        protected

        def foo; end

        private

        def bar; end
      end
    RUBY
  end
end
