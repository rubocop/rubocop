# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::BisectedAttrAccessor, :config do
  it 'registers an offense and corrects when both accessors of the name exists' do
    expect_offense(<<~RUBY)
      class Foo
        attr_reader :bar
                    ^^^^ Combine both accessors into `attr_accessor :bar`.
        attr_writer :bar
                    ^^^^ Combine both accessors into `attr_accessor :bar`.
        other_macro :something
      end
    RUBY

    expect_correction(<<~RUBY)
      class Foo
        attr_accessor :bar
        other_macro :something
      end
    RUBY
  end

  it 'registers an offense and corrects when attr and attr_writer exists' do
    expect_offense(<<~RUBY)
      class Foo
        attr :bar
             ^^^^ Combine both accessors into `attr_accessor :bar`.
        attr_writer :bar
                    ^^^^ Combine both accessors into `attr_accessor :bar`.
        other_macro :something
      end
    RUBY

    expect_correction(<<~RUBY)
      class Foo
        attr_accessor :bar
        other_macro :something
      end
    RUBY
  end

  it 'registers an offense and corrects when both accessors of the splat exists' do
    expect_offense(<<~RUBY)
      class Foo
        ATTRIBUTES = %i[foo bar]
        attr_reader *ATTRIBUTES
                    ^^^^^^^^^^^ Combine both accessors into `attr_accessor *ATTRIBUTES`.
        attr_writer *ATTRIBUTES
                    ^^^^^^^^^^^ Combine both accessors into `attr_accessor *ATTRIBUTES`.
        other_macro :something
      end
    RUBY

    expect_correction(<<~RUBY)
      class Foo
        ATTRIBUTES = %i[foo bar]
        attr_accessor *ATTRIBUTES
        other_macro :something
      end
    RUBY
  end

  it 'registers an offense and corrects when both accessors of the name exists and accessor contains multiple names' do
    expect_offense(<<~RUBY)
      class Foo
        attr_reader :baz, :bar, :quux
                          ^^^^ Combine both accessors into `attr_accessor :bar`.
        attr_writer :bar, :zoo
                    ^^^^ Combine both accessors into `attr_accessor :bar`.
        other_macro :something
      end
    RUBY

    expect_correction(<<~RUBY)
      class Foo
        attr_accessor :bar
        attr_reader :baz, :quux
        attr_writer :zoo
        other_macro :something
      end
    RUBY
  end

  it 'registers an offense and corrects properly when attr_writer is before attr_reader' do
    expect_offense(<<~RUBY)
      class Foo
        attr_writer :foo
                    ^^^^ Combine both accessors into `attr_accessor :foo`.
        attr_reader :foo
                    ^^^^ Combine both accessors into `attr_accessor :foo`.
        other_macro :something
      end
    RUBY

    expect_correction(<<~RUBY)
      class Foo
        attr_accessor :foo
        other_macro :something
      end
    RUBY
  end

  it 'registers an offense and corrects when both accessors are in the same visibility scope' do
    expect_offense(<<~RUBY)
      class Foo
        attr_reader :bar
                    ^^^^ Combine both accessors into `attr_accessor :bar`.
        attr_writer :bar
                    ^^^^ Combine both accessors into `attr_accessor :bar`.

        private

        attr_writer :baz
                    ^^^^ Combine both accessors into `attr_accessor :baz`.
        attr_reader :baz
                    ^^^^ Combine both accessors into `attr_accessor :baz`.
      end
    RUBY

    expect_correction(<<~RUBY)
      class Foo
        attr_accessor :bar

        private

        attr_accessor :baz
      end
    RUBY
  end

  it 'registers an offense and corrects when within eigenclass' do
    expect_offense(<<~RUBY)
      class Foo
        attr_reader :bar

        class << self
          attr_reader :baz
                      ^^^^ Combine both accessors into `attr_accessor :baz`.
          attr_writer :baz
                      ^^^^ Combine both accessors into `attr_accessor :baz`.

          private

          attr_reader :quux
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      class Foo
        attr_reader :bar

        class << self
          attr_accessor :baz

          private

          attr_reader :quux
        end
      end
    RUBY
  end

  context 'multiple bisected accessors' do
    context 'when all attr names are bisected' do
      it 'registers and replaces with attr_accessor' do
        expect_offense(<<~RUBY)
          class Foo
            attr_reader :foo, :bar, :baz
                        ^^^^ Combine both accessors into `attr_accessor :foo`.
                              ^^^^ Combine both accessors into `attr_accessor :bar`.
                                    ^^^^ Combine both accessors into `attr_accessor :baz`.
            attr_writer :foo, :bar, :baz
                        ^^^^ Combine both accessors into `attr_accessor :foo`.
                              ^^^^ Combine both accessors into `attr_accessor :bar`.
                                    ^^^^ Combine both accessors into `attr_accessor :baz`.
          end
        RUBY

        expect_correction(<<~RUBY)
          class Foo
            attr_accessor :foo, :bar, :baz
          end
        RUBY
      end
    end

    context 'when some attr names are bisected' do
      it 'registers and retains non-bisected attrs' do
        expect_offense(<<~RUBY)
          class Foo
            attr_reader :foo, :bar, :baz
                        ^^^^ Combine both accessors into `attr_accessor :foo`.
                                    ^^^^ Combine both accessors into `attr_accessor :baz`.
            attr_writer :foo, :baz
                        ^^^^ Combine both accessors into `attr_accessor :foo`.
                              ^^^^ Combine both accessors into `attr_accessor :baz`.
          end
        RUBY

        expect_correction(<<~RUBY)
          class Foo
            attr_accessor :foo, :baz
            attr_reader :bar
          end
        RUBY
      end
    end
  end

  it 'does not register an offense when only one accessor of the name exists' do
    expect_no_offenses(<<~RUBY)
      class Foo
        attr_reader :bar
        attr_writer :baz
      end
    RUBY
  end

  it 'does not register an offense when accessors are within different visibility scopes' do
    expect_no_offenses(<<~RUBY)
      class Foo
        attr_reader :bar

        private
        attr_writer :bar
      end
    RUBY
  end

  it 'registers an offense for accessors with the same visibility in different scopes' do
    expect_offense(<<~RUBY)
      class Foo
        attr_reader :foo
                    ^^^^ Combine both accessors into `attr_accessor :foo`.

        private
        attr_writer :bar

        public
        attr_writer :foo
                    ^^^^ Combine both accessors into `attr_accessor :foo`.
      end
    RUBY

    expect_correction(<<~RUBY)
      class Foo
        attr_accessor :foo

        private
        attr_writer :bar

        public
      end
    RUBY
  end

  it 'registers and corrects in a module' do
    expect_offense(<<~RUBY)
      module Foo
        attr_reader :foo
                    ^^^^ Combine both accessors into `attr_accessor :foo`.
        attr_writer :foo, :bar
                    ^^^^ Combine both accessors into `attr_accessor :foo`.

        private

        attr_reader :bar, :baz
                          ^^^^ Combine both accessors into `attr_accessor :baz`.
        attr_writer :baz
                    ^^^^ Combine both accessors into `attr_accessor :baz`.
      end
    RUBY

    expect_correction(<<~RUBY)
      module Foo
        attr_accessor :foo
        attr_writer :bar

        private

        attr_accessor :baz
        attr_reader :bar
      end
    RUBY
  end

  it 'does not register an offense when using `attr_accessor`' do
    expect_no_offenses(<<~RUBY)
      class Foo
        attr_accessor :bar
      end
    RUBY
  end
end
