# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::Syntax, :config do
  describe '.offenses_from_processed_source' do
    let(:commissioner) { RuboCop::Cop::Commissioner.new([cop]) }
    let(:offenses) { commissioner.investigate(processed_source).offenses }

    context 'with a diagnostic error' do
      let(:source) { '(' }

      it 'returns an offense' do
        expect(offenses.size).to eq(1)
        message = <<~MESSAGE.chomp
          unexpected token $end
          (Using Ruby 2.7 parser; configure using `TargetRubyVersion` parameter, under `AllCops`)
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
            Lint/Syntax: unexpected token $end
            (Using Ruby 2.7 parser; configure using `TargetRubyVersion` parameter, under `AllCops`)
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
            unexpected token $end
            (Using Ruby 2.7 parser; configure using `TargetRubyVersion` parameter, under `AllCops`)
          MESSAGE
          offense = offenses.first
          expect(offense.message).to eq(message)
          expect(offense.severity).to eq(:fatal)
        end
      end
    end

    context 'with a parser error' do
      let(:source) { <<-RUBY }
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
