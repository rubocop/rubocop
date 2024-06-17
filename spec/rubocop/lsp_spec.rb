# frozen_string_literal: true

RSpec.describe RuboCop::LSP, :lsp do
  describe '.enabled?' do
    context 'when `RuboCop::LSP.enable` is called' do
      before { described_class.enable }

      it 'returns true' do
        expect(described_class).to be_enabled
      end
    end

    context 'when `RuboCop::LSP.disable` is called' do
      before { described_class.disable }

      it 'returns false' do
        expect(described_class).not_to be_enabled
      end
    end

    context 'when `RuboCop::LSP.disable` with block is called after `RuboCop::LSP.enable`' do
      before do
        described_class.enable
        described_class.disable { @inner = described_class.enabled? }
        @outer = described_class.enabled?
      end

      it 'returns false within block' do
        expect(@inner).to be(false) # rubocop:disable RSpec/InstanceVariable
      end

      it 'returns true without block' do
        expect(@outer).to be(true) # rubocop:disable RSpec/InstanceVariable
      end
    end

    context 'when `RuboCop::LSP.disable` with block is called after `RuboCop::LSP.disable`' do
      before do
        described_class.disable
        described_class.disable { @inner = described_class.enabled? }
        @outer = described_class.enabled?
      end

      it 'returns false within block' do
        expect(@inner).to be(false) # rubocop:disable RSpec/InstanceVariable
      end

      it 'returns false without block' do
        expect(@outer).to be(false) # rubocop:disable RSpec/InstanceVariable
      end
    end
  end
end
