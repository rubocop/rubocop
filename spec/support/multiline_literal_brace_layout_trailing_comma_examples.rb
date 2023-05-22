# frozen_string_literal: true

RSpec.shared_examples_for 'multiline literal brace layout trailing comma' do
  let(:prefix) { '' } # A prefix before the opening brace.
  let(:suffix) { '' } # A suffix for the line after the closing brace.
  let(:a) { 'a' } # The first element.
  let(:b) { 'b' } # The second element.

  context 'symmetrical style' do
    let(:cop_config) { { 'EnforcedStyle' => 'symmetrical' } }

    context 'opening brace on same line as first element' do
      context 'last element has a trailing comma' do
        it 'autocorrects closing brace on different line from last element' do
          expect_offense(<<~RUBY.chomp)
            #{prefix}#{open}#{a}, # a
            #{b}, # b
            #{close}
            ^ #{same_line_message}
            #{suffix}
          RUBY

          expect_correction(<<~RUBY.chomp)
            #{prefix}#{open}#{a}, # a
            #{b},#{close} # b
            #{suffix}
          RUBY
        end
      end
    end
  end

  context 'same_line style' do
    let(:cop_config) { { 'EnforcedStyle' => 'same_line' } }

    context 'opening brace on same line as first element' do
      context 'last element has a trailing comma' do
        it 'autocorrects closing brace on different line as last element' do
          expect_offense(<<~RUBY.chomp)
            #{prefix}#{open}#{a}, # a
            #{b}, # b
            #{close}
            ^ #{always_same_line_message}
            #{suffix}
          RUBY

          expect_correction(<<~RUBY.chomp)
            #{prefix}#{open}#{a}, # a
            #{b},#{close} # b
            #{suffix}
          RUBY
        end
      end
    end
  end
end
