# frozen_string_literal: true

RSpec.describe RuboCop::Cop::AlignmentCorrector do
  let(:cop) { RuboCop::Cop::Test::AlignmentDirective.new }

  describe '#correct' do
    context 'simple indentation' do
      context 'with a positive column delta' do
        it 'indents' do
          expect(autocorrect_source(<<~INPUT)).to eq(<<~OUTPUT)
            # >> 2
              42
          INPUT
            # >> 2
                42
          OUTPUT
        end
      end

      context 'with a negative column delta' do
        it 'outdents' do
          expect(autocorrect_source(<<~INPUT)).to eq(<<~OUTPUT)
            # << 3
                42
          INPUT
            # << 3
             42
          OUTPUT
        end
      end
    end
  end
end
