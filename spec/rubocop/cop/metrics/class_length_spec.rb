# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Metrics::ClassLength, :config do
  let(:cop_config) { { 'Max' => 5, 'CountComments' => false } }

  it 'rejects a class with more than 5 lines' do
    expect_offense(<<~RUBY)
      class Test
      ^^^^^^^^^^ Class has too many lines. [6/5]
        a = 1
        a = 2
        a = 3
        a = 4
        a = 5
        a = 6
      end
    RUBY
  end

  it 'reports the correct beginning and end lines' do
    offenses = expect_offense(<<~RUBY)
      class Test
      ^^^^^^^^^^ Class has too many lines. [6/5]
        a = 1
        a = 2
        a = 3
        a = 4
        a = 5
        a = 6
      end
    RUBY

    offense = offenses.first
    expect(offense.location.last_line).to eq(8)
  end

  it 'accepts a class with 5 lines' do
    expect_no_offenses(<<~RUBY)
      class Test
        a = 1
        a = 2
        a = 3
        a = 4
        a = 5
      end
    RUBY
  end

  it 'accepts a class with less than 5 lines' do
    expect_no_offenses(<<~RUBY)
      class Test
        a = 1
        a = 2
        a = 3
        a = 4
      end
    RUBY
  end

  it 'does not count blank lines' do
    expect_no_offenses(<<~RUBY)
      class Test
        a = 1
        a = 2
        a = 3
        a = 4


        a = 7
      end
    RUBY
  end

  it 'accepts empty classes' do
    expect_no_offenses(<<~RUBY)
      class Test
      end
    RUBY
  end

  context 'when a class has inner classes' do
    it 'does not count lines of inner classes' do
      expect_no_offenses(<<~RUBY)
        class NamespaceClass
          class TestOne
            a = 1
            a = 2
            a = 3
            a = 4
            a = 5
          end
          class TestTwo
            a = 1
            a = 2
            a = 3
            a = 4
            a = 5
          end
          a = 1
          a = 2
          a = 3
          a = 4
          a = 5
        end
      RUBY
    end

    it 'rejects a class with 6 lines that belong to the class directly' do
      expect_offense(<<~RUBY)
        class NamespaceClass
        ^^^^^^^^^^^^^^^^^^^^ Class has too many lines. [6/5]
          class TestOne
            a = 1
            a = 2
            a = 3
            a = 4
            a = 5
          end
          class TestTwo
            a = 1
            a = 2
            a = 3
            a = 4
            a = 5
          end
          a = 1
          a = 2
          a = 3
          a = 4
          a = 5
          a = 6
        end
      RUBY
    end
  end

  context 'when CountComments is disabled' do
    it 'accepts classes that only contain comments' do
      expect_no_offenses(<<~RUBY)
        class Test
          # comment
          # comment
          # comment
          # comment
          # comment
          # comment
        end
      RUBY
    end
  end

  context 'when CountComments is enabled' do
    before { cop_config['CountComments'] = true }

    it 'also counts commented lines' do
      expect_offense(<<~RUBY)
        class Test
        ^^^^^^^^^^ Class has too many lines. [6/5]
          a = 1
          #a = 2
          a = 3
          #a = 4
          a = 5
          a = 6
        end
      RUBY
    end

    it 'registers an offense for a class that only contains comments' do
      expect_offense(<<~RUBY)
        class Test
        ^^^^^^^^^^ Class has too many lines. [6/5]
          # comment
          # comment
          # comment
          # comment
          # comment
          # comment
        end
      RUBY
    end
  end

  context 'when `CountAsOne` is not empty' do
    before { cop_config['CountAsOne'] = ['array'] }

    it 'folds array into one line' do
      expect_no_offenses(<<~RUBY)
        class Test
          a = 1
          a = [
            2,
            3,
            4,
            5
          ]
        end
      RUBY
    end
  end

  context 'when overlapping constant assignments' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        X = Y = Z = do_something
      RUBY
    end
  end

  context 'when singleton class' do
    it 'rejects a class with more than 5 lines' do
      expect_offense(<<~RUBY)
        class << self
        ^^^^^^^^^^^^^ Class has too many lines. [6/5]
          a = 1
          a = 2
          a = 3
          a = 4
          a = 5
          a = 6
        end
      RUBY
    end

    it 'accepts a class with 5 lines' do
      expect_no_offenses(<<~RUBY)
        class << self
          a = 1
          a = 2
          a = 3
          a = 4
          a = 5
        end
      RUBY
    end
  end

  context 'when inspecting a class defined with Class.new' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        Foo = Class.new do
              ^^^^^^^^^^^^ Class has too many lines. [6/5]
          a = 1
          a = 2
          a = 3
          a = 4
          a = 5
          a = 6
        end
      RUBY
    end
  end

  context 'when inspecting a class defined with ::Class.new' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        Foo = ::Class.new do
              ^^^^^^^^^^^^^^ Class has too many lines. [6/5]
          a = 1
          a = 2
          a = 3
          a = 4
          a = 5
          a = 6
        end
      RUBY
    end
  end

  context 'when inspecting a class defined with Struct.new' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        Foo = Struct.new(:foo, :bar) do
              ^^^^^^^^^^^^^^^^^^^^^^^^^ Class has too many lines. [6/5]
          a = 1
          a = 2
          a = 3
          a = 4
          a = 5
          a = 6
        end
      RUBY
    end

    it 'registers an offense when inspecting or equals (`||=`) for constant' do
      expect_offense(<<~RUBY)
        Foo ||= Struct.new(:foo, :bar) do
                ^^^^^^^^^^^^^^^^^^^^^^^^^ Class has too many lines. [6/5]
          a = 1
          a = 2
          a = 3
          a = 4
          a = 5
          a = 6
        end
      RUBY
    end

    it 'registers an offense when multiple assignments to constants' do
      # `Bar` is always nil, but syntax is valid.
      expect_offense(<<~RUBY)
        Foo, Bar = Struct.new(:foo, :bar) do
                   ^^^^^^^^^^^^^^^^^^^^^^^^^ Class has too many lines. [6/5]
          a = 1
          a = 2
          a = 3
          a = 4
          a = 5
          a = 6
        end
      RUBY
    end
  end

  context 'when using numbered parameter', :ruby27 do
    context 'when inspecting a class defined with Class.new' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          Foo = Class.new do
                ^^^^^^^^^^^^ Class has too many lines. [6/5]
            a(_1)
            b(_1)
            c(_1)
            d(_1)
            e(_1)
            f(_1)
          end
        RUBY
      end
    end

    context 'when inspecting a class defined with ::Class.new' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          Foo = ::Class.new do
                ^^^^^^^^^^^^^^ Class has too many lines. [6/5]
            a(_1)
            b(_1)
            c(_1)
            d(_1)
            e(_1)
            f(_1)
          end
        RUBY
      end
    end

    context 'when inspecting a class defined with Struct.new' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          Foo = Struct.new(:foo, :bar) do
                ^^^^^^^^^^^^^^^^^^^^^^^^^ Class has too many lines. [6/5]
            a(_1)
            b(_1)
            c(_1)
            d(_1)
            e(_1)
            f(_1)
          end
        RUBY
      end

      it 'registers an offense when inspecting or equals (`||=`) for constant' do
        expect_offense(<<~RUBY)
          Foo ||= Struct.new(:foo, :bar) do
                  ^^^^^^^^^^^^^^^^^^^^^^^^^ Class has too many lines. [6/5]
            a(_1)
            b(_1)
            c(_1)
            d(_1)
            e(_1)
            f(_1)
          end
        RUBY
      end

      it 'registers an offense when multiple assignments to constants' do
        # `Bar` is always nil, but syntax is valid.
        expect_offense(<<~RUBY)
          Foo, Bar = Struct.new(:foo, :bar) do
                     ^^^^^^^^^^^^^^^^^^^^^^^^^ Class has too many lines. [6/5]
            a(_1)
            b(_1)
            c(_1)
            d(_1)
            e(_1)
            f(_1)
          end
        RUBY
      end
    end
  end
end
