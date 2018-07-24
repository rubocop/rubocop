# frozen_string_literal: true

shared_examples_for 'multiline literal brace layout' do
  include MultilineLiteralBraceHelper

  let(:prefix) { '' } # A prefix before the opening brace.
  let(:suffix) { '' } # A suffix for the line after the closing brace.
  let(:open) { nil } # The opening brace.
  let(:close) { nil } # The closing brace.
  let(:a) { 'a' } # The first element.
  let(:b) { 'b' } # The second element.
  let(:b_comment) { '' } # Comment after the second element.
  let(:multi_prefix) { '' } # Prefix multi and heredoc with this.
  let(:multi) do # A viable multi-line element.
    <<-RUBY.strip_indent.chomp
      {
      foo: bar
      }
    RUBY
  end
  # This heredoc is unsafe to edit around because it ends on the same line as
  # the node itself.
  let(:heredoc) do
    <<-RUBY.strip_indent.chomp
      <<-EOM
      baz
      EOM
    RUBY
  end
  # This heredoc is safe to edit around because it ends on a line before the
  # last line of the node.
  let(:safe_heredoc) do
    <<-RUBY.strip_indent.chomp
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
      inspect_source(construct(false, a, make_multi(safe_heredoc), true))

      expect(cop.offenses.size).to eq(1)
    end

    it 'auto-corrects safe heredoc offenses' do
      new_source = autocorrect_source(
        construct(false, a, make_multi(safe_heredoc), true)
      )

      expect(new_source)
        .to eq(construct(false, a, make_multi(safe_heredoc), false))
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
        src = construct(false, true)
        inspect_source(src)

        expect(cop.offenses.size).to eq(1)
        expect(cop.highlights).to eq([close])
        expect(cop.messages).to eq([described_class::SAME_LINE_MESSAGE])
      end

      it 'autocorrects closing brace on different line from last element' do
        new_source = autocorrect_source(<<-RUBY.strip_indent.chomp)
          #{prefix}#{open}#{a}, # a
          #{b} # b
          #{close}
          #{suffix}
        RUBY

        expect(new_source)
          .to eq("#{prefix}#{open}#{a}, # a\n#{b}#{close} # b\n#{suffix}")
      end

      unless described_class ==
             RuboCop::Cop::Layout::MultilineMethodDefinitionBraceLayout
        context 'with a chained call on the closing brace' do
          let(:suffix) { '.any?' }
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
              expect(new_source).to eq(source)
            end
          end

          context 'but no comment after the last element' do
            it 'autocorrects the closing brace' do
              new_source = autocorrect_source(source)

              expect(new_source).to eq(["#{prefix}#{open}#{a},",
                                        "#{b}#{close}",
                                        suffix].join($RS))
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
        src = construct(true, false)
        inspect_source(src)

        expect(cop.offenses.size).to eq(1)
        expect(cop.highlights).to eq([close])
        expect(cop.messages).to eq([described_class::NEW_LINE_MESSAGE])
      end

      it 'autocorrects closing brace on same line from last element' do
        new_source = autocorrect_source(construct(true, false))

        expect(new_source).to eq(construct(true, true))
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

      it 'detects closing brace on same line as last element' do
        src = construct(false, false)
        inspect_source(src)

        expect(cop.offenses.size).to eq(1)
        expect(cop.highlights).to eq([close])
        expect(cop.messages).to eq([described_class::ALWAYS_NEW_LINE_MESSAGE])
      end

      it 'detects closing brace on same line as last multiline element' do
        src = construct(false, a, make_multi(multi), false)
        inspect_source(src)

        expect(cop.offenses.size).to eq(1)
        expect(cop.highlights).to eq([close])
        expect(cop.messages).to eq([described_class::ALWAYS_NEW_LINE_MESSAGE])
      end

      it 'autocorrects closing brace on same line as last element' do
        new_source = autocorrect_source(<<-RUBY.strip_indent.chomp)
          #{prefix}#{open}#{a}, # a
          #{b}#{close} # b
          #{suffix}
        RUBY

        expect(new_source)
          .to eq("#{prefix}#{open}#{a}, # a\n#{b}\n#{close} # b\n#{suffix}")
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
        src = construct(true, false)
        inspect_source(src)

        expect(cop.offenses.size).to eq(1)
        expect(cop.highlights).to eq([close])
        expect(cop.messages).to eq([described_class::ALWAYS_NEW_LINE_MESSAGE])
      end

      it 'autocorrects closing brace on same line from last element' do
        new_source = autocorrect_source(construct(true, false))

        expect(new_source).to eq(construct(true, true))
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

      it 'detects closing brace on different line from last element' do
        src = construct(false, true)
        inspect_source(src)

        expect(cop.offenses.size).to eq(1)
        expect(cop.highlights).to eq([close])
        expect(cop.messages).to eq([described_class::ALWAYS_SAME_LINE_MESSAGE])
      end

      it 'detects closing brace on different line from multiline element' do
        src = construct(false, a, make_multi(multi), true)
        inspect_source(src)

        expect(cop.offenses.size).to eq(1)
        expect(cop.highlights).to eq([close])
        expect(cop.messages).to eq([described_class::ALWAYS_SAME_LINE_MESSAGE])
      end

      it 'autocorrects closing brace on different line as last element' do
        new_source = autocorrect_source(<<-RUBY.strip_indent.chomp)
          #{prefix}#{open}#{a}, # a
          #{b} # b
          #{close}
          #{suffix}
        RUBY

        expect(new_source)
          .to eq("#{prefix}#{open}#{a}, # a\n#{b}#{close} # b\n#{suffix}")
      end

      unless described_class ==
             RuboCop::Cop::Layout::MultilineMethodDefinitionBraceLayout
        context 'with a chained call on the closing brace' do
          let(:suffix) { '.any?' }
          let(:source) { construct(false, true) }

          context 'and a comment after the last element' do
            let(:b_comment) { ' # comment b' }

            it 'detects closing brace on separate line from last element' do
              inspect_source(source)

              expect(cop.highlights).to eq([close])
              expect(cop.messages)
                .to eq([described_class::ALWAYS_SAME_LINE_MESSAGE])
            end

            it 'does not autocorrect the closing brace' do
              new_source = autocorrect_source(source)
              expect(new_source).to eq(source)
            end
          end

          context 'but no comment after the last element' do
            it 'autocorrects the closing brace' do
              new_source = autocorrect_source(source)

              expect(new_source).to eq(["#{prefix}#{open}#{a},",
                                        "#{b}#{close}",
                                        suffix].join($RS))
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
        src = construct(true, true)
        inspect_source(src)
        expect(cop.offenses.size).to eq(1)
        expect(cop.highlights).to eq([close])
        expect(cop.messages).to eq([described_class::ALWAYS_SAME_LINE_MESSAGE])
      end

      it 'autocorrects closing brace on different line from last element' do
        new_source = autocorrect_source(construct(true, true))

        expect(new_source).to eq(construct(true, false))
      end
    end
  end
end
