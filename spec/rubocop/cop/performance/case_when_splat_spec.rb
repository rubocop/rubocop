# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::Performance::CaseWhenSplat do
  subject(:cop) { described_class.new }

  it 'allows case when without splat' do
    inspect_source(cop, ['case foo',
                         'when 1',
                         '  bar',
                         'else',
                         '  baz',
                         'end'])

    expect(cop.messages).to be_empty
  end

  it 'allows splat on a variable in the last when condition' do
    inspect_source(cop, ['case foo',
                         'when 4',
                         '  foobar',
                         'when *cond',
                         '  bar',
                         'else',
                         '  baz',
                         'end'])

    expect(cop.messages).to be_empty
  end

  it 'allows multiple splat conditions on variables at the end' do
    inspect_source(cop, ['case foo',
                         'when 4',
                         '  foobar',
                         'when *cond1',
                         '  bar',
                         'when *cond2',
                         '  doo',
                         'else',
                         '  baz',
                         'end'])

    expect(cop.messages).to be_empty
  end

  it 'registers an offense for case when with a splat in the first condition' do
    inspect_source(cop, ['case foo',
                         'when *cond',
                         '  bar',
                         'when 4',
                         '  foobar',
                         'else',
                         '  baz',
                         'end'])

    expect(cop.messages).to eq([described_class::MSG])
    expect(cop.highlights).to eq(['when *cond'])
  end

  it 'registers an offense for case when with a splat without an else' do
    inspect_source(cop, ['case foo',
                         'when *baz',
                         '  bar',
                         'when 4',
                         '  foobar',
                         'end'])

    expect(cop.messages).to eq([described_class::MSG])
    expect(cop.highlights).to eq(['when *baz'])
  end

  it 'registers an offense for splat conditions in when then' do
    inspect_source(cop, ['case foo',
                         'when *cond then bar',
                         'when 4 then baz',
                         'end'])

    expect(cop.messages).to eq([described_class::MSG])
    expect(cop.highlights).to eq(['when *cond'])
  end

  it 'registers an offense for multiple splat conditions at the beginning' do
    inspect_source(cop, ['case foo',
                         'when *cond1',
                         '  bar',
                         'when *cond2',
                         '  doo',
                         'when 4',
                         '  foobar',
                         'else',
                         '  baz',
                         'end'])

    expect(cop.messages).to eq([described_class::MSG, described_class::MSG])
    expect(cop.highlights).to eq(['when *cond1', 'when *cond2'])
  end

  it 'registers an offense for multiple out of order splat conditions' do
    inspect_source(cop, ['case foo',
                         'when *cond1',
                         '  bar',
                         'when 8',
                         '  barfoo',
                         'when *SOME_CONSTANT',
                         '  doo',
                         'when 4',
                         '  foobar',
                         'else',
                         '  baz',
                         'end'])

    expect(cop.messages).to eq([described_class::MSG, described_class::MSG])
    expect(cop.highlights).to eq(['when *cond1', 'when *SOME_CONSTANT'])
  end

  it 'registers an offense for splat condition that do not appear at the end' do
    inspect_source(cop, ['case foo',
                         'when *cond1',
                         '  bar',
                         'when 8',
                         '  barfoo',
                         'when *cond2',
                         '  doo',
                         'when 4',
                         '  foobar',
                         'when *cond3',
                         '  doofoo',
                         'else',
                         '  baz',
                         'end'])

    expect(cop.messages).to eq([described_class::MSG, described_class::MSG])
    expect(cop.highlights).to eq(['when *cond1', 'when *cond2'])
  end

  it 'registers an offense for splat on an array literal' do
    inspect_source(cop, ['case foo',
                         'when *[1, 2]',
                         '  bar',
                         'when *[3, 4]',
                         '  bar',
                         'when 5',
                         '  baz',
                         'end'])

    expect(cop.messages)
      .to eq([described_class::ARRAY_MSG, described_class::ARRAY_MSG])
    expect(cop.highlights).to eq(['when *[1, 2]', 'when *[3, 4]'])
  end

  it 'registers an offense for splat on array literal as the last condition' do
    inspect_source(cop, ['case foo',
                         'when *[1, 2]',
                         '  bar',
                         'end'])

    expect(cop.messages).to eq([described_class::ARRAY_MSG])
    expect(cop.highlights).to eq(['when *[1, 2]'])
  end

  it 'registers an offense for a splat on a variable that proceeds a splat ' \
     'on an array literal as the last condition' do
    inspect_source(cop, ['case foo',
                         'when *cond',
                         '  bar',
                         'when *[1, 2]',
                         '  baz',
                         'end'])

    expect(cop.messages)
      .to eq([described_class::MSG, described_class::ARRAY_MSG])
    expect(cop.highlights).to eq(['when *cond', 'when *[1, 2]'])
  end

  context 'autocorrect' do
    it 'corrects *array to a list of the elements in the array' do
      new_source = autocorrect_source(cop, ['case foo',
                                            'when *[1, 2]',
                                            '  bar',
                                            'when 3',
                                            '  baz',
                                            'end'])

      expect(new_source).to eq(['case foo',
                                'when 1, 2',
                                '  bar',
                                'when 3',
                                '  baz',
                                'end'].join("\n"))
    end

    it 'moves a single splat condition to the end of the when conditions' do
      new_source = autocorrect_source(cop, ['case foo',
                                            'when *cond',
                                            '  bar',
                                            'when 3',
                                            '  baz',
                                            'end'])

      expect(new_source).to eq(['case foo',
                                'when 3',
                                '  baz',
                                'when *cond',
                                '  bar',
                                'end'].join("\n"))
    end

    it 'moves multiple splat condition to the end of the when conditions' do
      new_source = autocorrect_source(cop, ['case foo',
                                            'when *cond1',
                                            '  bar',
                                            'when *cond2',
                                            '  foobar',
                                            'when 5',
                                            '  baz',
                                            'end'])

      expect(new_source).to eq(['case foo',
                                'when 5',
                                '  baz',
                                'when *cond1',
                                '  bar',
                                'when *cond2',
                                '  foobar',
                                'end'].join("\n"))
    end

    it 'moves multiple out of order splat condition to the end ' \
       'of the when conditions' do
      new_source = autocorrect_source(cop, ['case foo',
                                            'when *cond1',
                                            '  bar',
                                            'when 3',
                                            '  doo',
                                            'when *cond2',
                                            '  foobar',
                                            'when 6',
                                            '  baz',
                                            'end'])

      expect(new_source).to eq(['case foo',
                                'when 3',
                                '  doo',
                                'when 6',
                                '  baz',
                                'when *cond1',
                                '  bar',
                                'when *cond2',
                                '  foobar',
                                'end'].join("\n"))
    end

    it 'corrects splat condition when using when then' do
      new_source = autocorrect_source(cop, ['case foo',
                                            'when *cond then bar',
                                            'when 4 then baz',
                                            'end'])

      expect(new_source).to eq(['case foo',
                                'when 4 then baz',
                                'when *cond then bar',
                                'end'].join("\n"))
    end

    it 'corrects nested case when statements' do
      new_source = autocorrect_source(cop, ['def check',
                                            '  case foo',
                                            '  when *cond',
                                            '    bar',
                                            '  when 3',
                                            '    baz',
                                            '  end',
                                            'end'])

      expect(new_source).to eq(['def check',
                                '  case foo',
                                '  when 3',
                                '    baz',
                                '  when *cond',
                                '    bar',
                                '  end',
                                'end'].join("\n"))
    end

    it 'corrects splat on variable and on array literal at the same time' do
      new_source = autocorrect_source(cop, ['case foo',
                                            'when *cond',
                                            '  bar',
                                            'when *[1, 2]',
                                            '  baz',
                                            'end'])

      expect(new_source).to eq(['case foo',
                                'when 1, 2',
                                '  baz',
                                'when *cond',
                                '  bar',
                                'end'].join("\n"))
    end

    it 'corrects splat on array literals using %w' do
      new_source = autocorrect_source(cop, ['case foo',
                                            'when *%w(first second)',
                                            '  baz',
                                            'end'])

      expect(new_source).to eq(['case foo',
                                "when 'first', 'second'",
                                '  baz',
                                'end'].join("\n"))
    end

    it 'corrects splat on array literals using %W' do
      new_source = autocorrect_source(cop, ['case foo',
                                            'when *%W(#{first} #{second})',
                                            '  baz',
                                            'end'])

      expect(new_source).to eq(['case foo',
                                'when "#{first}", "#{second}"',
                                '  baz',
                                'end'].join("\n"))
    end

    context 'ruby >= 2.0', :ruby20 do
      it 'corrects splat on array literals using %i' do
        new_source = autocorrect_source(cop, ['case foo',
                                              'when *%i(first second)',
                                              '  baz',
                                              'end'])

        expect(new_source).to eq(['case foo',
                                  'when :first, :second',
                                  '  baz',
                                  'end'].join("\n"))
      end

      it 'corrects splat on array literals using %I' do
        new_source = autocorrect_source(cop, ['case foo',
                                              'when *%I(#{first} #{second})',
                                              '  baz',
                                              'end'])

        expect(new_source).to eq(['case foo',
                                  'when :"#{first}", :"#{second}"',
                                  '  baz',
                                  'end'].join("\n"))
      end

      it 'corrects everything at once' do
        new_source = autocorrect_source(cop, ['case foo',
                                              'when *bar',
                                              '  1',
                                              'when baz',
                                              '  2',
                                              "when *['a', 'b']",
                                              '  3',
                                              'when *%w(c d)',
                                              '  4',
                                              'when *%W(#{e} #{f})',
                                              '  5',
                                              'when *%i(g h)',
                                              '  6',
                                              'when *%I(#{i} #{j})',
                                              '  7',
                                              'end'])

        expect(new_source).to eq(['case foo',
                                  'when baz',
                                  '  2',
                                  "when 'a', 'b'",
                                  '  3',
                                  "when 'c', 'd'",
                                  '  4',
                                  'when "#{e}", "#{f}"',
                                  '  5',
                                  'when :g, :h',
                                  '  6',
                                  'when :"#{i}", :"#{j}"',
                                  '  7',
                                  'when *bar',
                                  '  1',
                                  'end'].join("\n"))
      end
    end
  end
end
