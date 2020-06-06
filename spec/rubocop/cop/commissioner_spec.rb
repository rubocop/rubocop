# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Commissioner do
  describe '#investigate' do
    subject(:offenses) do
      report.offenses
    end

    let(:report) { commissioner.investigate(processed_source) }
    let(:cop_offenses) { [] }
    let(:cop_report) do
      RuboCop::Cop::Base::InvestigationReport
        .new(nil, processed_source, cop_offenses, nil)
    end
    let(:cop) do
      # rubocop:disable RSpec/VerifiedDoubles
      double(RuboCop::Cop::Base, complete_investigation: cop_report).as_null_object
      # rubocop:enable RSpec/VerifiedDoubles
    end
    let(:cops) { [cop] }
    let(:options) { {} }
    let(:forces) { [] }
    let(:commissioner) { described_class.new(cops, forces, **options) }
    let(:errors) { commissioner.errors }
    let(:source) { <<~RUBY }
      def method
      1
      end
    RUBY
    let(:processed_source) { parse_source(source, 'file.rb') }

    context 'when a cop reports offenses' do
      let(:cop_offenses) { [Object.new] }

      it 'returns all offenses found by the cops' do
        expect(offenses).to eq cop_offenses
      end
    end

    it 'traverses the AST and invoke cops specific callbacks' do
      expect(cop).to receive(:on_def).once
      offenses
    end

    it 'stores all errors raised by the cops' do
      allow(cop).to receive(:on_int) { raise RuntimeError }

      expect(offenses).to eq []
      expect(errors.size).to eq(1)
      expect(
        errors[0].cause.instance_of?(RuntimeError)
      ).to be(true)
      expect(errors[0].line).to eq 2
      expect(errors[0].column).to eq 0
    end

    context 'when passed :raise_error option' do
      let(:options) { { raise_error: true } }

      it 're-raises the exception received while processing' do
        allow(cop).to receive(:on_int) { raise RuntimeError }

        expect do
          offenses
        end.to raise_error(RuntimeError)
      end
    end

    context 'when given a force' do
      let(:force) { instance_double(RuboCop::Cop::Force).as_null_object }
      let(:forces) { [force] }

      it 'passes the input params to all cops/forces that implement their own' \
         ' #investigate method' do
        expect(cop).to receive(:on_new_investigation).with(no_args)
        expect(force).to receive(:investigate).with(processed_source)

        offenses
      end
    end

    context 'when given a source with parsing errors' do
      let(:source) { '(' }

      it 'only calls on_other_file' do
        expect(cop).not_to receive(:on_new_investigation)
        expect(cop).to receive(:on_other_file)
        offenses
      end
    end
  end
end
