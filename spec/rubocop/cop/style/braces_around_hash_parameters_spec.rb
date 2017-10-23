# frozen_string_literal: true

describe RuboCop::Cop::Style::BracesAroundHashParameters, :config do
  subject(:cop) { described_class.new(config) }

  shared_examples 'general non-offenses' do
    it 'accepts one non-hash parameter' do
      expect_no_offenses('where(2)')
    end

    it 'accepts multiple non-hash parameters' do
      expect_no_offenses('where(1, "2")')
    end

    it 'accepts one empty hash parameter' do
      expect_no_offenses('where({})')
    end

    it 'accepts one empty hash parameter with whitespace' do
      expect_no_offenses(['where(  {     ',
                          " }\t   )  "])
    end
  end

  shared_examples 'no_braces and context_dependent non-offenses' do
    it 'accepts one hash parameter without braces' do
      expect_no_offenses('where(x: "y")')
    end

    it 'accepts one hash parameter without braces and with multiple keys' do
      expect_no_offenses('where(x: "y", foo: "bar")')
    end

    it 'accepts one hash parameter without braces and with one hash value' do
      expect_no_offenses('where(x: { "y" => "z" })')
    end

    it 'accepts property assignment with braces' do
      expect_no_offenses('x.z = { y: "z" }')
    end

    it 'accepts operator with a hash parameter with braces' do
      expect_no_offenses('x.z - { y: "z" }')
    end
  end

  shared_examples 'no_braces and context_dependent offenses' do
    let(:msg) { 'Redundant curly braces around a hash parameter.' }

    it 'registers an offense for one non-hash parameter followed by a hash ' \
       'parameter with braces' do
      inspect_source('where(1, { y: 2 })')
      expect(cop.messages).to eq([msg])
      expect(cop.highlights).to eq(['{ y: 2 }'])
    end

    it 'registers an offense for one object method hash parameter with ' \
       'braces' do
      inspect_source('x.func({ y: "z" })')
      expect(cop.messages).to eq([msg])
      expect(cop.highlights).to eq(['{ y: "z" }'])
    end

    it 'registers an offense for one hash parameter with braces' do
      inspect_source('where({ x: 1 })')
      expect(cop.messages).to eq([msg])
      expect(cop.highlights).to eq(['{ x: 1 }'])
    end

    it 'registers an offense for one hash parameter with braces and ' \
       'whitespace' do
      inspect_source("where(  \n { x: 1 }   )")
      expect(cop.messages).to eq([msg])
      expect(cop.highlights).to eq(['{ x: 1 }'])
    end

    it 'registers an offense for one hash parameter with braces and multiple ' \
       'keys' do
      inspect_source('where({ x: 1, foo: "bar" })')
      expect(cop.messages).to eq([msg])
      expect(cop.highlights).to eq(['{ x: 1, foo: "bar" }'])
    end
  end

  shared_examples 'no_braces and context_dependent auto-corrections' do
    it 'corrects one non-hash parameter followed by a hash parameter with ' \
       'braces' do
      corrected = autocorrect_source(['where(1, { y: 2 })'])
      expect(corrected).to eq('where(1, y: 2)')
    end

    it 'corrects one object method hash parameter with braces' do
      corrected = autocorrect_source(['x.func({ y: "z" })'])
      expect(corrected).to eq('x.func(y: "z")')
    end

    it 'corrects one hash parameter with braces' do
      corrected = autocorrect_source(['where({ x: 1 })'])
      expect(corrected).to eq('where(x: 1)')
    end

    it 'corrects one hash parameter with braces and whitespace' do
      corrected = autocorrect_source(['where(  ',
                                      ' { x: 1 }   )'])
      expect(corrected).to eq(['where(  ',
                               ' x: 1   )'].join("\n"))
    end

    it 'corrects one hash parameter with braces and multiple keys' do
      corrected = autocorrect_source(['where({ x: 1, foo: "bar" })'])
      expect(corrected).to eq('where(x: 1, foo: "bar")')
    end

    it 'corrects one hash parameter with braces and extra leading whitespace' do
      corrected = autocorrect_source(['where({   x: 1, y: 2 })'])
      expect(corrected).to eq('where(x: 1, y: 2)')
    end

    it 'corrects one hash parameter with braces and extra trailing ' \
       'whitespace' do
      corrected = autocorrect_source(['where({ x: 1, y: 2   })'])
      expect(corrected).to eq('where(x: 1, y: 2)')
    end

    it 'corrects one hash parameter with braces and a trailing comma' do
      corrected = autocorrect_source(['where({ x: 1, y: 2, })'])
      expect(corrected).to eq('where(x: 1, y: 2)')
    end

    it 'corrects one hash parameter with braces and trailing comma and ' \
       'whitespace' do
      corrected = autocorrect_source(['where({ x: 1, y: 2,   })'])
      expect(corrected).to eq('where(x: 1, y: 2)')
    end

    it 'corrects one hash parameter with braces without adding extra space' do
      corrected = autocorrect_source('get :i, { q: { x: 1 } }')
      expect(corrected).to eq('get :i, q: { x: 1 }')
    end

    context 'with a comment following the last key-value pair' do
      it 'corrects and leaves line breaks' do
        src = <<-RUBY.strip_indent
          r = opts.merge({
            p1: opts[:a],
            p2: (opts[:b] || opts[:c]) # a comment
          })
        RUBY
        corrected = autocorrect_source(src)
        expect(corrected).to eq(<<-RUBY.strip_indent)
          r = opts.merge(
            p1: opts[:a],
            p2: (opts[:b] || opts[:c]) # a comment
          )
        RUBY
      end
    end

    context 'in a method call without parentheses' do
      it 'corrects a hash parameter with trailing comma' do
        src = 'get :i, { x: 1, }'
        corrected = autocorrect_source(src)
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

      it 'registers an offense for two hash parameters with braces' do
        expect_offense(<<-RUBY.strip_indent)
          where({ x: 1 }, { y: 2 })
                          ^^^^^^^^ Redundant curly braces around a hash parameter.
        RUBY
      end
    end

    describe '#autocorrect' do
      include_examples 'no_braces and context_dependent auto-corrections'

      it 'corrects one hash parameter with braces' do
        corrected = autocorrect_source(['where(1, { x: 1 })'])
        expect(corrected).to eq('where(1, x: 1)')
      end

      it 'corrects two hash parameters with braces' do
        corrected = autocorrect_source(['where(1, { x: 1 }, { y: 2 })'])
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
        expect_no_offenses('where({ x: 1 }, { y: 2 })')
      end
    end

    context 'for incorrect code' do
      include_examples 'no_braces and context_dependent offenses'

      it 'registers an offense for one hash parameter with braces and one ' \
         'without' do
        inspect_source('where({ x: 1 }, y: 2)')
        expect(cop.messages)
          .to eq(['Missing curly braces around a hash parameter.'])
        expect(cop.highlights).to eq(['y: 2'])
      end
    end

    describe '#autocorrect' do
      include_examples 'no_braces and context_dependent auto-corrections'

      it 'corrects one hash parameter with braces and one without' do
        corrected = autocorrect_source(['where(1, { x: 1 }, y: 2)'])
        expect(corrected).to eq('where(1, { x: 1 }, {y: 2})')
      end

      it 'corrects one hash parameter with braces' do
        corrected = autocorrect_source(['where(1, { x: 1 })'])
        expect(corrected).to eq('where(1, x: 1)')
      end
    end
  end

  context 'when EnforcedStyle is braces' do
    let(:cop_config) { { 'EnforcedStyle' => 'braces' } }

    context 'for correct code' do
      include_examples 'general non-offenses'

      it 'accepts one hash parameter with braces' do
        expect_no_offenses('where({ x: 1 })')
      end

      it 'accepts multiple hash parameters with braces' do
        expect_no_offenses('where({ x: 1 }, { y: 2 })')
      end

      it 'accepts one hash parameter with braces and whitespace' do
        expect_no_offenses(<<-RUBY.strip_indent)
          where( 	    {  x: 1
            }   )
        RUBY
      end
    end

    context 'for incorrect code' do
      it 'registers an offense for one hash parameter without braces' do
        expect_offense(<<-RUBY.strip_indent)
          where(x: "y")
                ^^^^^^ Missing curly braces around a hash parameter.
        RUBY
      end

      it 'registers an offense for one hash parameter with multiple keys and ' \
         'without braces' do
        expect_offense(<<-RUBY.strip_indent)
          where(x: "y", foo: "bar")
                ^^^^^^^^^^^^^^^^^^ Missing curly braces around a hash parameter.
        RUBY
      end

      it 'registers an offense for one hash parameter without braces with ' \
         'one hash value' do
        expect_offense(<<-RUBY.strip_indent)
          where(x: { "y" => "z" })
                ^^^^^^^^^^^^^^^^^ Missing curly braces around a hash parameter.
        RUBY
      end
    end

    describe '#autocorrect' do
      it 'corrects one hash parameter without braces' do
        corrected = autocorrect_source(['where(x: "y")'])
        expect(corrected).to eq('where({x: "y"})')
      end

      it 'corrects one hash parameter with multiple keys and without braces' do
        corrected = autocorrect_source(['where(x: "y", foo: "bar")'])
        expect(corrected).to eq('where({x: "y", foo: "bar"})')
      end

      it 'corrects one hash parameter without braces with one hash value' do
        corrected = autocorrect_source(['where(x: { "y" => "z" })'])
        expect(corrected).to eq('where({x: { "y" => "z" }})')
      end
    end
  end
end
