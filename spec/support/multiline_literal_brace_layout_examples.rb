# frozen_string_literal: true

RSpec.shared_examples_for 'multiline literal brace layout' do
  include MultilineLiteralBraceHelper

  let(:prefix) { '' } # A prefix before the opening brace.
  let(:suffix) { '' } # A suffix for the line after the closing brace.
  let(:a) { 'a' } # The first element.
  let(:b) { 'b' } # The second element.
  let(:b_comment) { '' } # Comment after the second element.
  let(:multi_prefix) { '' } # Prefix multi and heredoc with this.
  let(:multi) do # A viable multi-line element.
    <<~RUBY.chomp
      {
      foo: bar
      }
    RUBY
  end
  # This heredoc is unsafe to edit around because it ends on the same line as
  # the node itself.
  let(:heredoc) do
    <<~RUBY.chomp
      <<-EOM
      baz
      EOM
    RUBY
  end
  # This heredoc is safe to edit around because it ends on a line before the
  # last line of the node.
  let(:safe_heredoc) do
    <<~RUBY.chomp
      {
      a: <<-EOM
      baz
      EOM
      }
    RUBY
  end

  def make_multi(multi)
    multi = multi.dup
    multi[0] = multi_prefix + multi[0]
    multi
  end

  context 'heredoc' do
    let(:cop_config) { { 'EnforcedStyle' => 'same_line' } }

    it 'ignores heredocs that could share a last line' do
      expect_no_offenses(construct(false, a, make_multi(heredoc), true))
    end

    it 'detects heredoc structures that are safe to add to' do
      expect_offense(<<~RUBY, close: close)
        #{prefix}#{open}#{a},
        #{multi_prefix}#{safe_heredoc}
        %{close}
        ^{close} #{described_class::ALWAYS_SAME_LINE_MESSAGE}
        #{suffix}
      RUBY

      expect_correction(<<~RUBY)
        #{prefix}#{open}#{a},
        #{multi_prefix}#{safe_heredoc}#{close}
        #{suffix}
      RUBY
    end
  end

  context 'symmetrical style' do
    let(:cop_config) { { 'EnforcedStyle' => 'symmetrical' } }

    context 'opening brace on same line as first element' do
      it 'allows closing brace on same line as last element' do
        expect_no_offenses(construct(false, false))
      end

      it 'allows closing brace on same line as last multiline element' do
        expect_no_offenses(construct(false, a, make_multi(multi), false))
      end

      it 'detects closing brace on different line from last element' do
        expect_offense(<<~RUBY, close: close)
          #{prefix}#{open}#{a},
          #{b}#{b_comment}
          %{close}
          ^{close} #{described_class::SAME_LINE_MESSAGE}
          #{suffix}
        RUBY
      end

      it 'autocorrects closing brace on different line from last element' do
        expect_offense(<<~RUBY, close: close)
          #{prefix}#{open}#{a}, # a
          #{b} # b
          %{close}
          ^{close} #{described_class::SAME_LINE_MESSAGE}
          #{suffix}
        RUBY

        expect_correction(<<~RUBY)
          #{prefix}#{open}#{a}, # a
          #{b}#{close} # b
          #{suffix}
        RUBY
      end

      unless described_class == RuboCop::Cop::Layout::MultilineMethodDefinitionBraceLayout
        context 'with a chained call on the closing brace' do
          let(:suffix) { '.any?' }

          context 'and a comment after the last element' do
            let(:b_comment) { ' # comment b' }

            it 'detects closing brace on separate line from last element' \
               'but does not autocorrect the closing brace' do
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
    end

    context 'opening brace on separate line from first element' do
      it 'allows closing brace on separate line from last element' do
        expect_no_offenses(construct(true, true))
      end

      it 'allows closing brace on separate line from last multiline element' do
        expect_no_offenses(construct(true, a, make_multi(multi), true))
      end

      it 'detects closing brace on same line as last element' do
        expect_offense(<<~RUBY.chomp, b: b, close: close)
          #{prefix}#{open}
          #{a},
          %{b}%{close}
          _{b}^{close} #{described_class::NEW_LINE_MESSAGE}
          #{suffix}
        RUBY

        expect_correction(construct(true, true))
      end
    end
  end

  context 'new_line style' do
    let(:cop_config) { { 'EnforcedStyle' => 'new_line' } }

    context 'opening brace on same line as first element' do
      it 'allows closing brace on different line from last element' do
        expect_no_offenses(construct(false, true))
      end

      it 'allows closing brace on different line from multi-line element' do
        expect_no_offenses(construct(false, a, make_multi(multi), true))
      end

      it 'detects closing brace on same line as last multiline element' do
        expect_offense(<<~RUBY, multi_end: multi.lines.last.chomp, close: close)
          #{prefix}#{open}#{a},
          #{multi_prefix}#{multi}#{close}
          _{multi_end}^{close} #{described_class::ALWAYS_NEW_LINE_MESSAGE}
          #{suffix}
        RUBY
      end

      it 'autocorrects closing brace on same line as last element' do
        expect_offense(<<~RUBY, b: b, close: close)
          #{prefix}#{open}#{a}, # a
          %{b}%{close} # b
          _{b}^{close} #{described_class::ALWAYS_NEW_LINE_MESSAGE}
          #{suffix}
        RUBY

        expect_correction(<<~RUBY)
          #{prefix}#{open}#{a}, # a
          #{b}
          #{close} # b
          #{suffix}
        RUBY
      end
    end

    context 'opening brace on separate line from first element' do
      it 'allows closing brace on separate line from last element' do
        expect_no_offenses(construct(true, true))
      end

      it 'allows closing brace on separate line from last multiline element' do
        expect_no_offenses(construct(true, a, make_multi(multi), true))
      end

      it 'detects closing brace on same line as last element' do
        expect_offense(<<~RUBY, b: b, close: close)
          #{prefix}#{open}
          #{a},
          %{b}%{close}
          _{b}^{close} #{described_class::ALWAYS_NEW_LINE_MESSAGE}
          #{suffix}
        RUBY

        expect_correction(<<~RUBY)
          #{construct(true, true)}
        RUBY
      end
    end
  end

  context 'same_line style' do
    let(:cop_config) { { 'EnforcedStyle' => 'same_line' } }

    context 'opening brace on same line as first element' do
      it 'allows closing brace on same line from last element' do
        expect_no_offenses(construct(false, false))
      end

      it 'allows closing brace on same line as multi-line element' do
        expect_no_offenses(construct(false, a, make_multi(multi), false))
      end

      it 'detects closing brace on different line from multiline element' do
        expect_offense(<<~RUBY, close: close)
          #{prefix}#{open}#{a},
          #{multi_prefix}#{multi}
          %{close}
          ^{close} #{described_class::ALWAYS_SAME_LINE_MESSAGE}
          #{suffix}
        RUBY
      end

      it 'autocorrects closing brace on different line as last element' do
        expect_offense(<<~RUBY, close: close)
          #{prefix}#{open}#{a}, # a
          #{b} # b
          %{close}
          ^{close} #{described_class::ALWAYS_SAME_LINE_MESSAGE}
          #{suffix}
        RUBY

        expect_correction(<<~RUBY)
          #{prefix}#{open}#{a}, # a
          #{b}#{close} # b
          #{suffix}
        RUBY
      end

      unless described_class == RuboCop::Cop::Layout::MultilineMethodDefinitionBraceLayout
        context 'with a chained call on the closing brace' do
          let(:suffix) { '.any?' }

          context 'and a comment after the last element' do
            let(:b_comment) { ' # comment b' }

            it 'detects closing brace on separate line from last element' \
               'but does not autocorrect the closing brace' do
              expect_offense(<<~RUBY, close: close)
                #{prefix}#{open}#{a},
                #{b}#{b_comment}
                %{close}
                ^{close} #{described_class::ALWAYS_SAME_LINE_MESSAGE}
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
                ^{close} #{described_class::ALWAYS_SAME_LINE_MESSAGE}
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
    end

    context 'opening brace on separate line from first element' do
      it 'allows closing brace on same line as last element' do
        expect_no_offenses(construct(true, false))
      end

      it 'allows closing brace on same line as last multiline element' do
        expect_no_offenses(construct(true, a, make_multi(multi), false))
      end

      it 'detects closing brace on different line from last element' do
        expect_offense(<<~RUBY, close: close)
          #{prefix}#{open}
          #{a},
          #{b}#{b_comment}
          %{close}
          ^{close} #{described_class::ALWAYS_SAME_LINE_MESSAGE}
          #{suffix}
        RUBY

        expect_correction(<<~RUBY)
          #{construct(true, false)}
        RUBY
      end
    end
  end
end
