# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::MixinGrouping, :config do
  context 'when configured with separated style' do
    let(:cop_config) { { 'EnforcedStyle' => 'separated' } }

    context 'when using `include`' do
      it 'registers an offense for several mixins in one call' do
        expect_offense(<<~RUBY)
          class Foo
            include Bar, Qux
            ^^^^^^^^^^^^^^^^ Put `include` mixins in separate statements.
          end
        RUBY

        expect_correction(<<~RUBY)
          class Foo
            include Qux
            include Bar
          end
        RUBY
      end

      it 'allows include call as an argument to another method' do
        expect_no_offenses('expect(foo).to include { { bar: baz } }')
      end

      it 'registers an offense for several mixins in separate calls' do
        expect_offense(<<~RUBY)
          class Foo
            include Bar, Baz
            ^^^^^^^^^^^^^^^^ Put `include` mixins in separate statements.
            include Qux
          end
        RUBY

        expect_correction(<<~RUBY)
          class Foo
            include Baz
            include Bar
            include Qux
          end
        RUBY
      end
    end

    context 'when using `extend`' do
      it 'registers an offense for several mixins in one call' do
        expect_offense(<<~RUBY)
          class Foo
            extend Bar, Qux
            ^^^^^^^^^^^^^^^ Put `extend` mixins in separate statements.
          end
        RUBY

        expect_correction(<<~RUBY)
          class Foo
            extend Qux
            extend Bar
          end
        RUBY
      end
    end

    context 'when using `prepend`' do
      it 'registers an offense for several mixins in one call' do
        expect_offense(<<~RUBY)
          class Foo
            prepend Bar, Qux
            ^^^^^^^^^^^^^^^^ Put `prepend` mixins in separate statements.
          end
        RUBY

        expect_correction(<<~RUBY)
          class Foo
            prepend Qux
            prepend Bar
          end
        RUBY
      end
    end

    context 'when using a mix of different methods' do
      it 'registers an offense for some calls having several mixins' do
        expect_offense(<<~RUBY)
          class Foo
            include Bar, Baz
            ^^^^^^^^^^^^^^^^ Put `include` mixins in separate statements.
            extend Qux
          end
        RUBY

        expect_correction(<<~RUBY)
          class Foo
            include Baz
            include Bar
            extend Qux
          end
        RUBY
      end
    end
  end

  context 'when configured with grouped style' do
    let(:cop_config) { { 'EnforcedStyle' => 'grouped' } }

    context 'when using include' do
      it 'registers an offense for single mixins in separate calls' do
        expect_offense(<<~RUBY)
          class Foo
            include Bar
            ^^^^^^^^^^^ Put `include` mixins in a single statement.
            include Baz
            ^^^^^^^^^^^ Put `include` mixins in a single statement.
            include Qux
            ^^^^^^^^^^^ Put `include` mixins in a single statement.
          end
        RUBY

        expect_correction(<<~RUBY)
          class Foo
            include Qux, Baz, Bar
          end
        RUBY
      end

      it 'allows include with an explicit receiver' do
        expect_no_offenses(<<~RUBY)
          config.include Foo
          config.include Bar
        RUBY
      end

      it 'registers an offense for several mixins in separate calls' do
        expect_offense(<<~RUBY)
          class Foo
            include Bar, Baz
            ^^^^^^^^^^^^^^^^ Put `include` mixins in a single statement.
            include FooBar, FooBaz
            ^^^^^^^^^^^^^^^^^^^^^^ Put `include` mixins in a single statement.
            include Qux, FooBarBaz
            ^^^^^^^^^^^^^^^^^^^^^^ Put `include` mixins in a single statement.
          end
        RUBY

        expect_correction(<<~RUBY)
          class Foo
            include Qux, FooBarBaz, FooBar, FooBaz, Bar, Baz
          end
        RUBY
      end
    end

    context 'when using `extend`' do
      it 'registers an offense for single mixins in separate calls' do
        expect_offense(<<~RUBY)
          class Foo
            extend Bar
            ^^^^^^^^^^ Put `extend` mixins in a single statement.
            extend Baz
            ^^^^^^^^^^ Put `extend` mixins in a single statement.
          end
        RUBY

        expect_correction(<<~RUBY)
          class Foo
            extend Baz, Bar
          end
        RUBY
      end
    end

    context 'when using `prepend`' do
      it 'registers an offense for single mixins in separate calls' do
        expect_offense(<<~RUBY)
          class Foo
            prepend Bar
            ^^^^^^^^^^^ Put `prepend` mixins in a single statement.
            prepend Baz
            ^^^^^^^^^^^ Put `prepend` mixins in a single statement.
          end
        RUBY

        expect_correction(<<~RUBY)
          class Foo
            prepend Baz, Bar
          end
        RUBY
      end

      it 'registers an offense for single mixins in separate calls, interspersed' do
        expect_offense(<<~RUBY)
          class Foo
            prepend Bar
            ^^^^^^^^^^^ Put `prepend` mixins in a single statement.
            prepend Baz
            ^^^^^^^^^^^ Put `prepend` mixins in a single statement.
            do_something_else
            prepend Qux
            ^^^^^^^^^^^ Put `prepend` mixins in a single statement.
          end
        RUBY

        # empty line left by prepend Qux
        expect_correction(<<~RUBY)
          class Foo
            prepend Qux, Baz, Bar
            do_something_else
           #{trailing_whitespace}
          end
        RUBY
      end

      it 'registers an offense when other mixins have receivers' do
        expect_offense(<<~RUBY)
          class Foo
            prepend Bar
            ^^^^^^^^^^^ Put `prepend` mixins in a single statement.
            Other.prepend Baz
            do_something_else
            prepend Qux
            ^^^^^^^^^^^ Put `prepend` mixins in a single statement.
          end
        RUBY

        # empty line left by prepend Qux
        expect_correction(<<~RUBY)
          class Foo
            prepend Qux, Bar
            Other.prepend Baz
            do_something_else
           #{trailing_whitespace}
          end
        RUBY
      end
    end

    context 'when using a mix of different methods' do
      it 'registers an offense with some duplicated mixin methods' do
        expect_offense(<<~RUBY)
          class Foo
            include Bar
            ^^^^^^^^^^^ Put `include` mixins in a single statement.
            include Baz
            ^^^^^^^^^^^ Put `include` mixins in a single statement.
            extend Baz
          end
        RUBY

        expect_correction(<<~RUBY)
          class Foo
            include Baz, Bar
            extend Baz
          end
        RUBY
      end

      it 'allows all different mixin methods' do
        expect_no_offenses(<<~RUBY)
          class Foo
            include Bar
            prepend Baz
            extend Baz
          end
        RUBY
      end
    end
  end
end
