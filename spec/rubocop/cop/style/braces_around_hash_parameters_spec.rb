# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::BracesAroundHashParameters, :config do
  subject(:cop) { described_class.new(config) }

  shared_examples 'general non-offenses' do
    after(:each) { expect(cop.offenses).to be_empty }

    it 'accepts one non-hash parameter' do
      inspect_source(cop, 'where(2)')
    end

    it 'accepts multiple non-hash parameters' do
      inspect_source(cop, 'where(1, "2")')
    end

    it 'accepts one empty hash parameter' do
      inspect_source(cop, 'where({})')
    end

    it 'accepts one empty hash parameter with whitespace' do
      inspect_source(cop, ['where(  {     ',
                           " }\t   )  "])
    end
  end

  shared_examples 'no_braces and context_dependent non-offenses' do
    after(:each) { expect(cop.offenses).to be_empty }

    it 'accepts one hash parameter without braces' do
      inspect_source(cop, 'where(x: "y")')
    end

    it 'accepts one hash parameter without braces and with multiple keys' do
      inspect_source(cop, 'where(x: "y", foo: "bar")')
    end

    it 'accepts one hash parameter without braces and with one hash value' do
      inspect_source(cop, 'where(x: { "y" => "z" })')
    end

    it 'accepts property assignment with braces' do
      inspect_source(cop, 'x.z = { y: "z" }')
    end

    it 'accepts operator with a hash parameter with braces' do
      inspect_source(cop, 'x.z - { y: "z" }')
    end
  end

  shared_examples 'no_braces and context_dependent offenses' do
    let(:msg) { 'Redundant curly braces around a hash parameter.' }

    it 'registers an offense for one non-hash parameter followed by a hash ' \
       'parameter with braces' do
      inspect_source(cop, 'where(1, { y: 2 })')
      expect(cop.messages).to eq([msg])
      expect(cop.highlights).to eq(['{ y: 2 }'])
    end

    it 'registers an offense for one object method hash parameter with ' \
       'braces' do
      inspect_source(cop, 'x.func({ y: "z" })')
      expect(cop.messages).to eq([msg])
      expect(cop.highlights).to eq(['{ y: "z" }'])
    end

    it 'registers an offense for one hash parameter with braces' do
      inspect_source(cop, 'where({ x: 1 })')
      expect(cop.messages).to eq([msg])
      expect(cop.highlights).to eq(['{ x: 1 }'])
    end

    it 'registers an offense for one hash parameter with braces and ' \
       'whitespace' do
      inspect_source(cop, "where(  \n { x: 1 }   )")
      expect(cop.messages).to eq([msg])
      expect(cop.highlights).to eq(['{ x: 1 }'])
    end

    it 'registers an offense for one hash parameter with braces and multiple ' \
       'keys' do
      inspect_source(cop, 'where({ x: 1, foo: "bar" })')
      expect(cop.messages).to eq([msg])
      expect(cop.highlights).to eq(['{ x: 1, foo: "bar" }'])
    end
  end

  shared_examples 'no_braces and context_dependent auto-corrections' do
    it 'corrects one non-hash parameter followed by a hash parameter with ' \
       'braces' do
      corrected = autocorrect_source(cop, ['where(1, { y: 2 })'])
      expect(corrected).to eq('where(1, y: 2)')
    end

    it 'corrects one object method hash parameter with braces' do
      corrected = autocorrect_source(cop, ['x.func({ y: "z" })'])
      expect(corrected).to eq('x.func(y: "z")')
    end

    it 'corrects one hash parameter with braces' do
      corrected = autocorrect_source(cop, ['where({ x: 1 })'])
      expect(corrected).to eq('where(x: 1)')
    end

    it 'corrects one hash parameter with braces and whitespace' do
      corrected = autocorrect_source(cop, ['where(  ',
                                           ' { x: 1 }   )'])
      expect(corrected).to eq(['where(  ',
                               ' x: 1   )'].join("\n"))
    end

    it 'corrects one hash parameter with braces and multiple keys' do
      corrected = autocorrect_source(cop, ['where({ x: 1, foo: "bar" })'])
      expect(corrected).to eq('where(x: 1, foo: "bar")')
    end

    it 'corrects one hash parameter with braces and extra leading whitespace' do
      corrected = autocorrect_source(cop, ['where({   x: 1, y: 2 })'])
      expect(corrected).to eq('where(x: 1, y: 2)')
    end

    it 'corrects one hash parameter with braces and extra trailing ' \
       'whitespace' do
      corrected = autocorrect_source(cop, ['where({ x: 1, y: 2   })'])
      expect(corrected).to eq('where(x: 1, y: 2)')
    end

    it 'corrects one hash parameter with braces and a trailing comma' do
      corrected = autocorrect_source(cop, ['where({ x: 1, y: 2, })'])
      expect(corrected).to eq('where(x: 1, y: 2)')
    end

    it 'corrects one hash parameter with braces and trailing comma and ' \
       'whitespace' do
      corrected = autocorrect_source(cop, ['where({ x: 1, y: 2,   })'])
      expect(corrected).to eq('where(x: 1, y: 2)')
    end

    it 'corrects one hash parameter with braces without adding extra space' do
      corrected = autocorrect_source(cop, 'get :i, { q: { x: 1 } }')
      expect(corrected).to eq('get :i, q: { x: 1 }')
    end

    context 'with a comment following the last key-value pair' do
      it 'corrects and leaves line breaks' do
        src = ['r = opts.merge({',
               '  p1: opts[:a],',
               '  p2: (opts[:b] || opts[:c]) # a comment',
               '})']
        corrected = autocorrect_source(cop, src)
        expect(corrected).to eq(['r = opts.merge(',
                                 '  p1: opts[:a],',
                                 '  p2: (opts[:b] || opts[:c]) # a comment',
                                 ')'].join("\n"))
      end
    end

    context 'in a method call without parentheses' do
      it 'corrects a hash parameter with trailing comma' do
        src = 'get :i, { x: 1, }'
        corrected = autocorrect_source(cop, src)
        expect(corrected).to eq('get :i, x: 1')
      end
    end
  end

  context 'when EnforcedStyle is no_braces' do
    let(:cop_config) { { 'EnforcedStyle' => 'no_braces' } }

    context 'for correct code' do
      include_examples 'general non-offenses'
      include_examples 'no_braces and context_dependent non-offenses'
    end

    context 'for incorrect code' do
      include_examples 'no_braces and context_dependent offenses'

      after(:each) do
        expect(cop.messages)
          .to eq(['Redundant curly braces around a hash parameter.'])
      end

      it 'registers an offense for two hash parameters with braces' do
        inspect_source(cop, 'where({ x: 1 }, { y: 2 })')
        expect(cop.highlights).to eq(['{ y: 2 }'])
      end
    end

    describe '#autocorrect' do
      include_examples 'no_braces and context_dependent auto-corrections'

      it 'corrects one hash parameter with braces' do
        corrected = autocorrect_source(cop, ['where(1, { x: 1 })'])
        expect(corrected).to eq('where(1, x: 1)')
      end

      it 'corrects two hash parameters with braces' do
        corrected = autocorrect_source(cop, ['where(1, { x: 1 }, { y: 2 })'])
        expect(corrected).to eq('where(1, { x: 1 }, y: 2)')
      end
    end
  end

  context 'when EnforcedStyle is context_dependent' do
    let(:cop_config) { { 'EnforcedStyle' => 'context_dependent' } }

    context 'for correct code' do
      include_examples 'general non-offenses'
      include_examples 'no_braces and context_dependent non-offenses'

      it 'accepts two hash parameters with braces' do
        inspect_source(cop, 'where({ x: 1 }, { y: 2 })')
        expect(cop.offenses).to be_empty
      end
    end

    context 'for incorrect code' do
      include_examples 'no_braces and context_dependent offenses'

      it 'registers an offense for one hash parameter with braces and one ' \
         'without' do
        inspect_source(cop, 'where({ x: 1 }, y: 2)')
        expect(cop.messages)
          .to eq(['Missing curly braces around a hash parameter.'])
        expect(cop.highlights).to eq(['y: 2'])
      end
    end

    describe '#autocorrect' do
      include_examples 'no_braces and context_dependent auto-corrections'

      it 'corrects one hash parameter with braces and one without' do
        corrected = autocorrect_source(cop, ['where(1, { x: 1 }, y: 2)'])
        expect(corrected).to eq('where(1, { x: 1 }, {y: 2})')
      end

      it 'corrects one hash parameter with braces' do
        corrected = autocorrect_source(cop, ['where(1, { x: 1 })'])
        expect(corrected).to eq('where(1, x: 1)')
      end
    end
  end

  context 'when EnforcedStyle is braces' do
    let(:cop_config) { { 'EnforcedStyle' => 'braces' } }

    context 'for correct code' do
      include_examples 'general non-offenses'

      after(:each) { expect(cop.offenses).to be_empty }

      it 'accepts one hash parameter with braces' do
        inspect_source(cop, 'where({ x: 1 })')
      end

      it 'accepts multiple hash parameters with braces' do
        inspect_source(cop, 'where({ x: 1 }, { y: 2 })')
      end

      it 'accepts one hash parameter with braces and whitespace' do
        inspect_source(cop, ["where( \t    {  x: 1 ",
                             '  }   )'])
      end
    end

    context 'for incorrect code' do
      after(:each) do
        expect(cop.messages)
          .to eq(['Missing curly braces around a hash parameter.'])
      end

      it 'registers an offense for one hash parameter without braces' do
        inspect_source(cop, 'where(x: "y")')
        expect(cop.highlights).to eq(['x: "y"'])
      end

      it 'registers an offense for one hash parameter with multiple keys and ' \
         'without braces' do
        inspect_source(cop, 'where(x: "y", foo: "bar")')
        expect(cop.highlights).to eq(['x: "y", foo: "bar"'])
      end

      it 'registers an offense for one hash parameter without braces with ' \
         'one hash value' do
        inspect_source(cop, 'where(x: { "y" => "z" })')
        expect(cop.highlights).to eq(['x: { "y" => "z" }'])
      end
    end

    describe '#autocorrect' do
      it 'corrects one hash parameter without braces' do
        corrected = autocorrect_source(cop, ['where(x: "y")'])
        expect(corrected).to eq('where({x: "y"})')
      end

      it 'corrects one hash parameter with multiple keys and without braces' do
        corrected = autocorrect_source(cop, ['where(x: "y", foo: "bar")'])
        expect(corrected).to eq('where({x: "y", foo: "bar"})')
      end

      it 'corrects one hash parameter without braces with one hash value' do
        corrected = autocorrect_source(cop, ['where(x: { "y" => "z" })'])
        expect(corrected).to eq('where({x: { "y" => "z" }})')
      end
    end
  end
end
