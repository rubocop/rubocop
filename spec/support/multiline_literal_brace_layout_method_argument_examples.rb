# frozen_string_literal: true

RSpec.shared_examples_for 'multiline literal brace layout method argument' do
  include MultilineLiteralBraceHelper

  context 'when arguments to a method' do
    let(:prefix) { 'bar(' }
    let(:suffix) { ')' }

    context 'and a comment after the last element' do
      let(:b_comment) { ' # comment b' }

      it 'detects closing brace on separate line from last element' do
        expect_offense(<<~RUBY, close: close)
          #{prefix}#{open}#{a},
          #{b}#{b_comment}
          %{close}
          ^{close} #{described_class::SAME_LINE_MESSAGE}
          #{suffix}
        RUBY

        expect_no_corrections
      end
    end

    context 'but no comment after the last element' do
      it 'autocorrects the closing brace' do
        expect_offense(<<~RUBY, close: close)
          #{prefix}#{open}#{a},
          #{b}
          %{close}
          ^{close} #{described_class::SAME_LINE_MESSAGE}
          #{suffix}
        RUBY

        expect_correction(<<~RUBY)
          #{prefix}#{open}#{a},
          #{b}#{close}
          #{suffix}
        RUBY
      end
    end
  end
end
