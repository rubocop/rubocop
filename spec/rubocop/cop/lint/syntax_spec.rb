# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Lint::Syntax do
  describe '.offence_from_diagnostic' do
    subject(:offence) { described_class.offence_from_diagnostic(diagnostic) }
    let(:diagnostic) { Parser::Diagnostic.new(level, reason, args, location) }
    let(:level) { :warning }
    let(:reason) { :odd_hash }
    let(:args) { [] }
    let(:location) { double('location').as_null_object }

    it 'returns an offence' do
      expect(offence).to be_a(Rubocop::Cop::Offence)
    end

    it "sets diagnostic's level to offence's severity" do
      expect(offence.severity).to eq(level)
    end

    it "sets diagnostic's message to offence's message" do
      expect(offence.message).to eq('odd number of entries for a hash')
    end

    it "sets diagnostic's location to offence's location" do
      expect(offence.location).to eq(location)
    end

    it 'sets Syntax as a cop name' do
      expect(offence.cop_name).to eq('Syntax')
    end
  end
end
