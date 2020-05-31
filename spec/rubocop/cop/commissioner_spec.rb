# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Commissioner do
  describe '#investigate' do
    subject(:offenses) { commissioner.investigate(processed_source) }

    let(:cop) do
      # rubocop:disable RSpec/VerifiedDoubles
      double(RuboCop::Cop::Cop, offenses: []).as_null_object
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

    it 'returns all offenses found by the cops' do
      allow(cop).to receive(:offenses).and_return([1])

      expect(offenses).to eq [1]
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
        expect(cop).to receive(:investigate).with(processed_source)
        expect(force).to receive(:investigate).with(processed_source)

        offenses
      end
    end

    describe 'inline cop settings' do
      let(:cop) do
        # rubocop:disable RSpec/VerifiedDoubles
        double(RuboCop::Cop::Cop, offenses: [], cop_name: 'Test/TheCop', processed_source: processed_source).as_null_object
        # rubocop:enable RSpec/VerifiedDoubles
      end

      let(:source) { <<~RUBY }
        def method0
        0
        end

        # rubocop:set Test/TheCop{Max: 10}
        def method1
        1
        end

        def method2 # rubocop:set Test/TheCop{Max: 5}
        2
        end

        # rubocop:reset Test/TheCop

        def method3
        3
        end
      RUBY

      it "pushes cop's settings according to inline config" do
        expect(cop).to receive(:on_def).ordered

        expect(cop).to receive(:push_config).with('Max' => 10).ordered
        expect(cop).to receive(:on_def).ordered
        expect(cop).to receive(:pop_config)

        expect(cop).to receive(:push_config).with('Max' => 5).ordered
        expect(cop).to receive(:on_def).ordered
        expect(cop).to receive(:pop_config)

        expect(cop).to receive(:on_def).ordered

        offenses
      end
    end
  end
end
