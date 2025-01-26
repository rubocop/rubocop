# frozen_string_literal: true

RSpec.describe RuboCop::LSP::Severity do
  describe '.find_by' do
    subject(:lsp_severity) { described_class.find_by(rubocop_severity) }

    context 'when RuboCop severity is fatal' do
      let(:rubocop_severity) { 'fatal' }

      it {
        expect(lsp_severity).to eq(LanguageServer::Protocol::Constant::DiagnosticSeverity::ERROR)
      }
    end

    context 'when RuboCop severity is error' do
      let(:rubocop_severity) { 'error' }

      it {
        expect(lsp_severity).to eq(LanguageServer::Protocol::Constant::DiagnosticSeverity::ERROR)
      }
    end

    context 'when RuboCop severity is warning' do
      let(:rubocop_severity) { 'warning' }

      it {
        expect(lsp_severity).to eq(LanguageServer::Protocol::Constant::DiagnosticSeverity::WARNING)
      }
    end

    context 'when RuboCop severity is convention' do
      let(:rubocop_severity) { 'convention' }

      it {
        expect(lsp_severity).to eq(
          LanguageServer::Protocol::Constant::DiagnosticSeverity::INFORMATION
        )
      }
    end

    context 'when RuboCop severity is refactor' do
      let(:rubocop_severity) { 'refactor' }

      it {
        expect(lsp_severity).to eq(LanguageServer::Protocol::Constant::DiagnosticSeverity::HINT)
      }
    end

    context 'when RuboCop severity is unknown severity' do
      let(:rubocop_severity) { 'UNKNOWN' }

      it {
        expect { lsp_severity }.to output("[server] Unknown severity: UNKNOWN\n").to_stderr
        expect(lsp_severity).to eq(LanguageServer::Protocol::Constant::DiagnosticSeverity::HINT)
      }
    end
  end
end
