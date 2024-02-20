# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::Syntax, :config do
  describe '.offenses_from_processed_source' do
    let(:commissioner) { RuboCop::Cop::Commissioner.new([cop]) }
    let(:offenses) { commissioner.investigate(processed_source).offenses }
    let(:ruby_version) { 3.3 } # The minimum version Prism can parse is 3.3.
    let(:syntax_error_message) do
      parser_engine == :parser_whitequark ? 'unexpected token $end' : 'expected a matching `)`'
    end

    context 'with a diagnostic error' do
      let(:source) { '(' }

      it 'returns an offense' do
        expect(offenses.size).to eq(1)
        message = <<~MESSAGE.chomp
          #{syntax_error_message}
          (Using Ruby 3.3 parser; configure using `TargetRubyVersion` parameter, under `AllCops`)
        MESSAGE
        offense = offenses.first
        expect(offense.message).to eq(message)
        expect(offense.severity).to eq(:fatal)
      end

      context 'with --display-cop-names option' do
        let(:cop_options) { { display_cop_names: true } }

        it 'returns an offense with cop name' do
          expect(offenses.size).to eq(1)
          message = <<~MESSAGE.chomp
            Lint/Syntax: #{syntax_error_message}
            (Using Ruby 3.3 parser; configure using `TargetRubyVersion` parameter, under `AllCops`)
          MESSAGE
          offense = offenses.first
          expect(offense.message).to eq(message)
          expect(offense.severity).to eq(:fatal)
        end
      end

      context 'with --autocorrect --disable-uncorrectable options' do
        let(:cop_options) do
          { autocorrect: true, safe_autocorrect: true, disable_uncorrectable: true }
        end

        it 'returns an offense' do
          expect(offenses.size).to eq(1)
          message = <<~MESSAGE.chomp
            #{syntax_error_message}
            (Using Ruby 3.3 parser; configure using `TargetRubyVersion` parameter, under `AllCops`)
          MESSAGE
          offense = offenses.first
          expect(offense.message).to eq(message)
          expect(offense.severity).to eq(:fatal)
        end
      end

      context 'with `--lsp` option', :lsp do
        it 'does not include a configuration information in the offense message' do
          expect(offenses.first.message).to eq(syntax_error_message)
        end
      end
    end

    context 'with a parser error' do
      let(:source) { <<~RUBY }
        # \xf9
      RUBY

      it 'returns an offense' do
        expect(offenses.size).to eq(1)
        offense = offenses.first
        expect(offense.message).to eq('Invalid byte sequence in utf-8.')
        expect(offense.severity).to eq(:fatal)
        expect(offense.location).to eq(RuboCop::Cop::Offense::NO_LOCATION)
      end

      context 'with --display-cop-names option' do
        let(:cop_options) { { display_cop_names: true } }

        it 'returns an offense with cop name' do
          expect(offenses.size).to eq(1)
          message = <<~MESSAGE.chomp
            Lint/Syntax: Invalid byte sequence in utf-8.
          MESSAGE
          offense = offenses.first
          expect(offense.message).to eq(message)
          expect(offense.severity).to eq(:fatal)
        end
      end
    end
  end
end
