# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::UnneededSplatExpansion do
  subject(:cop) { described_class.new }

  let(:message) { 'Replace splat expansion with comma separated values.' }

  it 'allows assigning to a splat' do
    expect_no_offenses('*, rhs = *node')
  end

  it 'allows assigning to a splat variable' do
    expect_no_offenses('lhs, *args = *node')
  end

  it 'allows assigning a variable to a splat expansion of a variable' do
    expect_no_offenses('a = *b')
  end

  it 'allows assigning to an expanded range' do
    expect_no_offenses('a = *1..10')
  end

  it 'allows splat expansion inside of an array' do
    expect_no_offenses('a = [10, 11, *1..9]')
  end

  it 'accepts expanding a variable as a method parameter' do
    expect_no_offenses(<<~RUBY)
      foo = [1, 2, 3]
      array.push(*foo)
    RUBY
  end

  shared_examples 'splat literal assignment' do |literal|
    it 'registers an offense for ' do
      inspect_source("a = *#{literal}")

      expect(cop.messages).to eq([message])
      expect(cop.highlights).to eq(["*#{literal}"])
    end
  end

  shared_examples 'array splat expansion' do |literal|
    context 'method parameters' do
      it 'registers an offense' do
        inspect_source("array.push(*#{literal})")

        expect(cop.messages)
          .to eq(['Pass array contents as separate arguments.'])
        expect(cop.highlights).to eq(["*#{literal}"])
      end
    end

    it_behaves_like 'splat literal assignment', literal
  end

  shared_examples 'splat expansion' do |literal|
    context 'method parameters' do
      it 'registers an offense' do
        inspect_source("array.push(*#{literal})")

        expect(cop.messages).to eq([message])
        expect(cop.highlights).to eq(["*#{literal}"])
      end
    end

    it_behaves_like 'splat literal assignment', literal
  end

  it_behaves_like 'array splat expansion', '[1, 2, 3]'
  it_behaves_like 'array splat expansion', '%w(one two three)'
  it_behaves_like 'array splat expansion', '%W(one #{two} three)'
  it_behaves_like 'splat expansion', "'a'"
  it_behaves_like 'splat expansion', '"#{a}"'
  it_behaves_like 'splat expansion', '1'
  it_behaves_like 'splat expansion', '1.1'

  context 'assignment to splat expansion' do
    it 'registers an offense and corrects an array using a constructor' do
      expect_offense(<<~RUBY)
        a = *Array.new(3) { 42 }
            ^^^^^^^^^^^^^^^^^^^^ Replace splat expansion with comma separated values.
      RUBY

      expect_correction(<<~RUBY)
        a = Array.new(3) { 42 }
      RUBY
    end
  end

  context 'expanding an array literal in a when condition' do
    it 'registers an offense and corrects an array using []' do
      expect_offense(<<~RUBY)
        case foo
        when *[first, second]
             ^^^^^^^^^^^^^^^^ Replace splat expansion with comma separated values.
          bar
        end
      RUBY

      expect_correction(<<~RUBY)
        case foo
        when first, second
          bar
        end
      RUBY
    end

    it 'registers an offense and corrects an array using %w' do
      expect_offense(<<~RUBY)
        case foo
        when *%w(first second)
             ^^^^^^^^^^^^^^^^^ Replace splat expansion with comma separated values.
          bar
        end
      RUBY

      expect_correction(<<~RUBY)
        case foo
        when 'first', 'second'
          bar
        end
      RUBY
    end

    it 'registers an offense and corrects an array using %W' do
      expect_offense(<<~RUBY)
        case foo
        when *%W(\#{first} second)
             ^^^^^^^^^^^^^^^^^^^^ Replace splat expansion with comma separated values.
          bar
        end
      RUBY

      expect_correction(<<~RUBY)
        case foo
        when "\#{first}", "second"
          bar
        end
      RUBY
    end

    it 'registers an offense and corrects %i to a list of symbols' do
      expect_offense(<<~RUBY)
        case foo
        when *%i(first second)
             ^^^^^^^^^^^^^^^^^ Replace splat expansion with comma separated values.
          baz
        end
      RUBY

      expect_correction(<<~RUBY)
        case foo
        when :first, :second
          baz
        end
      RUBY
    end

    it 'registers an offense and corrects %I to a list of symbols' do
      expect_offense(<<~RUBY)
        case foo
        when *%I(\#{first} second)
             ^^^^^^^^^^^^^^^^^^^^ Replace splat expansion with comma separated values.
          baz
        end
      RUBY

      expect_correction(<<~RUBY)
        case foo
        when :"\#{first}", :"second"
          baz
        end
      RUBY
    end

    it 'allows an array that is assigned to a variable' do
      expect_no_offenses(<<~RUBY)
        baz = [1, 2, 3]
        case foo
        when *baz
          bar
        end
      RUBY
    end

    it 'allows an array using a constructor' do
      expect_no_offenses(<<~RUBY)
        case foo
        when *Array.new(3) { 42 }
          bar
        end
      RUBY
    end
  end

  it 'registers an offense and corrects an array literal ' \
    'being expanded in a rescue' do
    expect_offense(<<~RUBY)
      begin
        foo
      rescue *[First, Second]
             ^^^^^^^^^^^^^^^^ Replace splat expansion with comma separated values.
        bar
      end
    RUBY

    expect_correction(<<~RUBY)
      begin
        foo
      rescue First, Second
        bar
      end
    RUBY
  end

  it 'allows expansions of an array that is assigned to a variable in rescue' do
    expect_no_offenses(<<~RUBY)
      ERRORS = [FirstError, SecondError]
      begin
        foo
      rescue *ERRORS
        bar
      end
    RUBY
  end

  it 'allows an array using a constructor' do
    expect_no_offenses(<<~RUBY)
      begin
        foo
      rescue *Array.new(3) { 42 }
        bad_example
      end
    RUBY
  end

  context 'splat expansion inside of an array' do
    it 'registers an offense and corrects the expansion of an array literal' \
      'inside of an array literal' do
      expect_offense(<<~RUBY)
        [1, 2, *[3, 4, 5], 6, 7]
               ^^^^^^^^^^ Pass array contents as separate arguments.
      RUBY

      expect_correction(<<~RUBY)
        [1, 2, 3, 4, 5, 6, 7]
      RUBY
    end

    it 'registers an offense and corrects expansion of %w to a list of words' do
      expect_offense(<<~RUBY)
        ['a', 'b', *%w(c d e), 'f', 'g']
                   ^^^^^^^^^^ Pass array contents as separate arguments.
      RUBY

      expect_correction(<<~RUBY)
        ['a', 'b', 'c', 'd', 'e', 'f', 'g']
      RUBY
    end

    it 'registers an offense and corrects expansion of %W to a list of words' do
      expect_offense(<<~RUBY)
        ["a", "b", *%W(\#{one} two)]
                   ^^^^^^^^^^^^^^^ Pass array contents as separate arguments.
      RUBY

      expect_correction(<<~RUBY)
        ["a", "b", "\#{one}", "two"]
      RUBY
    end
  end

  it 'allows expanding a method call on an array literal' do
    expect_no_offenses('[1, 2, *[3, 4, 5].map(&:to_s), 6, 7]')
  end

  describe 'expanding Array.new call on array literal' do
    context 'when the array literal contains exactly one element' do
      it 'registers an offense and corrects' do
        expect_offense(<<~RUBY)
          [*Array.new(foo)]
           ^^^^^^^^^^^^^^^ Replace splat expansion with comma separated values.
        RUBY

        expect_correction(<<~RUBY)
          Array.new(foo)
        RUBY
      end
    end

    context 'when the array literal contains more than one element' do
      it 'accepts' do
        expect_no_offenses('[1, 2, *Array.new(foo), 6]')
      end
    end
  end

  context 'autocorrect' do
    context 'assignment to a splat expanded variable' do
      it 'removes the splat from an array using []' do
        new_source = autocorrect_source('a = *[1, 2, 3]')

        expect(new_source).to eq('a = [1, 2, 3]')
      end

      it 'removes the splat from an array using %w' do
        new_source = autocorrect_source('a = *%w(one two three)')

        expect(new_source).to eq('a = %w(one two three)')
      end

      it 'removes the splat from an array using %W' do
        new_source = autocorrect_source('a = *%W(one two three)')

        expect(new_source).to eq('a = %W(one two three)')
      end

      it 'converts an expanded string to an array' do
        new_source = autocorrect_source("a = *'a'")

        expect(new_source).to eq("a = ['a']")
      end

      it 'converts an expanded string with interpolation to an array' do
        new_source = autocorrect_source('a = *"#{a}"')

        expect(new_source).to eq('a = ["#{a}"]')
      end

      it 'converts an expanded integer to an array' do
        new_source = autocorrect_source('a = *1')

        expect(new_source).to eq('a = [1]')
      end

      it 'converts an expanded float to an array' do
        new_source = autocorrect_source('a = *1.1')

        expect(new_source).to eq('a = [1.1]')
      end
    end

    context 'splat expansion of method parameters' do
      it 'removes the splat and brackets from []' do
        new_source = autocorrect_source('foo(*[1, 2, 3])')

        expect(new_source).to eq('foo(1, 2, 3)')
      end

      it 'changes %w to a list of words' do
        new_source = autocorrect_source('foo(*%w(one two three))')

        expect(new_source).to eq("foo('one', 'two', 'three')")
      end

      it 'changes %W to a list of words' do
        new_source = autocorrect_source('foo(*%W(#{one} two three))')

        expect(new_source).to eq('foo("#{one}", "two", "three")')
      end
    end
  end

  it_behaves_like 'array splat expansion', '%i(first second)'
  it_behaves_like 'array splat expansion', '%I(first second #{third})'

  context 'arrays being expanded with %i variants using splat expansion' do
    context 'splat expansion of method parameters' do
      it 'registers an offense and corrects an array literal %i' do
        expect_offense(<<~RUBY)
          array.push(*%i(first second))
                     ^^^^^^^^^^^^^^^^^ Pass array contents as separate arguments.
        RUBY

        expect_correction(<<~RUBY)
          array.push(:first, :second)
        RUBY
      end

      it 'registers an offense and corrects an array literal %I' do
        expect_offense(<<~RUBY)
          array.push(*%I(\#{first} second))
                     ^^^^^^^^^^^^^^^^^^^^ Pass array contents as separate arguments.
        RUBY

        expect_correction(<<~RUBY)
          array.push(:"\#{first}", :"second")
        RUBY
      end
    end

    context 'splat expansion inside of an array' do
      it 'changes %i to a list of symbols' do
        new_source = autocorrect_source('[:a, :b, *%i(c d), :e]')

        expect(new_source).to eq('[:a, :b, :c, :d, :e]')
      end

      it 'changes %I to a list of symbols' do
        new_source = autocorrect_source('[:a, :b, *%I(#{one} two), :e]')

        expect(new_source).to eq('[:a, :b, :"#{one}", :"two", :e]')
      end
    end
  end
end
