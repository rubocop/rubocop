# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::AccessorGrouping, :config do
  subject(:cop) { described_class.new(config) }

  context 'when EnforcedStyle is grouped' do
    let(:cop_config) do
      { 'EnforcedStyle' => 'grouped' }
    end

    it 'registers an offense and corrects when using separated accessors' do
      expect_offense(<<~RUBY)
        class Foo
          attr_reader :bar1
          ^^^^^^^^^^^^^^^^^ Group together all `attr_reader` attributes.
          attr_reader :bar2
          ^^^^^^^^^^^^^^^^^ Group together all `attr_reader` attributes.
          attr_accessor :quux
          attr_reader :bar3, :bar4
          ^^^^^^^^^^^^^^^^^^^^^^^^ Group together all `attr_reader` attributes.
          other_macro :zoo
        end
      RUBY

      expect_correction(<<~RUBY)
        class Foo
          attr_reader :bar1, :bar2, :bar3, :bar4
          
          attr_accessor :quux
          
          other_macro :zoo
        end
      RUBY
    end

    it 'registers an offense and corrects when using separated accessors with different access modifiers' do
      expect_offense(<<~RUBY)
        class Foo
          attr_reader :bar1
          ^^^^^^^^^^^^^^^^^ Group together all `attr_reader` attributes.
          attr_reader :bar2
          ^^^^^^^^^^^^^^^^^ Group together all `attr_reader` attributes.

          protected
          attr_accessor :quux

          private
          attr_reader :baz1, :baz2
          ^^^^^^^^^^^^^^^^^^^^^^^^ Group together all `attr_reader` attributes.
          attr_writer :baz3
          attr_reader :baz4
          ^^^^^^^^^^^^^^^^^ Group together all `attr_reader` attributes.

          public
          attr_reader :bar3
          ^^^^^^^^^^^^^^^^^ Group together all `attr_reader` attributes.
          other_macro :zoo
        end
      RUBY

      expect_correction(<<~RUBY)
        class Foo
          attr_reader :bar1, :bar2, :bar3
          

          protected
          attr_accessor :quux

          private
          attr_reader :baz1, :baz2, :baz4
          attr_writer :baz3
          

          public
          
          other_macro :zoo
        end
      RUBY
    end

    it 'registers an offense and corrects when using separated accessors within eigenclass' do
      expect_offense(<<~RUBY)
        class Foo
          attr_reader :bar

          class << self
            attr_reader :baz1, :baz2
            ^^^^^^^^^^^^^^^^^^^^^^^^ Group together all `attr_reader` attributes.
            attr_reader :baz3
            ^^^^^^^^^^^^^^^^^ Group together all `attr_reader` attributes.

            private

            attr_reader :quux1
            ^^^^^^^^^^^^^^^^^^ Group together all `attr_reader` attributes.
            attr_reader :quux2
            ^^^^^^^^^^^^^^^^^^ Group together all `attr_reader` attributes.
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        class Foo
          attr_reader :bar

          class << self
            attr_reader :baz1, :baz2, :baz3
            

            private

            attr_reader :quux1, :quux2
            
          end
        end
      RUBY
    end

    it 'does not register an offense when using grouped accessors' do
      expect_no_offenses(<<~RUBY)
        class Foo
          attr_reader :bar, :baz
        end
      RUBY
    end

    it 'does not register offense for accessors with comments' do
      expect_no_offenses(<<~RUBY)
        class Foo
          # @return [String] value of foo
          attr_reader :one, :two

          attr_reader :four
        end
      RUBY
    end

    it 'registers offense and corrects if atleast two separate accessors without comments' do
      expect_offense(<<~RUBY)
        class Foo
          # @return [String] value of foo
          attr_reader :one, :two

          # [String] Some bar value return
          attr_reader :three

          attr_reader :four
          ^^^^^^^^^^^^^^^^^ Group together all `attr_reader` attributes.
          attr_reader :five
          ^^^^^^^^^^^^^^^^^ Group together all `attr_reader` attributes.
        end
      RUBY

      expect_correction(<<~RUBY)
        class Foo
          # @return [String] value of foo
          attr_reader :one, :two

          # [String] Some bar value return
          attr_reader :three

          attr_reader :four, :five
          
        end
      RUBY
    end
  end

  context 'when EnforcedStyle is separated' do
    let(:cop_config) do
      { 'EnforcedStyle' => 'separated' }
    end

    it 'registers an offense and corrects when using grouped accessors' do
      expect_offense(<<~RUBY)
        class Foo
          attr_reader :bar, :baz
          ^^^^^^^^^^^^^^^^^^^^^^ Use one attribute per `attr_reader`.
          attr_accessor :quux
          other_macro :zoo, :woo
        end
      RUBY

      expect_correction(<<~RUBY)
        class Foo
          attr_reader :bar
          attr_reader :baz
          attr_accessor :quux
          other_macro :zoo, :woo
        end
      RUBY
    end

    it 'registers an offense and corrects when using grouped accessors with different access modifiers' do
      expect_offense(<<~RUBY)
        class Foo
          attr_reader :bar1, :bar2
          ^^^^^^^^^^^^^^^^^^^^^^^^ Use one attribute per `attr_reader`.

          protected
          attr_accessor :quux

          private
          attr_reader :baz1, :baz2
          ^^^^^^^^^^^^^^^^^^^^^^^^ Use one attribute per `attr_reader`.
          attr_writer :baz3
          attr_reader :baz4

          public
          attr_reader :bar3
          other_macro :zoo
        end
      RUBY

      expect_correction(<<~RUBY)
        class Foo
          attr_reader :bar1
          attr_reader :bar2

          protected
          attr_accessor :quux

          private
          attr_reader :baz1
          attr_reader :baz2
          attr_writer :baz3
          attr_reader :baz4

          public
          attr_reader :bar3
          other_macro :zoo
        end
      RUBY
    end

    it 'registers an offense and corrects when using grouped accessors within eigenclass' do
      expect_offense(<<~RUBY)
        class Foo
          attr_reader :bar

          class << self
            attr_reader :baz1, :baz2
            ^^^^^^^^^^^^^^^^^^^^^^^^ Use one attribute per `attr_reader`.
            attr_reader :baz3

            private

            attr_reader :quux1, :quux2
            ^^^^^^^^^^^^^^^^^^^^^^^^^^ Use one attribute per `attr_reader`.
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        class Foo
          attr_reader :bar

          class << self
            attr_reader :baz1
            attr_reader :baz2
            attr_reader :baz3

            private

            attr_reader :quux1
            attr_reader :quux2
          end
        end
      RUBY
    end

    it 'does not register an offense when using separated accessors' do
      expect_no_offenses(<<~RUBY)
        class Foo
          attr_reader :bar
          attr_reader :baz
        end
      RUBY
    end

    it 'does not register an offense for grouped accessors with comments' do
      expect_no_offenses(<<~RUBY)
        class Foo
          # Some comment
          attr_reader :one, :two
        end
      RUBY
    end
  end
end
