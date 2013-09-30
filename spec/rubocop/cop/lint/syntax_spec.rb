# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Lint::Syntax do
  describe '.offences_from_diagnostic' do
    subject(:offence) { described_class.offence_from_diagnostic(diagnostic) }
    let(:diagnostic) { Parser::Diagnostic.new(level, message, location) }
    let(:level) { :warning }
    let(:message) { 'This is a message' }
    let(:location) { double('location').as_null_object }

    it 'returns an offence' do
      expect(offence).to be_a(Rubocop::Cop::Offence)
    end

    it "sets diagnostic's level to offence's severity" do
      expect(offence.severity).to eq(level)
    end

    it "sets diagnostic's message to offence's message" do
      expect(offence.message).to eq(message)
    end

    it "sets diagnostic's location to offence's location" do
      expect(offence.location).to eq(location)
    end

    it 'sets Sytanx as cop name' do
      expect(offence.cop_name).to eq('Syntax')
    end
  end
end
