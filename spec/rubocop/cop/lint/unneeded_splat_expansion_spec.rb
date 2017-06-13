# frozen_string_literal: true

describe RuboCop::Cop::Lint::UnneededSplatExpansion do
  subject(:cop) { described_class.new }
  let(:message) { 'Unnecessary splat expansion.' }
  let(:array_param_message) { 'Pass array contents as separate arguments.' }

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
    expect_no_offenses(<<-RUBY.strip_indent)
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

        expect(cop.messages).to eq([array_param_message])
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
    it 'registers an offense for an array using a constructor' do
      expect_offense(<<-RUBY.strip_indent)
        a = *Array.new(3) { 42 }
            ^^^^^^^^^^^^^^^^^^^^ Unnecessary splat expansion.
      RUBY
    end
  end

  context 'expanding an array literal in a when condition' do
    it 'registers an offense for an array using []' do
      expect_offense(<<-RUBY.strip_indent)
        case foo
        when *[first, second]
             ^^^^^^^^^^^^^^^^ Unnecessary splat expansion.
          bar
        end
      RUBY
    end

    it 'registers an offense for an array using %w' do
      expect_offense(<<-RUBY.strip_indent)
        case foo
        when *%w(first second)
             ^^^^^^^^^^^^^^^^^ Unnecessary splat expansion.
          bar
        end
      RUBY
    end

    it 'registers an offense for an array using %W' do
      expect_offense(<<-'RUBY'.strip_indent)
        case foo
        when *%W(#{first} second)
             ^^^^^^^^^^^^^^^^^^^^ Unnecessary splat expansion.
          bar
        end
      RUBY
    end

    it 'allows an array that is assigned to a variable' do
      expect_no_offenses(<<-RUBY.strip_indent)
        baz = [1, 2, 3]
        case foo
        when *baz
          bar
        end
      RUBY
    end

    it 'allows an array using a constructor' do
      expect_no_offenses(<<-RUBY.strip_indent)
        case foo
        when *Array.new(3) { 42 }
          bar
        end
      RUBY
    end
  end

  it 'registers an offense for an array literal being expanded in a rescue' do
    expect_offense(<<-RUBY.strip_indent)
      begin
        foo
      rescue *[First, Second]
             ^^^^^^^^^^^^^^^^ Unnecessary splat expansion.
        bar
      end
    RUBY
  end

  it 'allows expansions of an array that is assigned to a variable in rescue' do
    expect_no_offenses(<<-RUBY.strip_indent)
      ERRORS = [FirstError, SecondError]
      begin
        foo
      rescue *ERRORS
        bar
      end
    RUBY
  end

  it 'allows an array using a constructor' do
    expect_no_offenses(<<-RUBY.strip_indent)
      begin
        foo
      rescue *Array.new(3) { 42 }
        bad_example
      end
    RUBY
  end

  it 'registers an offense for the expansion of an array literal' \
    'inside of an array literal' do
    inspect_source('[1, 2, *[3, 4, 5], 6, 7]')

    expect(cop.messages).to eq([array_param_message])
    expect(cop.highlights).to eq(['*[3, 4, 5]'])
  end

  it 'allows expanding a method call on an array literal' do
    expect_no_offenses('[1, 2, *[3, 4, 5].map(&:to_s), 6, 7]')
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

    context 'splat expansion in when condition' do
      it 'removes the square brackets' do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          case foo
          when *[1, 2, 3]
            bar
          end
        RUBY

        expect(new_source).to eq(<<-RUBY.strip_indent)
          case foo
          when 1, 2, 3
            bar
          end
        RUBY
      end

      it 'changes %w to a list of words' do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          case foo
          when *%w(one two three)
            bar
          end
        RUBY

        expect(new_source).to eq(<<-RUBY.strip_indent)
          case foo
          when 'one', 'two', 'three'
            bar
          end
        RUBY
      end

      it 'changes %W to a list of words' do
        new_source = autocorrect_source(<<-'RUBY'.strip_indent)
          case foo
          when *%W(one #{two} three)
            bar
          end
        RUBY

        expect(new_source).to eq(<<-'RUBY'.strip_indent)
          case foo
          when "one", "#{two}", "three"
            bar
          end
        RUBY
      end
    end

    context 'rescuing splat expansion' do
      it 'changes an array literal to a list of constants' do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          begin
            foo
          rescue *[First, Second]
            bar
          end
        RUBY

        expect(new_source).to eq(<<-RUBY.strip_indent)
          begin
            foo
          rescue First, Second
            bar
          end
        RUBY
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

    context 'splat expansion inside of an array' do
      it 'removes the splat and brackets from []' do
        new_source = autocorrect_source('[1, 2, *[3, 4, 5], 6, 7]')

        expect(new_source).to eq('[1, 2, 3, 4, 5, 6, 7]')
      end

      it 'changes %w to a list of words' do
        new_source = autocorrect_source("['a', 'b', *%w(c d e), 'f', 'g']")

        expect(new_source).to eq("['a', 'b', 'c', 'd', 'e', 'f', 'g']")
      end

      it 'changes %W to a list of words' do
        new_source = autocorrect_source('["a", "b", *%W(#{one} two)]')

        expect(new_source).to eq('["a", "b", "#{one}", "two"]')
      end
    end
  end

  context 'ruby >= 2.0', :ruby20 do
    it_behaves_like 'array splat expansion', '%i(first second)'
    it_behaves_like 'array splat expansion', '%I(first second #{third})'

    context 'arrays being expanded with %i variants using splat expansion' do
      it 'registers an offense for an array literal being expanded in a ' \
        'when condition' do
        inspect_source(<<-'RUBY'.strip_indent)
          case foo
          when *%i(first second)
            bar
          when *%I(#{first} second)
            baz
          end
        RUBY

        expect(cop.offenses.size).to eq(2)
        expect(cop.highlights).to eq(['*%i(first second)',
                                      '*%I(#{first} second)'])
      end

      context 'splat expansion of method parameters' do
        it 'registers an offense for an array literal %i' do
          expect_offense(<<-RUBY.strip_indent)
            array.push(*%i(first second))
                       ^^^^^^^^^^^^^^^^^ Pass array contents as separate arguments.
          RUBY
        end

        it 'registers an offense for an array literal %I' do
          expect_offense(<<-'RUBY'.strip_indent)
            array.push(*%I(#{first} second))
                       ^^^^^^^^^^^^^^^^^^^^ Pass array contents as separate arguments.
          RUBY
        end
      end

      context 'autocorrect' do
        it 'changes %i to a list of symbols' do
          new_source = autocorrect_source(<<-RUBY.strip_indent)
            case foo
            when *%i(first second)
              baz
            end
          RUBY

          expect(new_source).to eq(<<-RUBY.strip_indent)
            case foo
            when :first, :second
              baz
            end
          RUBY
        end

        it 'changes %I to a list of symbols' do
          new_source = autocorrect_source(<<-'RUBY'.strip_indent)
            case foo
            when *%I(#{first} second)
              baz
            end
          RUBY

          expect(new_source).to eq(<<-'RUBY'.strip_indent)
            case foo
            when :"#{first}", :"second"
              baz
            end
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
end
