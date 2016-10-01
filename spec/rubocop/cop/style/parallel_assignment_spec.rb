# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::ParallelAssignment, :config do
  subject(:cop) { described_class.new(config) }

  let(:config) do
    RuboCop::Config.new('Style/IndentationWidth' => { 'Width' => 2 })
  end

  shared_examples('offenses') do |source|
    it "registers an offense for: #{source.gsub(/\s*\n\s*/, '; ')}" do
      inspect_source(cop, source)

      expect(cop.messages).to eq(['Do not use parallel assignment.'])
    end
  end

  it_behaves_like('offenses', 'a, b, c = 1, 2, 3')
  it_behaves_like('offenses', 'a, b, c = [1, 2, 3]')
  it_behaves_like('offenses', 'a, b, c = [1, 2], [3, 4], [5, 6]')
  it_behaves_like('offenses', 'a, b, c = {a: 1}, {b: 2}, {c: 3}')
  it_behaves_like('offenses', 'a, b, c = CONSTANT1, CONSTANT2, CONSTANT3')
  it_behaves_like('offenses', 'a, b, c = [1, 2], {a: 1}, CONSTANT3')
  it_behaves_like('offenses', 'a, b = foo(), bar()')
  it_behaves_like('offenses', 'a, b = foo { |a| puts a }, bar()')
  it_behaves_like('offenses', 'CONSTANT1, CONSTANT2 = CONSTANT3, CONSTANT4')
  it_behaves_like('offenses', 'a, b = 1, 2 if something')
  it_behaves_like('offenses', 'a, b = 1, 2 unless something')
  it_behaves_like('offenses', 'a, b = 1, 2 while something')
  it_behaves_like('offenses', 'a, b = 1, 2 until something')
  it_behaves_like('offenses', "a, b = 1, 2 rescue 'Error'")
  it_behaves_like('offenses', 'a, b = 1, a')
  it_behaves_like('offenses', 'a, b = a, b')
  it_behaves_like('offenses',
                  'a, b = foo.map { |e| e.id }, bar.map { |e| e.id }')
  it_behaves_like('offenses', ['array = [1, 2, 3]',
                               'a, b, c, = 8, 9, array'].join("\n"))
  it_behaves_like('offenses', ['if true',
                               '  a, b = 1, 2',
                               'end'].join("\n"))
  it_behaves_like('offenses', 'a, b = Float::INFINITY, Float::INFINITY')
  it_behaves_like('offenses', 'Float::INFINITY, Float::INFINITY = 1, 2')
  it_behaves_like('offenses', 'a[0], a[1] = a[1], a[2]')
  it_behaves_like('offenses', 'obj.attr1, obj.attr2 = obj.attr3, obj.attr1')
  it_behaves_like('offenses', 'obj.attr1, ary[0] = ary[1], obj.attr1')
  it_behaves_like('offenses', 'a[0], a[1] = a[1], b[0]')

  shared_examples('allowed') do |source|
    it "allows assignment of: #{source.gsub(/\s*\n\s*/, '; ')}" do
      inspect_source(cop, source)

      expect(cop.messages).to be_empty
    end
  end

  it_behaves_like('allowed', 'a = 1')
  it_behaves_like('allowed', 'a = a')
  it_behaves_like('allowed', 'a, = a')
  it_behaves_like('allowed', 'a, = 1')
  it_behaves_like('allowed', "a = *'foo'")
  it_behaves_like('allowed', "a, = *'foo'")
  it_behaves_like('allowed', 'a, = 1, 2, 3')
  it_behaves_like('allowed', 'a, = *foo')
  it_behaves_like('allowed', 'a, *b = [1, 2, 3]')
  it_behaves_like('allowed', '*a, b = [1, 2, 3]')
  it_behaves_like('allowed', 'a, b = b, a')
  it_behaves_like('allowed', 'a, b, c = b, c, a')
  it_behaves_like('allowed', 'a, b = (a + b), (a - b)')
  it_behaves_like('allowed', 'a, b = foo.map { |e| e.id }')
  it_behaves_like('allowed', 'a, b = foo()')
  it_behaves_like('allowed', 'a, b = *foo')
  it_behaves_like('allowed', 'a, b, c = 1, 2, *node')
  it_behaves_like('allowed', 'a, b, c = *node, 1, 2')
  it_behaves_like('allowed', 'begin_token, end_token = CONSTANT')
  it_behaves_like('allowed', 'CONSTANT, = 1, 2')
  it_behaves_like('allowed', ['a = 1',
                              'b = 2'].join("\n"))
  it_behaves_like('allowed', ['foo = [1, 2, 3]',
                              'a, b, c = foo'].join("\n"))
  it_behaves_like('allowed', ['array = [1, 2, 3]',
                              'a, = array'].join("\n"))
  it_behaves_like('allowed', 'a, b = Float::INFINITY')
  it_behaves_like('allowed', 'a[0], a[1] = a[1], a[0]')
  it_behaves_like('allowed', 'obj.attr1, obj.attr2 = obj.attr2, obj.attr1')
  it_behaves_like('allowed', 'obj.attr1, ary[0] = ary[0], obj.attr1')
  it_behaves_like('allowed', 'ary[0], ary[1], ary[2] = ary[1], ary[2], ary[0]')

  it 'highlights the entire expression' do
    inspect_source(cop, 'a, b = 1, 2')

    expect(cop.highlights).to eq(['a, b = 1, 2'])
  end

  it 'does not highlight the modifier statement' do
    inspect_source(cop, 'a, b = 1, 2 if true')

    expect(cop.highlights).to eq(['a, b = 1, 2'])
  end

  describe 'autocorrect' do
    it 'corrects when the number of left hand variables matches ' \
      'the number of right hand variables' do
        new_source = autocorrect_source(cop, 'a, b, c = 1, 2, 3')

        expect(new_source).to eq(['a = 1',
                                  'b = 2',
                                  'c = 3'].join("\n"))
      end

    it 'corrects when the right variable is an array' do
      new_source = autocorrect_source(cop, 'a, b, c = ["1", "2", :c]')

      expect(new_source).to eq(['a = "1"',
                                'b = "2"',
                                'c = :c'].join("\n"))
    end

    it 'corrects when the right variable is a word array' do
      new_source = autocorrect_source(cop, 'a, b, c = %w(1 2 3)')

      expect(new_source).to eq(["a = '1'",
                                "b = '2'",
                                "c = '3'"].join("\n"))
    end

    it 'corrects when the right variable is a symbol array' do
      new_source = autocorrect_source(cop, 'a, b, c = %i(a b c)')

      expect(new_source).to eq(['a = :a',
                                'b = :b',
                                'c = :c'].join("\n"))
    end

    it 'corrects when assigning to method returns' do
      new_source = autocorrect_source(cop, 'a, b = foo(), bar()')

      expect(new_source).to eq(['a = foo()',
                                'b = bar()'].join("\n"))
    end

    it 'corrects when assigning from multiple methods with blocks' do
      source = 'a, b = foo() { |c| puts c }, bar() { |d| puts d }'
      new_source = autocorrect_source(cop, source)

      expect(new_source).to eq(['a = foo() { |c| puts c }',
                                'b = bar() { |d| puts d }'].join("\n"))
    end

    it 'corrects when using constants' do
      source = 'CONSTANT1, CONSTANT2 = CONSTANT3, CONSTANT4'
      new_source = autocorrect_source(cop, source)

      expect(new_source).to eq(['CONSTANT1 = CONSTANT3',
                                'CONSTANT2 = CONSTANT4'].join("\n"))
    end

    it 'corrects when the expression is missing spaces' do
      new_source = autocorrect_source(cop, 'a,b,c=1,2,3')

      expect(new_source).to eq(['a = 1',
                                'b = 2',
                                'c = 3'].join("\n"))
    end

    it 'corrects when using single indentation' do
      new_source = autocorrect_source(cop, ['def foo',
                                            '  a, b, c = 1, 2, 3',
                                            'end'].join("\n"))

      expect(new_source).to eq(['def foo',
                                '  a = 1',
                                '  b = 2',
                                '  c = 3',
                                'end'].join("\n"))
    end

    it 'corrects when using nested indentation' do
      new_source = autocorrect_source(cop, ['def foo',
                                            '  if true',
                                            '    a, b, c = 1, 2, 3',
                                            '  end',
                                            'end'].join("\n"))

      expect(new_source).to eq(['def foo',
                                '  if true',
                                '    a = 1',
                                '    b = 2',
                                '    c = 3',
                                '  end',
                                'end'].join("\n"))
    end

    it 'corrects when the expression uses a modifier if statement' do
      new_source = autocorrect_source(cop, 'a, b = 1, 2 if foo')

      expect(new_source).to eq(['if foo',
                                '  a = 1',
                                '  b = 2',
                                'end'].join("\n"))
    end

    it 'corrects when the expression uses a modifier if statement ' \
       'inside a method' do
      new_source = autocorrect_source(cop, ['def foo',
                                            '  a, b = 1, 2 if foo',
                                            'end'])

      expect(new_source).to eq(['def foo',
                                '  if foo',
                                '    a = 1',
                                '    b = 2',
                                '  end',
                                'end'].join("\n"))
    end

    it 'corrects parallel assignment in if statements' do
      new_source = autocorrect_source(cop, ['if foo',
                                            '  a, b = 1, 2',
                                            'end'].join("\n"))

      expect(new_source).to eq(['if foo',
                                '  a = 1',
                                '  b = 2',
                                'end'].join("\n"))
    end

    it 'corrects when the expression uses a modifier unless statement' do
      new_source = autocorrect_source(cop, 'a, b = 1, 2 unless foo')

      expect(new_source).to eq(['unless foo',
                                '  a = 1',
                                '  b = 2',
                                'end'].join("\n"))
    end

    it 'corrects parallel assignment in unless statements' do
      new_source = autocorrect_source(cop, ['unless foo',
                                            '  a, b = 1, 2',
                                            'end'].join("\n"))

      expect(new_source).to eq(['unless foo',
                                '  a = 1',
                                '  b = 2',
                                'end'].join("\n"))
    end

    it 'corrects when the expression uses a modifier while statement' do
      new_source = autocorrect_source(cop, 'a, b = 1, 2 while foo')

      expect(new_source).to eq(['while foo',
                                '  a = 1',
                                '  b = 2',
                                'end'].join("\n"))
    end

    it 'corrects parallel assignment in while statements' do
      new_source = autocorrect_source(cop, ['while foo',
                                            '  a, b = 1, 2',
                                            'end'].join("\n"))

      expect(new_source).to eq(['while foo',
                                '  a = 1',
                                '  b = 2',
                                'end'].join("\n"))
    end

    it 'corrects when the expression uses a modifier until statement' do
      new_source = autocorrect_source(cop, 'a, b = 1, 2 until foo')

      expect(new_source).to eq(['until foo',
                                '  a = 1',
                                '  b = 2',
                                'end'].join("\n"))
    end

    it 'corrects parallel assignment in until statements' do
      new_source = autocorrect_source(cop, ['until foo',
                                            '  a, b = 1, 2',
                                            'end'].join("\n"))

      expect(new_source).to eq(['until foo',
                                '  a = 1',
                                '  b = 2',
                                'end'].join("\n"))
    end

    it 'corrects when the expression uses a modifier rescue statement' do
      new_source = autocorrect_source(cop, 'a, b = 1, 2 rescue foo')

      expect(new_source).to eq(['begin',
                                '  a = 1',
                                '  b = 2',
                                'rescue',
                                '  foo',
                                'end'].join("\n"))
    end

    it 'corrects parallel assignment in rescue statements' do
      new_source = autocorrect_source(cop, ['def bar',
                                            '  a, b = 1, 2',
                                            'rescue',
                                            "  'foo'",
                                            'end'].join("\n"))

      expect(new_source).to eq(['def bar',
                                '  a = 1',
                                '  b = 2',
                                'rescue',
                                "  'foo'",
                                'end'].join("\n"))
    end

    it 'corrects parallel assignment in rescue statements' do
      new_source = autocorrect_source(cop, ['begin',
                                            '  a, b = 1, 2',
                                            'rescue',
                                            "  'foo'",
                                            'end'].join("\n"))

      expect(new_source).to eq(['begin',
                                '  a = 1',
                                '  b = 2',
                                'rescue',
                                "  'foo'",
                                'end'].join("\n"))
    end

    it 'corrects when the expression uses a modifier rescue statement ' \
       'as the only thing inside of a method' do
      new_source = autocorrect_source(cop, ['def foo',
                                            '  a, b = 1, 2 rescue foo',
                                            'end'])

      expect(new_source).to eq(['def foo',
                                '  a = 1',
                                '  b = 2',
                                'rescue',
                                '  foo',
                                'end'].join("\n"))
    end

    it 'corrects when the expression uses a modifier rescue statement ' \
       'inside of a method' do
      new_source = autocorrect_source(cop, ['def foo',
                                            '  a, b = %w(1 2) rescue foo',
                                            '  something_else',
                                            'end'])

      expect(new_source).to eq(['def foo',
                                '  begin',
                                "    a = '1'",
                                "    b = '2'",
                                '  rescue',
                                '    foo',
                                '  end',
                                '  something_else',
                                'end'].join("\n"))
    end

    it 'corrects when assignments must be reordered to avoid changing ' \
       'meaning' do
      new_source = autocorrect_source(cop, ['a, b, c, d = 1, a + 1, b + 1, ' \
        'a + b + c'])

      expect(new_source).to eq(['d = a + b + c',
                                'c = b + 1',
                                'b = a + 1',
                                'a = 1'].join("\n"))
    end

    shared_examples('no correction') do |description, source|
      context description do
        it "does not change: #{source.gsub(/\s*\n\s*/, '; ')}" do
          new_source = autocorrect_source(cop, source)
          expect(new_source).to eq(source)
        end
      end
    end

    it_behaves_like 'no correction',
                    'when there are more left variables than right variables',
                    'a, b, c, d = 1, 2'

    it_behaves_like 'no correction',
                    'when there are more right variables than left variables',
                    'a, b = 1, 2, 3'

    it_behaves_like 'no correction',
                    'when expanding an assigned variable',
                    ['foo = [1, 2, 3]',
                     'a, b, c = foo'].join("\n")

    describe 'using custom indentation width' do
      let(:config) do
        RuboCop::Config.new('Performance/ParallelAssignment' => {
                              'Enabled' => true
                            },
                            'Style/IndentationWidth' => {
                              'Enabled' => true,
                              'Width' => 3
                            })
      end

      it 'works with standard correction' do
        new_source = autocorrect_source(cop, 'a, b, c = 1, 2, 3')

        expect(new_source).to eq(['a = 1',
                                  'b = 2',
                                  'c = 3'].join("\n"))
      end

      it 'works with guard clauses' do
        new_source = autocorrect_source(cop, 'a, b = 1, 2 if foo')

        expect(new_source).to eq(['if foo',
                                  '   a = 1',
                                  '   b = 2',
                                  'end'].join("\n"))
      end

      it 'works with rescue' do
        new_source = autocorrect_source(cop, 'a, b = 1, 2 rescue foo')

        expect(new_source).to eq(['begin',
                                  '   a = 1',
                                  '   b = 2',
                                  'rescue',
                                  '   foo',
                                  'end'].join("\n"))
      end

      it 'works with nesting' do
        new_source = autocorrect_source(cop, ['def foo',
                                              '   if true',
                                              '      a, b, c = 1, 2, 3',
                                              '   end',
                                              'end'].join("\n"))

        expect(new_source).to eq(['def foo',
                                  '   if true',
                                  '      a = 1',
                                  '      b = 2',
                                  '      c = 3',
                                  '   end',
                                  'end'].join("\n"))
      end
    end
  end
end
