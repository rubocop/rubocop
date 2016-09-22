# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Lint::UnneededSplatExpansion do
  subject(:cop) { described_class.new }
  let(:message) { 'Unnecessary splat expansion.' }
  let(:array_param_message) { 'Pass array contents as separate arguments.' }

  it 'allows assigning to a splat' do
    inspect_source(cop, '*, rhs = *node')

    expect(cop.offenses).to be_empty
  end

  it 'allows assigning to a splat variable' do
    inspect_source(cop, 'lhs, *args = *node')

    expect(cop.offenses).to be_empty
  end

  it 'allows assigning a variable to a splat expansion of a variable' do
    inspect_source(cop, 'a = *b')

    expect(cop.offenses).to be_empty
  end

  it 'allows assigning to an expanded range' do
    inspect_source(cop, 'a = *1..10')

    expect(cop.offenses).to be_empty
  end

  it 'allows splat expansion inside of an array' do
    inspect_source(cop, 'a = [10, 11, *1..9]')

    expect(cop.offenses).to be_empty
  end

  it 'accepts expanding a variable as a method parameter' do
    inspect_source(cop, ['foo = [1, 2, 3]',
                         'array.push(*foo)'])

    expect(cop.offenses).to be_empty
  end

  shared_examples 'splat literal assignment' do |literal|
    it 'registers an offense for ' do
      inspect_source(cop, "a = *#{literal}")

      expect(cop.messages).to eq([message])
      expect(cop.highlights).to eq(["*#{literal}"])
    end
  end

  shared_examples 'array splat expansion' do |literal|
    context 'method parameters' do
      it 'registers an offense' do
        inspect_source(cop, "array.push(*#{literal})")

        expect(cop.messages).to eq([array_param_message])
        expect(cop.highlights).to eq(["*#{literal}"])
      end
    end

    it_behaves_like 'splat literal assignment', literal
  end

  shared_examples 'splat expansion' do |literal|
    context 'method parameters' do
      it 'registers an offense' do
        inspect_source(cop, "array.push(*#{literal})")

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
      inspect_source(cop, 'a = *Array.new(3) { 42 }')

      expect(cop.messages).to eq([message])
      expect(cop.highlights).to eq(['*Array.new(3) { 42 }'])
    end
  end

  context 'expanding an array literal in a when condition' do
    it 'registers an offense for an array using []' do
      inspect_source(cop, ['case foo',
                           'when *[first, second]',
                           '  bar',
                           'end'])

      expect(cop.messages).to eq([message])
      expect(cop.highlights).to eq(['*[first, second]'])
    end

    it 'registers an offense for an array using %w' do
      inspect_source(cop, ['case foo',
                           'when *%w(first second)',
                           '  bar',
                           'end'])

      expect(cop.messages).to eq([message])
      expect(cop.highlights).to eq(['*%w(first second)'])
    end

    it 'registers an offense for an array using %W' do
      inspect_source(cop, ['case foo',
                           'when *%W(#{first} second)',
                           '  bar',
                           'end'])

      expect(cop.messages).to eq([message])
      expect(cop.highlights).to eq(['*%W(#{first} second)'])
    end

    it 'allows an array that is assigned to a variable' do
      inspect_source(cop, ['baz = [1, 2, 3]',
                           'case foo',
                           'when *baz',
                           '  bar',
                           'end'])

      expect(cop.offenses).to be_empty
    end

    it 'allows an array using a constructor' do
      inspect_source(cop, ['case foo',
                           'when *Array.new(3) { 42 }',
                           '  bar',
                           'end'])

      expect(cop.offenses).to be_empty
    end
  end

  it 'registers an offense for an array literal being expanded in a rescue' do
    inspect_source(cop, ['begin',
                         '  foo',
                         'rescue *[First, Second]',
                         '  bar',
                         'end'])

    expect(cop.messages).to eq([message])
    expect(cop.highlights).to eq(['*[First, Second]'])
  end

  it 'allows expansions of an array that is assigned to a variable in rescue' do
    inspect_source(cop, ['ERRORS = [FirstError, SecondError]',
                         'begin',
                         '  foo',
                         'rescue *ERRORS',
                         '  bar',
                         'end'])

    expect(cop.offenses).to be_empty
  end

  it 'allows an array using a constructor' do
    inspect_source(cop, ['begin',
                         '  foo',
                         'rescue *Array.new(3) { 42 }',
                         '  bad_example',
                         'end'])

    expect(cop.offenses).to be_empty
  end

  context 'autocorrect' do
    context 'assignment to a splat expanded variable' do
      it 'removes the splat from an array using []' do
        new_source = autocorrect_source(cop, 'a = *[1, 2, 3]')

        expect(new_source).to eq('a = [1, 2, 3]')
      end

      it 'removes the splat from an array using %w' do
        new_source = autocorrect_source(cop, 'a = *%w(one two three)')

        expect(new_source).to eq('a = %w(one two three)')
      end

      it 'removes the splat from an array using %W' do
        new_source = autocorrect_source(cop, 'a = *%W(one two three)')

        expect(new_source).to eq('a = %W(one two three)')
      end

      it 'convert an expanded string to an array' do
        new_source = autocorrect_source(cop, "a = *'a'")

        expect(new_source).to eq("a = ['a']")
      end

      it 'convert an expanded string to an array' do
        new_source = autocorrect_source(cop, 'a = *"#{a}"')

        expect(new_source).to eq('a = ["#{a}"]')
      end

      it 'convert an expanded string to an array' do
        new_source = autocorrect_source(cop, 'a = *1')

        expect(new_source).to eq('a = [1]')
      end

      it 'convert an expanded string to an array' do
        new_source = autocorrect_source(cop, 'a = *1.1')

        expect(new_source).to eq('a = [1.1]')
      end
    end

    context 'splat expansion in when condition' do
      it 'removes the square brackets' do
        new_source = autocorrect_source(cop, ['case foo',
                                              'when *[1, 2, 3]',
                                              '  bar',
                                              'end'])

        expect(new_source).to eq(['case foo',
                                  'when 1, 2, 3',
                                  '  bar',
                                  'end'].join("\n"))
      end

      it 'changes %w to a list of words' do
        new_source = autocorrect_source(cop, ['case foo',
                                              'when *%w(one two three)',
                                              '  bar',
                                              'end'])

        expect(new_source).to eq(['case foo',
                                  "when 'one', 'two', 'three'",
                                  '  bar',
                                  'end'].join("\n"))
      end

      it 'changes %W to a list of words' do
        new_source = autocorrect_source(cop, ['case foo',
                                              'when *%W(one #{two} three)',
                                              '  bar',
                                              'end'])

        expect(new_source).to eq(['case foo',
                                  'when "one", "#{two}", "three"',
                                  '  bar',
                                  'end'].join("\n"))
      end
    end

    context 'rescuing splat expansion' do
      it 'changes an array literal to a list of constants' do
        new_source = autocorrect_source(cop, ['begin',
                                              '  foo',
                                              'rescue *[First, Second]',
                                              '  bar',
                                              'end'])

        expect(new_source).to eq(['begin',
                                  '  foo',
                                  'rescue First, Second',
                                  '  bar',
                                  'end'].join("\n"))
      end
    end

    context 'splat expansion of method parameters' do
      it 'removes the splat and brackets from []' do
        new_source = autocorrect_source(cop, 'foo(*[1, 2, 3])')

        expect(new_source).to eq('foo(1, 2, 3)')
      end

      it 'changes %w to a list of words' do
        new_source = autocorrect_source(cop, 'foo(*%w(one two three))')

        expect(new_source).to eq("foo('one', 'two', 'three')")
      end

      it 'changes %W to a list of words' do
        new_source = autocorrect_source(cop, 'foo(*%W(#{one} two three))')

        expect(new_source).to eq('foo("#{one}", "two", "three")')
      end
    end
  end

  context 'ruby >= 2.0', :ruby20 do
    it_behaves_like 'array splat expansion', '%i(first second)'
    it_behaves_like 'array splat expansion', '%I(first second #{third})'

    context 'arrays being expanded with %i variants using splat expansion' do
      it 'registers an offense for an array literal being expanded in a ' \
        'when condition' do
        inspect_source(cop, ['case foo',
                             'when *%i(first second)',
                             '  bar',
                             'when *%I(#{first} second)',
                             '  baz',
                             'end'])

        expect(cop.offenses.size).to eq(2)
        expect(cop.highlights).to eq(['*%i(first second)',
                                      '*%I(#{first} second)'])
      end

      context 'splat expansion of method parameters' do
        it 'registers an offense for an array literal %i' do
          inspect_source(cop, 'array.push(*%i(first second))')

          expect(cop.messages).to eq([array_param_message])
          expect(cop.highlights).to eq(['*%i(first second)'])
        end

        it 'registers an offense for an array literal %I' do
          inspect_source(cop, 'array.push(*%I(#{first} second))')

          expect(cop.messages).to eq([array_param_message])
          expect(cop.highlights).to eq(['*%I(#{first} second)'])
        end
      end

      context 'autocorrect' do
        it 'changes %i to a list of symbols' do
          new_source = autocorrect_source(cop, ['case foo',
                                                'when *%i(first second)',
                                                '  baz',
                                                'end'])

          expect(new_source).to eq(['case foo',
                                    'when :first, :second',
                                    '  baz',
                                    'end'].join("\n"))
        end

        it 'changes %I to a list of symbols' do
          new_source = autocorrect_source(cop, ['case foo',
                                                'when *%I(#{first} second)',
                                                '  baz',
                                                'end'])

          expect(new_source).to eq(['case foo',
                                    'when :"#{first}", :"second"',
                                    '  baz',
                                    'end'].join("\n"))
        end
      end
    end
  end
end
