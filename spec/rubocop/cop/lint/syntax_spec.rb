# frozen_string_literal: true

describe RuboCop::Cop::Lint::Syntax do
  let(:options) { nil }
  let(:ruby_version) { 2.4 }
  let(:path) { 'test.rb' }
  let(:processed_source) do
    RuboCop::ProcessedSource.new(source, ruby_version, path)
  end

  describe '.offenses_from_processed_source' do
    let(:offenses) do
      described_class.offenses_from_processed_source(processed_source,
                                                     nil, options)
    end

    context 'with a diagnostic error' do
      let(:source) { '(' }

      it 'returns an offense' do
        expect(offenses.size).to eq(1)
        message = <<-MESSAGE.chomp.strip_indent
          unexpected token $end
          (Using Ruby 2.4 parser; configure using `TargetRubyVersion` parameter, under `AllCops`)
        MESSAGE
        offense = offenses.first
        expect(offense.message).to eq(message)
        expect(offense.severity).to eq(:error)
      end

      context 'with --display-cop-names option' do
        let(:options) { { display_cop_names: true } }

        it 'returns an offense with cop name' do
          expect(offenses.size).to eq(1)
          message = <<-MESSAGE.chomp.strip_indent
            Lint/Syntax: unexpected token $end
            (Using Ruby 2.4 parser; configure using `TargetRubyVersion` parameter, under `AllCops`)
          MESSAGE
          offense = offenses.first
          expect(offense.message).to eq(message)
          expect(offense.severity).to eq(:error)
        end
      end
    end

    context 'with a parser error' do
      let(:source) { <<-RUBY }
        # encoding: utf-8
        # \xf9
      RUBY

      it 'returns an offense' do
        expect(offenses.size).to eq(1)
        offense = offenses.first
        expect(offense.message).to eq('Invalid byte sequence in utf-8.')
        expect(offense.severity).to eq(:fatal)
        expect(offense.location).to eq(described_class::ERROR_SOURCE_RANGE)
      end

      context 'with --display-cop-names option' do
        let(:options) { { display_cop_names: true } }

        it 'returns an offense with cop name' do
          expect(offenses.size).to eq(1)
          message = <<-MESSAGE.chomp.strip_indent
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
