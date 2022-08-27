# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::EmptyLineBetweenDefs, :config do
  let(:cop_config) { { 'AllowAdjacentOneLineDefs' => false } }

  it 'finds offenses in inner classes' do
    expect_offense(<<~RUBY)
      class K
        def m
        end

        class J
          def n
          end
          def o
          ^^^^^ Expected 1 empty line between method definitions; found 0.
          end
        end

        # checks something
        def p
        end
      end
    RUBY
  end

  context 'when there are only comments between defs' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        class J
          def n
          end # n-related
          # checks something o-related
          # and more
          def o
          ^^^^^ Expected 1 empty line between method definitions; found 0.
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        class J
          def n
          end # n-related

          # checks something o-related
          # and more
          def o
          end
        end
      RUBY
    end
  end

  context 'conditional method definitions' do
    it 'accepts defs inside a conditional without blank lines in between' do
      expect_no_offenses(<<~RUBY)
        if condition
          def foo
            true
          end
        else
          def foo
            false
          end
        end
      RUBY
    end

    it 'registers an offense for consecutive defs inside a conditional' do
      expect_offense(<<~RUBY)
        if condition
          def foo
            true
          end
          def bar
          ^^^^^^^ Expected 1 empty line between method definitions; found 0.
            true
          end
        else
          def foo
            false
          end
        end
      RUBY
    end
  end

  context 'class methods' do
    context 'adjacent class methods' do
      it 'registers an offense for missing blank line between methods' do
        expect_offense(<<~RUBY)
          class Test
            def self.foo
              true
            end
            def self.bar
            ^^^^^^^^^^^^ Expected 1 empty line between method definitions; found 0.
              true
            end
          end
        RUBY

        expect_correction(<<~RUBY)
          class Test
            def self.foo
              true
            end

            def self.bar
              true
            end
          end
        RUBY
      end
    end

    context 'mixed instance and class methods' do
      it 'registers an offense for missing blank line between methods' do
        expect_offense(<<~RUBY)
          class Test
            def foo
              true
            end
            def self.bar
            ^^^^^^^^^^^^ Expected 1 empty line between method definitions; found 0.
              true
            end
          end
        RUBY

        expect_correction(<<~RUBY)
          class Test
            def foo
              true
            end

            def self.bar
              true
            end
          end
        RUBY
      end
    end
  end

  # Only one def, so rule about empty line *between* defs does not
  # apply.
  it 'accepts a def that follows a line with code' do
    expect_no_offenses(<<~RUBY)
      x = 0
      def m
      end
    RUBY
  end

  # Only one def, so rule about empty line *between* defs does not
  # apply.
  it 'accepts a def that follows code and a comment' do
    expect_no_offenses(<<~RUBY)
      x = 0
      # 123
      def m
      end
    RUBY
  end

  it 'accepts the first def without leading empty line in a class' do
    expect_no_offenses(<<~RUBY)
      class K
        def m
        end
      end
    RUBY
  end

  it 'accepts a def that follows an empty line and then a comment' do
    expect_no_offenses(<<~RUBY)
      class A
        # calculates value
        def m
        end

        private
        # calculates size
        def n
        end
      end
    RUBY
  end

  it 'accepts a def that is the first of a module' do
    expect_no_offenses(<<~RUBY)
      module Util
        public
        #
        def html_escape(s)
        end
      end
    RUBY
  end

  it 'accepts a nested def' do
    expect_no_offenses(<<~RUBY)
      def mock_model(*attributes)
        Class.new do
          def initialize(attrs)
          end
        end
      end
    RUBY
  end

  it 'registers an offense for adjacent one-liners by default' do
    expect_offense(<<~RUBY)
      def a; end
      def b; end
      ^^^^^ Expected 1 empty line between method definitions; found 0.
    RUBY

    expect_correction(<<~RUBY)
      def a; end

      def b; end
    RUBY
  end

  it 'autocorrects when there are too many new lines' do
    expect_offense(<<~RUBY)
      def a; end



      def b; end
      ^^^^^ Expected 1 empty line between method definitions; found 3.
    RUBY

    expect_correction(<<~RUBY)
      def a; end

      def b; end
    RUBY
  end

  it 'treats lines with whitespaces as blank' do
    expect_no_offenses(<<~RUBY)
      class J
        def n
        end

        def o
        end
      end
    RUBY
  end

  it "doesn't allow more than the required number of newlines" do
    expect_offense(<<~RUBY)
      class A
        def n
        end


        def o
        ^^^^^ Expected 1 empty line between method definitions; found 2.
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      class A
        def n
        end

        def o
        end
      end
    RUBY
  end

  it 'registers an offense for multiple one-liners on the same line' do
    expect_offense(<<~RUBY)
      def a; end; def b; end
                  ^^^^^ Expected 1 empty line between method definitions; found 0.
    RUBY

    expect_correction(<<~RUBY)
      def a; end;#{trailing_whitespace}

      def b; end
    RUBY
  end

  context 'when AllowAdjacentOneLineDefs is enabled' do
    let(:cop_config) { { 'AllowAdjacentOneLineDefs' => true } }

    it 'accepts adjacent one-liners' do
      expect_no_offenses(<<~RUBY)
        def a; end
        def b; end
      RUBY
    end

    it 'registers an offense for adjacent defs if some are multi-line' do
      expect_offense(<<~RUBY)
        def a; end
        def b; end
        def c # Not a one-liner, so this is an offense.
        ^^^^^ Expected 1 empty line between method definitions; found 0.
        end
        def d; end # Also an offense since previous was multi-line:
        ^^^^^ Expected 1 empty line between method definitions; found 0.
      RUBY

      expect_correction(<<~RUBY)
        def a; end
        def b; end

        def c # Not a one-liner, so this is an offense.
        end

        def d; end # Also an offense since previous was multi-line:
      RUBY
    end
  end

  context 'when a maximum of empty lines is specified' do
    let(:cop_config) { { 'NumberOfEmptyLines' => [0, 1] } }

    it 'finds no offense for no empty line' do
      expect_no_offenses(<<~RUBY)
        def n
        end
        def o
        end
      RUBY
    end

    it 'finds no offense for one empty line' do
      expect_no_offenses(<<~RUBY)
        def n
        end

        def o
         end
      RUBY
    end

    it 'finds an offense for two empty lines' do
      expect_offense(<<~RUBY)
        def n
        end


        def o
        ^^^^^ Expected 0..1 empty lines between method definitions; found 2.
        end
      RUBY

      expect_correction(<<~RUBY)
        def n
        end

        def o
        end
      RUBY
    end
  end

  context 'when multiple lines between defs are allowed' do
    let(:cop_config) { { 'NumberOfEmptyLines' => 2 } }

    it 'treats lines with whitespaces as blank' do
      expect_offense(<<~RUBY)
        def n
        end

        def o
        ^^^^^ Expected 2 empty lines between method definitions; found 1.
        end
      RUBY

      expect_correction(<<~RUBY)
        def n
        end


        def o
        end
      RUBY
    end

    it 'registers an offense and corrects when there are too many new lines' do
      expect_offense(<<~RUBY)
        def n
        end




        def o
        ^^^^^ Expected 2 empty lines between method definitions; found 4.
        end
      RUBY

      expect_correction(<<~RUBY)
        def n
        end


        def o
        end
      RUBY
    end
  end

  context 'EmptyLineBetweenClassDefs' do
    it 'registers offense when no empty lines between class and method definitions' do
      expect_offense(<<~RUBY)
        class Foo
        end
        class Baz
        ^^^^^^^^^ Expected 1 empty line between class definitions; found 0.
        end
        def example
        ^^^^^^^^^^^ Expected 1 empty line between method definitions; found 0.
        end
      RUBY

      expect_correction(<<~RUBY)
        class Foo
        end

        class Baz
        end

        def example
        end
      RUBY
    end

    context 'when disabled' do
      let(:cop_config) { { 'EmptyLineBetweenClassDefs' => false } }

      it 'does not register offense' do
        expect_no_offenses(<<~RUBY)
          class Foo
          end
          class Baz
          end
          def example
          end
        RUBY
      end
    end

    context 'with AllowAdjacentOneLineDefs enabled' do
      let(:cop_config) { { 'AllowAdjacentOneLineDefs' => true } }

      it 'does not register offense' do
        expect_no_offenses(<<~RUBY)
          class Foo; end
          class Baz; end
        RUBY
      end
    end
  end

  context 'EmptyLineBetweenModuleDefs' do
    it 'registers offense when no empty lines between module and method definitions' do
      expect_offense(<<~RUBY)
        module Foo
        end
        module Baz
        ^^^^^^^^^^ Expected 1 empty line between module definitions; found 0.
        end
        def example
        ^^^^^^^^^^^ Expected 1 empty line between method definitions; found 0.
        end
      RUBY

      expect_correction(<<~RUBY)
        module Foo
        end

        module Baz
        end

        def example
        end
      RUBY
    end

    context 'when disabled' do
      let(:cop_config) { { 'EmptyLineBetweenModuleDefs' => false } }

      it 'does not register offense' do
        expect_no_offenses(<<~RUBY)
          module Foo
          end
          module Baz
          end
          def example
          end
        RUBY
      end
    end
  end

  context 'when empty lines between classes and modules together' do
    it 'registers offense when no empty lines between module and method definitions' do
      expect_offense(<<~RUBY)
        class Foo
        end
        module Baz
        ^^^^^^^^^^ Expected 1 empty line between module definitions; found 0.
        end
        def example
        ^^^^^^^^^^^ Expected 1 empty line between method definitions; found 0.
        end
      RUBY

      expect_correction(<<~RUBY)
        class Foo
        end

        module Baz
        end

        def example
        end
      RUBY
    end
  end

  context 'endless methods', :ruby30 do
    context 'between endless and regular methods' do
      it 'registers an offense and corrects' do
        expect_offense(<<~RUBY)
          def foo() = x
          def bar
          ^^^^^^^ Expected 1 empty line between method definitions; found 0.
            y
          end
        RUBY

        expect_correction(<<~RUBY)
          def foo() = x

          def bar
            y
          end
        RUBY
      end
    end

    context 'between regular and endless methods' do
      it 'registers an offense and corrects' do
        expect_offense(<<~RUBY)
          def foo
            x
          end
          def bar() = y
          ^^^^^^^ Expected 1 empty line between method definitions; found 0.
        RUBY

        expect_correction(<<~RUBY)
          def foo
            x
          end

          def bar() = y
        RUBY
      end
    end

    context 'between endless class method and regular methods' do
      it 'registers an offense and corrects' do
        expect_offense(<<~RUBY)
          def self.foo = x
          def bar
          ^^^^^^^ Expected 1 empty line between method definitions; found 0.
            y
          end
        RUBY

        expect_correction(<<~RUBY)
          def self.foo = x

          def bar
            y
          end
        RUBY
      end
    end

    context 'between endless class method and regular class methods' do
      it 'registers an offense and corrects' do
        expect_offense(<<~RUBY)
          def self.foo = x
          def self.bar
          ^^^^^^^^^^^^ Expected 1 empty line between method definitions; found 0.
            y
          end
        RUBY

        expect_correction(<<~RUBY)
          def self.foo = x

          def self.bar
            y
          end
        RUBY
      end
    end

    context 'with AllowAdjacentOneLineDefs: false' do
      it 'registers an offense and corrects' do
        expect_offense(<<~RUBY)
          def foo() = x
          def bar() = y
          ^^^^^^^ Expected 1 empty line between method definitions; found 0.
        RUBY

        expect_correction(<<~RUBY)
          def foo() = x

          def bar() = y
        RUBY
      end
    end

    context 'with AllowAdjacentOneLineDefs: true' do
      let(:cop_config) { { 'AllowAdjacentOneLineDefs' => true } }

      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          def foo() = x
          def bar() = y
        RUBY
      end
    end
  end
end
