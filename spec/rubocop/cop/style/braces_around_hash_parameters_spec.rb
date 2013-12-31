# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::BracesAroundHashParameters, :config do
  subject(:cop) { described_class.new(config) }

  context 'no_braces' do
    let(:cop_config) do
      { 'EnforcedStyle' => 'no_braces' }
    end

    describe 'accepts' do
      it 'one non-hash parameter' do
        inspect_source(cop, ['where(2)'])
        expect(cop.messages).to be_empty
        expect(cop.highlights).to be_empty
      end

      it 'one empty hash parameter' do
        inspect_source(cop, ['where({})'])
        expect(cop.messages).to be_empty
        expect(cop.highlights).to be_empty
      end

      it 'one hash parameter with separators' do
        inspect_source(cop, ["where(  {     \n }\t   )  "])
        expect(cop.messages).to be_empty
        expect(cop.highlights).to be_empty
      end

      it 'multiple non-hash parameters' do
        inspect_source(cop, ['where(1, "2")'])
        expect(cop.messages).to be_empty
        expect(cop.highlights).to be_empty
      end

      it 'one hash parameter without braces' do
        inspect_source(cop, ['where(x: "y")'])
        expect(cop.messages).to be_empty
        expect(cop.highlights).to be_empty
      end

      it 'one hash parameter without braces and multiple keys' do
        inspect_source(cop, ['where(x: "y", foo: "bar")'])
        expect(cop.messages).to be_empty
        expect(cop.highlights).to be_empty
      end

      it 'one hash parameter without braces and one hash value' do
        inspect_source(cop, ['where(x: { "y" => "z" })'])
        expect(cop.messages).to be_empty
        expect(cop.highlights).to be_empty
      end

      it 'multiple hash parameters with braces' do
        inspect_source(cop, ['where({ x: 1 }, { y: 2 })'])
        expect(cop.messages).to be_empty
        expect(cop.highlights).to be_empty
      end

      it 'property assignment with braces' do
        inspect_source(cop, ['x.z = { y: "z" }'])
        expect(cop.messages).to be_empty
        expect(cop.highlights).to be_empty
      end

      it 'operator with a hash parameter with braces' do
        inspect_source(cop, ['x.z - { y: "z" }'])
        expect(cop.messages).to be_empty
        expect(cop.highlights).to be_empty
      end

    end

    describe 'registers an offence for' do
      it 'one non-hash parameter followed by a hash parameter with braces' do
        inspect_source(cop, ['where(1, { y: 2 })'])
        expect(cop.messages).to eq([
          'Redundant curly braces around a hash parameter.'
        ])
        expect(cop.highlights).to eq(['{ y: 2 }'])
        expect(cop.config_to_allow_offences).to eq('EnforcedStyle' => 'braces')
      end

      it 'correct + opposite style' do
        inspect_source(cop, ['where(1, y: 2)',
                             'where(1, { y: 2 })'])
        expect(cop.messages).to eq([
          'Redundant curly braces around a hash parameter.'
        ])
        expect(cop.config_to_allow_offences).to eq('Enabled' => false)
      end

      it 'opposite + correct style' do
        inspect_source(cop, ['where(1, { y: 2 })',
                             'where(1, y: 2)'])
        expect(cop.messages).to eq([
          'Redundant curly braces around a hash parameter.'
        ])
        expect(cop.config_to_allow_offences).to eq('Enabled' => false)
      end

      it 'one object method hash parameter with braces' do
        inspect_source(cop, ['x.func({ y: "z" })'])
        expect(cop.messages).to eq([
          'Redundant curly braces around a hash parameter.'
        ])
        expect(cop.highlights).to eq(['{ y: "z" }'])
      end

      it 'one hash parameter with braces' do
        inspect_source(cop, ['where({ x: 1 })'])
        expect(cop.messages).to eq([
          'Redundant curly braces around a hash parameter.'
        ])
        expect(cop.highlights).to eq(['{ x: 1 }'])
      end

      it 'one hash parameter with braces and separators' do
        inspect_source(cop, ["where(  \n { x: 1 }   )"])
        expect(cop.messages).to eq([
          'Redundant curly braces around a hash parameter.'
        ])
        expect(cop.highlights).to eq(['{ x: 1 }'])
      end

      it 'one hash parameter with braces and multiple keys' do
        inspect_source(cop, ['where({ x: 1, foo: "bar" })'])
        expect(cop.messages).to eq([
          'Redundant curly braces around a hash parameter.'
        ])
        expect(cop.highlights).to eq(['{ x: 1, foo: "bar" }'])
      end
    end

    describe 'auto-corrects' do
      it 'one non-hash parameter followed by a hash parameter with braces' do
        corrected = autocorrect_source(cop, ['where(1, { y: 2 })'])
        expect(corrected).to eq 'where(1,  y: 2 )'
      end

      it 'one object method hash parameter with braces' do
        corrected = autocorrect_source(cop, ['x.func({ y: "z" })'])
        expect(corrected).to eq 'x.func( y: "z" )'
      end

      it 'one hash parameter with braces' do
        corrected = autocorrect_source(cop, ['where({ x: 1 })'])
        expect(corrected).to eq 'where( x: 1 )'
      end

      it 'one hash parameter with braces and separators' do
        corrected = autocorrect_source(cop, ["where(  \n { x: 1 }   )"])
        expect(corrected).to eq "where(  \n  x: 1    )"
      end

      it 'one hash parameter with braces and multiple keys' do
        corrected = autocorrect_source(cop, ['where({ x: 1, foo: "bar" })'])
        expect(corrected).to eq 'where( x: 1, foo: "bar" )'
      end

      it 'one hash parameter with braces and a trailing comma' do
        corrected = autocorrect_source(cop, ['where({ x: 1, y: 2, })'])
        expect(corrected).to eq 'where( x: 1, y: 2 )'
      end
    end
  end

  context 'braces' do
    let(:cop_config) do
      { 'EnforcedStyle' => 'braces' }
    end

    describe 'accepts' do
      it 'an empty hash parameter' do
        inspect_source(cop, ['where({})'])
        expect(cop.messages).to be_empty
        expect(cop.highlights).to be_empty
      end

      it 'one non-hash parameter' do
        inspect_source(cop, ['where(2)'])
        expect(cop.messages).to be_empty
        expect(cop.highlights).to be_empty
      end

      it 'multiple non-hash parameters' do
        inspect_source(cop, ['where(1, "2")'])
        expect(cop.messages).to be_empty
        expect(cop.highlights).to be_empty
      end

      it 'one hash parameter with braces' do
        inspect_source(cop, ['where({ x: 1 })'])
        expect(cop.messages).to be_empty
        expect(cop.highlights).to be_empty
      end

      it 'multiple hash parameters with braces' do
        inspect_source(cop, ['where({ x: 1 }, { y: 2 })'])
        expect(cop.messages).to be_empty
        expect(cop.highlights).to be_empty
      end

      it 'one hash parameter with braces and spaces around it' do
        inspect_source(cop, [
          'where(     {  x: 1  }   )'
        ])
        expect(cop.messages).to be_empty
        expect(cop.highlights).to be_empty
      end

      it 'one hash parameter with braces and separators around it' do
        inspect_source(cop, ["where( \t    {  x: 1 \n  }   )"])
        expect(cop.messages).to be_empty
        expect(cop.highlights).to be_empty
      end
    end

    describe 'registers an offence for' do
      it 'one hash parameter without braces' do
        inspect_source(cop, ['where(x: "y")'])
        expect(cop.messages).to eq([
          'Missing curly braces around a hash parameter.'
        ])
        expect(cop.highlights).to eq(['x: "y"'])
        expect(cop.config_to_allow_offences).to eq('EnforcedStyle' =>
                                                   'no_braces')
      end

      it 'opposite + correct style' do
        inspect_source(cop, ['where(y: 2)',
                             'where({ y: 2 })'])
        expect(cop.messages).to eq([
          'Missing curly braces around a hash parameter.'
        ])
        expect(cop.config_to_allow_offences).to eq('Enabled' => false)
      end

      it 'correct + opposite style' do
        inspect_source(cop, ['where({ y: 2 })',
                             'where(y: 2)'])
        expect(cop.messages).to eq([
          'Missing curly braces around a hash parameter.'
        ])
        expect(cop.config_to_allow_offences).to eq('Enabled' => false)
      end

      it 'one hash parameter with multiple keys and without braces' do
        inspect_source(cop, ['where(x: "y", foo: "bar")'])
        expect(cop.messages).to eq([
          'Missing curly braces around a hash parameter.'
        ])
        expect(cop.highlights).to eq(['x: "y", foo: "bar"'])
      end

      it 'one hash parameter without braces with one hash value' do
        inspect_source(cop, ['where(x: { "y" => "z" })'])
        expect(cop.messages).to eq([
          'Missing curly braces around a hash parameter.'
        ])
        expect(cop.highlights).to eq(['x: { "y" => "z" }'])
      end
    end

    describe 'auto-corrects' do
      it 'one hash parameter without braces' do
        corrected = autocorrect_source(cop, ['where(x: "y")'])
        expect(corrected).to eq 'where({x: "y"})'
      end

      it 'one hash parameter with multiple keys and without braces' do
        corrected = autocorrect_source(cop, ['where(x: "y", foo: "bar")'])
        expect(corrected).to eq 'where({x: "y", foo: "bar"})'
      end

      it 'one hash parameter without braces with one hash value' do
        corrected = autocorrect_source(cop, ['where(x: { "y" => "z" })'])
        expect(corrected).to eq 'where({x: { "y" => "z" }})'
      end
    end
  end
end
