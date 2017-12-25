# frozen_string_literal: true

RSpec.describe RuboCop::Token do
  describe '.from_parser_token' do
    subject(:token) { described_class.from_parser_token(parser_token) }

    let(:parser_token) { [type, [text, range]] }
    let(:type) { :kDEF }
    let(:text) { 'def' }
    let(:range) { double('range', line: 42, column: 30) }

    it "sets parser token's type to rubocop token's type" do
      expect(token.type).to eq(type)
    end

    it "sets parser token's text to rubocop token's text" do
      expect(token.text).to eq(text)
    end

    it "sets parser token's range to rubocop token's pos" do
      expect(token.pos).to eq(range)
    end

    it 'returns a #to_s useful for debugging' do
      expect(token.to_s).to eq('[[42, 30], kDEF, "def"]')
    end
  end
end
