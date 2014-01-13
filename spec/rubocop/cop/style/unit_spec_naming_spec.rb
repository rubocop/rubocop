# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::UnitSpecNaming, :config do
  subject(:cop) { described_class.new(config) }

  context 'describe statement enforcement' do
    let(:cop_config) { { 'EnforceFilenames' => false } }

    it 'checks first-line describe statements' do
      inspect_source(cop,
                     ['describe "bad describe" do; end'])
      expect(cop.offences.size).to eq(1)
    end

    it 'checks describe statements after a require' do
      inspect_source(cop,
                     ["require 'spec_helper'",
                      'describe "bad describe" do; end'])
      expect(cop.offences.size).to eq(1)
    end

    it 'ignores nested describe statements' do
      inspect_source(cop,
                     ['describe Some::Class do',
                      '  describe "bad describe" do; end',
                      'end'])
      expect(cop.offences).to eq([])
    end

    it "doesn't blow up on single-line describes" do
      inspect_source(cop,
                     ['describe Some::Class'])
      expect(cop.offences).to eq([])
    end

    it 'checks class method naming' do
      inspect_source(cop,
                     ["describe Some::Class, '.asdf' do; end"])
      expect(cop.offences).to eq([])
    end

    it 'checks instance method naming' do
      inspect_source(cop,
                     ["describe Some::Class, '#fdsa' do; end"])
      expect(cop.offences).to eq([])
    end

    it 'enforces non-method names' do
      inspect_source(cop,
                     ["describe Some::Class, 'nope' do; end"])
      expect(cop.offences.size).to eq(1)
    end
  end

  context 'filename enforcement' do
    let(:cop_config) { { 'EnforceDescribeStatement' => false } }

    it 'checks class specs' do
      inspect_source(cop,
                     ['describe Some::Class do; end'],
                     'some/class_spec.rb')
      expect(cop.offences).to eq([])
    end

    it 'handles CamelCaps class names' do
      inspect_source(cop,
                     ['describe MyClass do; end'],
                     'my_class_spec.rb')
      expect(cop.offences).to eq([])
    end

    it 'handles ACRONYMClassNames' do
      inspect_source(cop,
                     ['describe ABCOne::Two do; end'],
                     'abc_one/two_spec.rb')
      expect(cop.offences).to eq([])
    end

    it 'handles ALLCAPS class names' do
      inspect_source(cop,
                     ['describe ALLCAPS do; end'],
                     'allcaps_spec.rb')
      expect(cop.offences).to eq([])
    end

    it 'checks instance methods' do
      inspect_source(cop,
                     ["describe Some::Class, '#inst' do; end"],
                     'some/class/inst_spec.rb')
      expect(cop.offences).to eq([])
    end

    it 'checks class methods' do
      inspect_source(cop,
                     ["describe Some::Class, '.inst' do; end"],
                     'some/class/class_methods/inst_spec.rb')
      expect(cop.offences).to eq([])
    end

    it 'ignores non-alphanumeric characters' do
      inspect_source(cop,
                     ["describe Some::Class, '#pred?' do; end"],
                     'some/class/pred_spec.rb')
      expect(cop.offences).to eq([])
    end

    it 'allows flexibility with predicates' do
      inspect_source(cop,
                     ["describe Some::Class, '#thing?' do; end"],
                     'some/class/thing_predicate_spec.rb')
      expect(cop.offences).to eq([])
    end

    it 'allows flexibility with operators' do
      inspect_source(cop,
                     ["describe MyClass, '#<=>' do; end"],
                     'my_class/spaceship_operator_spec.rb')
      expect(cop.offences).to eq([])
    end

    it 'checks the path' do
      inspect_source(cop,
                     ["describe MyClass, '#foo' do; end"],
                     'my_clas/foo_spec.rb')
      expect(cop.offences.size).to eq(1)
    end

    it 'checks class spec paths' do
      inspect_source(cop,
                     ['describe MyClass do; end'],
                     'my_clas_spec.rb')
      expect(cop.offences.size).to eq(1)
    end
  end
end
