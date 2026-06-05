# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::TrailingCommaInAttributeDeclaration, :config do
  it 'registers an offense when using trailing comma' do
    expect_offense(<<~RUBY)
      class Foo
        attr_reader :bar,
                        ^ Avoid leaving a trailing comma in attribute declarations.

        def baz
          puts "Qux"
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      class Foo
        attr_reader :bar

        def baz
          puts "Qux"
        end
      end
    RUBY
  end

  it 'registers an offense when a trailing comma precedes a singleton method definition' do
    expect_offense(<<~RUBY)
      class Foo
        attr_reader :bar,
                        ^ Avoid leaving a trailing comma in attribute declarations.

        def self.baz; end
      end
    RUBY

    expect_correction(<<~RUBY)
      class Foo
        attr_reader :bar

        def self.baz; end
      end
    RUBY
  end

  it 'registers an offense for `attr_accessor` with a trailing comma' do
    expect_offense(<<~RUBY)
      class Foo
        attr_accessor :bar,
                          ^ Avoid leaving a trailing comma in attribute declarations.

        def baz; end
      end
    RUBY

    expect_correction(<<~RUBY)
      class Foo
        attr_accessor :bar

        def baz; end
      end
    RUBY
  end

  it 'does not register an offense when not using trailing comma' do
    expect_no_offenses(<<~RUBY)
      class Foo
        attr_reader :bar

        def baz
          puts "Qux"
        end
      end
    RUBY
  end

  it 'does not register an offense (or crash) when a `def` is the sole argument' do
    expect_no_offenses(<<~RUBY)
      class Foo
        attr_reader def bar; end
      end
    RUBY
  end
end
