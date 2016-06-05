# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::StringInterpreter do
  describe '.interpret' do
    shared_examples 'simple escape' do |escaped|
      it "handles #{escaped}" do
        expect(described_class.interpret(escaped)).to eq escaped[1..-1]
      end
    end

    it 'handles hex' do
      expect(described_class.interpret('\\\\x68')).to eq('\x68')
    end

    it 'handles octal' do
      expect(described_class.interpret('\\\\150')).to eq('\150')
    end

    it 'handles unicode' do
      expect(described_class.interpret('\\\\u0068')).to eq('\u0068')
    end

    it 'handles extended unicode' do
      expect(described_class.interpret('\\\\u{0068 0068}'))
        .to eq('\\u{0068 0068}')
    end

    it_behaves_like 'simple escape', '\\\\a'
    it_behaves_like 'simple escape', '\\\\b'
    it_behaves_like 'simple escape', '\\\\e'
    it_behaves_like 'simple escape', '\\\\f'
    it_behaves_like 'simple escape', '\\\\n'
    it_behaves_like 'simple escape', '\\\\r'
    it_behaves_like 'simple escape', '\\\\s'
    it_behaves_like 'simple escape', '\\\\t'
    it_behaves_like 'simple escape', '\\\\v'
    it_behaves_like 'simple escape', '\\\\n'
  end
end
