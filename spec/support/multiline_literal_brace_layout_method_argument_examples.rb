# frozen_string_literal: true

shared_examples_for 'multiline literal brace layout method argument' do
  include MultilineLiteralBraceHelper

  context 'when arguments to a method' do
    let(:prefix) { 'bar(' }
    let(:suffix) { ')' }
    let(:source) { construct(false, true) }

    context 'and a comment after the last element' do
      let(:b_comment) { ' # comment b' }

      it 'detects closing brace on separate line from last element' do
        inspect_source(source)

        expect(cop.highlights).to eq([close])
        expect(cop.messages)
          .to eq([described_class::SAME_LINE_MESSAGE])
      end

      it 'does not autocorrect the closing brace' do
        new_source = autocorrect_source(source)
        expect(new_source).to eq([source].join($RS))
      end
    end

    context 'but no comment after the last element' do
      let(:b_comment) { '' }

      it 'autocorrects the closing brace' do
        new_source = autocorrect_source(source)

        expect(new_source).to eq(["#{prefix}#{open}#{a},",
                                  "#{b}#{close}",
                                  suffix].join($RS))
      end
    end
  end
end
