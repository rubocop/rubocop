# frozen_string_literal: true

RSpec.describe RuboCop::LSP, :lsp do
  describe '.enabled?' do
    context 'when `RuboCop::LSP.enable` is called' do
      before { described_class.enable }

      it 'returns true' do
        expect(described_class.enabled?).to be(true)
      end
    end

    context 'when `RuboCop::LSP.disable` is called' do
      before { described_class.disable }

      it 'returns false' do
        expect(described_class.enabled?).to be(false)
      end
    end
  end
end
