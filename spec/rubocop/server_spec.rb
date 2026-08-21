# frozen_string_literal: true

RSpec.describe RuboCop::Server do
  describe '.forward_to_server?' do
    context 'when the server is running' do
      before { allow(described_class).to receive(:running?).and_return(true) }

      it 'is true for a lint invocation' do
        expect(described_class).to be_forward_to_server(['lib'])
      end

      it 'is false when `--lsp` is given' do
        expect(described_class).not_to be_forward_to_server(['--lsp'])
      end

      it 'is false when `--mcp` is given' do
        expect(described_class).not_to be_forward_to_server(['--mcp'])
      end
    end

    context 'when the server is not running' do
      before { allow(described_class).to receive(:running?).and_return(false) }

      it 'is false' do
        expect(described_class).not_to be_forward_to_server(['lib'])
      end
    end
  end
end
