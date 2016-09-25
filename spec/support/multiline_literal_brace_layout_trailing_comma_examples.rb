# frozen_string_literal: true

shared_examples_for 'multiline literal brace layout trailing comma' do
  let(:prefix) { '' } # A prefix before the opening brace.
  let(:suffix) { '' } # A suffix for the line after the closing brace.
  let(:open) { nil } # The opening brace.
  let(:close) { nil } # The closing brace.
  let(:a) { 'a' } # The first element.
  let(:b) { 'b' } # The second element.

  context 'symmetrical style' do
    let(:cop_config) { { 'EnforcedStyle' => 'symmetrical' } }

    context 'opening brace on same line as first element' do
      context 'last element has a trailing comma' do
        it 'autocorrects closing brace on different line from last element' do
          new_source = autocorrect_source(cop, ["#{prefix}#{open}#{a}, # a",
                                                "#{b}, # b",
                                                close,
                                                suffix])

          expect(new_source)
            .to eq("#{prefix}#{open}#{a}, # a\n#{b},#{close} # b\n#{suffix}")
        end
      end
    end
  end

  context 'same_line style' do
    let(:cop_config) { { 'EnforcedStyle' => 'same_line' } }

    context 'opening brace on same line as first element' do
      context 'last element has a trailing comma' do
        it 'autocorrects closing brace on different line as last element' do
          new_source = autocorrect_source(cop, ["#{prefix}#{open}#{a}, # a",
                                                "#{b}, # b",
                                                close,
                                                suffix])

          expect(new_source)
            .to eq("#{prefix}#{open}#{a}, # a\n#{b},#{close} # b\n#{suffix}")
        end
      end
    end
  end
end
