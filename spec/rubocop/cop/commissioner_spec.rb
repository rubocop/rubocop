# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Commissioner do
  describe '#investigate' do
    subject(:offenses) { report.offenses }

    let(:report) { commissioner.investigate(processed_source) }
    let(:cop_class) do
      stub_const('Fake::FakeCop', Class.new(RuboCop::Cop::Base) do
                                    def on_int(node); end
                                    alias_method :on_def, :on_int
                                    alias_method :on_send, :on_int
                                    alias_method :on_csend, :on_int
                                    alias_method :after_int, :on_int
                                    alias_method :after_def, :on_int
                                    alias_method :after_send, :on_int
                                    alias_method :after_csend, :on_int
                                  end)
    end
    let(:cop) do
      cop_class.new.tap do |c|
        allow(c).to receive(:complete_investigation).and_return(cop_report)
      end
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
    let(:cop_offenses) { [] }
    let(:cop_report) do
      RuboCop::Cop::Base::InvestigationReport.new(nil, processed_source, cop_offenses, nil)
    end

    around { |example| RuboCop::Cop::Registry.with_temporary_global { example.run } }

    context 'when a cop reports offenses' do
      let(:cop_offenses) { [Object.new] }

      it 'returns all offenses found by the cops' do
        expect(offenses).to eq cop_offenses
      end
    end

    it 'traverses the AST and invoke cops specific callbacks' do
      expect(cop).to receive(:on_def).once
      expect(cop).to receive(:on_int).once
      expect(cop).not_to receive(:after_int)
      expect(cop).to receive(:after_def).once
      offenses
    end

    context 'traverses the AST with on_send / on_csend' do
      let(:source) { 'foo; var = bar; var&.baz' }

      context 'for unrestricted cops' do
        it 'calls on_send all method calls' do
          expect(cop).to receive(:on_send).twice
          expect(cop).to receive(:on_csend).once
          offenses
        end
      end

      context 'for a restricted cop' do
        before { stub_const("#{cop_class}::RESTRICT_ON_SEND", restrictions) }

        let(:restrictions) { [:bar] }

        it 'calls on_send for the right method calls' do
          expect(cop).to receive(:on_send).once
          expect(cop).to receive(:after_send).once
          expect(cop).not_to receive(:on_csend)
          expect(cop).not_to receive(:after_csend)
          offenses
        end

        context 'on both csend and send' do
          let(:restrictions) { %i[bar baz] }

          it 'calls on_send for the right method calls' do
            expect(cop).to receive(:on_send).once
            expect(cop).to receive(:on_csend).once
            expect(cop).to receive(:after_send).once
            expect(cop).to receive(:after_csend).once
            offenses
          end
        end
      end
    end

    it 'stores all errors raised by the cops' do
      allow(cop).to receive(:on_int) { raise RuntimeError }

      expect(offenses).to eq []
      expect(errors.size).to eq(1)
      expect(errors[0].cause.instance_of?(RuntimeError)).to be(true)
      expect(errors[0].line).to eq 2
      expect(errors[0].column).to eq 0
    end

    context 'when passed :raise_error option' do
      let(:options) { { raise_error: true } }

      it 're-raises the exception received while processing' do
        allow(cop).to receive(:on_int) { raise RuntimeError }

        expect { offenses }.to raise_error(RuntimeError)
      end
    end

    context 'when passed :raise_cop_error option' do
      let(:options) { { raise_cop_error: true } }

      it 're-raises the exception received while processing' do
        allow(cop).to receive(:on_int) { raise RuboCop::ErrorWithAnalyzedFileLocation }

        expect { offenses }.to raise_error(RuboCop::ErrorWithAnalyzedFileLocation)
      end
    end

    context 'when given a force' do
      let(:force) { instance_double(RuboCop::Cop::Force).as_null_object }
      let(:forces) { [force] }

      it 'passes the input params to all cops/forces that implement their own ' \
         '#investigate method' do
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
