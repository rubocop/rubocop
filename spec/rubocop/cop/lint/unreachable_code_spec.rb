# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Lint::UnreachableCode do
  subject(:cop) { described_class.new }

  described_class::NODE_TYPES.each do |t|
    it "registers an offence for #{t} before other statements" do
      inspect_source(cop,
                     ['foo = 5',
                      "#{t}",
                      'bar'
                     ])
      expect(cop.offences.size).to eq(1)
    end

    it "accepts code with conditional #{t}" do
      inspect_source(cop,
                     ['foo = 5',
                      "#{t} if test",
                      'bar'
                     ])
      expect(cop.offences).to be_empty
    end

    it "accepts #{t} as the final expression" do
      inspect_source(cop,
                     ['foo = 5',
                      "#{t} if test"
                     ])
      expect(cop.offences).to be_empty
    end
  end

  described_class::FLOW_COMMANDS.each do |t|
    it "registers an offence for #{t} before other statements" do
      inspect_source(cop,
                     ['foo = 5',
                      "#{t} something",
                      'bar'
                     ])
      expect(cop.offences.size).to eq(1)
    end

    it "accepts code with conditional #{t}" do
      inspect_source(cop,
                     ['foo = 5',
                      "#{t} something if test",
                      'bar'
                     ])
      expect(cop.offences).to be_empty
    end

    it "accepts #{t} as the final expression" do
      inspect_source(cop,
                     ['foo = 5',
                      "#{t} something if test"
                     ])
      expect(cop.offences).to be_empty
    end
  end
end
