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
end
