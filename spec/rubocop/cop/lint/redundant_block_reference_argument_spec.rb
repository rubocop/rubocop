# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Lint::RedundantBlockReferenceArgument, :config do
  subject(:cop) { described_class.new(config) }

  context 'When method does not have redundant argument' do
    let(:source) { <<-END }
      def foo(&block)
      end
    END

    it 'does not register any offenses' do
      inspect_source(cop, source)
      expect(cop.offenses).to be_empty
    end
  end

  context 'When method has a redundant argument' do
    let(:source) { <<-END }
      def foo(&_)
      end
    END

    it 'registers an offense' do
      inspect_source(cop, source)
      expect(cop.offenses.size).to eq(1)
    end
  end
end
