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

  describe '.wait_for_process_exit!' do
    before { allow(described_class).to receive(:sleep) }

    it 'returns when the process exits' do
      expect(RuboCop::Server::Cache)
        .to receive(:pid_running?).with(4242).exactly(3).times.and_return(true, true, false)

      described_class.wait_for_process_exit!(4242)
    end

    it 'exits with a warning when the process does not exit in time' do
      allow(RuboCop::Server::Cache).to receive(:pid_running?).with(4242).and_return(true)
      allow(Time).to receive(:now).and_return(Time.at(0), Time.at(described_class::TIMEOUT + 1))

      message = "RuboCop server (4242) did not exit after #{described_class::TIMEOUT} seconds!\n"
      expect { described_class.wait_for_process_exit!(4242) }
        .to raise_error(SystemExit).and output(message).to_stderr
    end
  end
end
