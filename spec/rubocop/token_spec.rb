# encoding: utf-8

require 'spec_helper'

describe Rubocop::Token do
  describe '.from_parser_token' do
    subject(:token) { described_class.from_parser_token(parser_token) }
    let(:parser_token) { [type, [text, range]] }
    let(:type) { :kDEF }
    let(:text) { 'def' }
    let(:range) { double('range') }

    it "sets parser token's type to rubocop token's type" do
      expect(token.type).to eq(type)
    end

    it "sets parser token's text to rubocop token's text" do
      expect(token.text).to eq(text)
    end

    it "sets parser token's range to rubocop token's pos" do
      expect(token.pos).to eq(range)
    end
  end
end
