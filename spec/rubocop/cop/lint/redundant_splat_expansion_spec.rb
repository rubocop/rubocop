# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::RedundantSplatExpansion, :config do
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

  shared_examples 'splat literal assignment' do |literal, corrects, as_array: literal|
    it "registers an offense and #{corrects}" do
      expect_offense(<<~RUBY, literal: literal)
        a = *%{literal}
            ^^{literal} Replace splat expansion with comma separated values.
      RUBY

      expect_correction(<<~RUBY)
        a = #{as_array}
      RUBY
    end
  end

  shared_examples 'array splat expansion' do |literal, as_args: nil|
    context 'method parameters' do
      it 'registers an offense and converts to a list of arguments' do
        expect_offense(<<~RUBY, literal: literal)
          array.push(*%{literal})
                     ^^{literal} Pass array contents as separate arguments.
        RUBY

        expect_correction(<<~RUBY)
          array.push(#{as_args})
        RUBY
      end
    end

    it_behaves_like 'splat literal assignment', literal,
                    'removes the splat from array', as_array: literal
  end

  shared_examples 'splat expansion' do |literal, as_array: literal|
    context 'method parameters' do
      it 'registers an offense and converts to an array' do
        expect_offense(<<~RUBY, literal: literal)
          array.push(*%{literal})
                     ^^{literal} Replace splat expansion with comma separated values.
        RUBY

        expect_correction(<<~RUBY)
          array.push(#{as_array})
        RUBY
      end
    end

    it_behaves_like 'splat literal assignment', literal, 'converts to an array', as_array: as_array
  end

  it_behaves_like 'array splat expansion', '[1, 2, 3]', as_args: '1, 2, 3'
  it_behaves_like 'splat expansion', "'a'", as_array: "['a']"
  it_behaves_like 'splat expansion', '"#{a}"', as_array: '["#{a}"]'
  it_behaves_like 'splat expansion', '1', as_array: '[1]'
  it_behaves_like 'splat expansion', '1.1', as_array: '[1.1]'

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

    it 'registers and corrects an array using top-level const' do
      expect_offense(<<~RUBY)
        a = *::Array.new(3) { 42 }
            ^^^^^^^^^^^^^^^^^^^^^^ Replace splat expansion with comma separated values.
      RUBY

      expect_correction(<<~RUBY)
        a = ::Array.new(3) { 42 }
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

  it 'registers an offense and corrects an array literal being expanded in a rescue' do
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

    context 'with ::Array.new' do
      context 'when the array literal contains exactly one element' do
        it 'registers an offense and corrects' do
          expect_offense(<<~RUBY)
            [*::Array.new(foo)]
             ^^^^^^^^^^^^^^^^^ Replace splat expansion with comma separated values.
          RUBY

          expect_correction(<<~RUBY)
            ::Array.new(foo)
          RUBY
        end
      end
    end
  end

  describe 'expanding Array.new call on method argument' do
    it 'registers an offense and corrects' do
      expect_offense(<<~RUBY)
        send(method, *Array.new(foo))
                     ^^^^^^^^^^^^^^^ Replace splat expansion with comma separated values.
      RUBY

      expect_correction(<<~RUBY)
        send(method, Array.new(foo))
      RUBY
    end
  end

  context 'arrays being expanded with %i variants using splat expansion' do
    context 'splat expansion inside of an array' do
      it 'registers an offense and corrects %i to a list of symbols' do
        expect_offense(<<~RUBY)
          [:a, :b, *%i(c d), :e]
                   ^^^^^^^^ Pass array contents as separate arguments.
        RUBY

        expect_correction(<<~RUBY)
          [:a, :b, :c, :d, :e]
        RUBY
      end

      it 'registers an offense and changes %I to a list of symbols' do
        expect_offense(<<~'RUBY')
          [:a, :b, *%I(#{one} two), :e]
                   ^^^^^^^^^^^^^^^ Pass array contents as separate arguments.
        RUBY

        expect_correction(<<~'RUBY')
          [:a, :b, :"#{one}", :"two", :e]
        RUBY
      end
    end
  end

  context 'when `AllowPercentLiteralArrayArgument: true`' do
    let(:cop_config) { { 'AllowPercentLiteralArrayArgument' => true } }

    it 'does not register an offense when using percent string literal array' do
      expect_no_offenses(<<~RUBY)
        do_something(*%w[foo bar baz])
      RUBY
    end

    it 'does not register an offense when using percent symbol literal array' do
      expect_no_offenses(<<~RUBY)
        do_something(*%i[foo bar baz])
      RUBY
    end
  end

  context 'when `AllowPercentLiteralArrayArgument: false`' do
    let(:cop_config) { { 'AllowPercentLiteralArrayArgument' => false } }

    it_behaves_like 'array splat expansion', '%w(one two three)', as_args: "'one', 'two', 'three'"
    it_behaves_like 'array splat expansion', '%W(one #{two} three)', as_args: '"one", "#{two}", "three"'

    it 'registers an offense when using percent literal array' do
      expect_offense(<<~RUBY)
        do_something(*%w[foo bar baz])
                     ^^^^^^^^^^^^^^^^ Pass array contents as separate arguments.
      RUBY
    end

    it_behaves_like 'array splat expansion', '%i(first second)', as_args: ':first, :second'
    it_behaves_like 'array splat expansion', '%I(first second #{third})', as_args: ':"first", :"second", :"#{third}"'

    it 'registers an offense when using percent symbol literal array' do
      expect_offense(<<~RUBY)
        do_something(*%i[foo bar baz])
                     ^^^^^^^^^^^^^^^^ Pass array contents as separate arguments.
      RUBY
    end

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
  end
end
