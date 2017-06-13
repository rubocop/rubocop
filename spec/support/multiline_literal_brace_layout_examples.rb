# frozen_string_literal: true

shared_examples_for 'multiline literal brace layout' do
  let(:prefix) { '' } # A prefix before the opening brace.
  let(:suffix) { '' } # A suffix for the line after the closing brace.
  let(:open) { nil } # The opening brace.
  let(:close) { nil } # The closing brace.
  let(:a) { 'a' } # The first element.
  let(:b) { 'b' } # The second element.
  let(:multi_prefix) { '' } # Prefix multi and heredoc with this.
  let(:multi) { ['{', 'foo: bar', '}'] } # A viable multi-line element.
  # This heredoc is unsafe to edit around because it ends on the same line as
  # the node itself.
  let(:heredoc) { ['<<-EOM', 'baz', 'EOM'] }
  # This heredoc is safe to edit around because it ends on a line before the
  # last line of the node.
  let(:safe_heredoc) { ['{', 'a: <<-EOM', 'baz', 'EOM', '}'] }

  def make_multi(multi)
    multi = multi.dup
    multi[0] = multi_prefix + multi[0]
    multi
  end

  # Construct the source code for the braces. For instance, for an array
  # the `open` brace would be `[` and the `close` brace would be `]`, so
  # you could construct the following:
  #
  #     braces(true, 'a', 'b', 'c', false)
  #
  #     [ # line break indicated by `true` as the first argument.
  #     a,
  #     b,
  #     c] # no line break indicated by `false` as the last argument.
  #
  # This method also supports multi-line arguments. For example:
  #
  #     braces(true, 'a', ['{', 'foo: bar', '}'], true)
  #
  #     [ # line break indicated by `true` as the first argument.
  #     a,
  #     {
  #     foo: bar
  #     } # line break indicated by `true` as the last argument.
  #     ]
  def braces(open_line_break, *args, close_line_break)
    args = [a, b] if args.empty?

    open + (open_line_break ? "\n" : '') +
      args.map { |a| a.respond_to?(:join) ? a.join("\n") : a }.join(",\n") +
      (close_line_break ? "\n" : '') + close
  end

  # Construct a piece of source code for brace layout testing. This farms
  # out most of the work to `#braces` but it also includes a prefix and suffix.
  def construct(*args)
    (prefix + braces(*args) + "\n" + suffix).split("\n")
  end

  context 'heredoc' do
    let(:cop_config) { { 'EnforcedStyle' => 'same_line' } }

    it 'ignores heredocs that could share a last line' do
      inspect_source(construct(false, a, make_multi(heredoc), true))

      expect(cop.offenses).to be_empty
    end

    it 'detects heredoc structures that are safe to add to' do
      inspect_source(construct(false, a, make_multi(safe_heredoc), true))

      expect(cop.offenses.size).to eq(1)
    end

    it 'auto-corrects safe heredoc offenses' do
      new_source = autocorrect_source(
        cop, construct(false, a, make_multi(safe_heredoc), true)
      )

      expect(new_source)
        .to eq(construct(false, a, make_multi(safe_heredoc), false).join("\n"))
    end
  end

  context 'symmetrical style' do
    let(:cop_config) { { 'EnforcedStyle' => 'symmetrical' } }

    context 'opening brace on same line as first element' do
      it 'allows closing brace on same line as last element' do
        inspect_source(construct(false, false))

        expect(cop.offenses).to be_empty
      end

      it 'allows closing brace on same line as last multiline element' do
        inspect_source(construct(false, a, make_multi(multi), false))

        expect(cop.offenses).to be_empty
      end

      it 'detects closing brace on different line from last element' do
        src = construct(false, true)
        inspect_source(src)

        expect(cop.offenses.size).to eq(1)
        expect(cop.offenses.first.line)
          .to eq(src.length - (suffix.empty? ? 0 : 1))
        expect(cop.highlights).to eq([close])
        expect(cop.messages).to eq([described_class::SAME_LINE_MESSAGE])
      end

      it 'autocorrects closing brace on different line from last element' do
        new_source = autocorrect_source(cop, ["#{prefix}#{open}#{a}, # a",
                                              "#{b} # b",
                                              close,
                                              suffix])

        expect(new_source)
          .to eq("#{prefix}#{open}#{a}, # a\n#{b}#{close} # b\n#{suffix}")
      end
    end

    context 'opening brace on separate line from first element' do
      it 'allows closing brace on separate line from last element' do
        inspect_source(construct(true, true))

        expect(cop.offenses).to be_empty
      end

      it 'allows closing brace on separate line from last multiline element' do
        inspect_source(construct(true, a, make_multi(multi), true))

        expect(cop.offenses).to be_empty
      end

      it 'detects closing brace on same line as last element' do
        src = construct(true, false)
        inspect_source(src)

        expect(cop.offenses.size).to eq(1)
        expect(cop.offenses.first.line)
          .to eq(src.length - (suffix.empty? ? 0 : 1))
        expect(cop.highlights).to eq([close])
        expect(cop.messages).to eq([described_class::NEW_LINE_MESSAGE])
      end

      it 'autocorrects closing brace on same line from last element' do
        new_source = autocorrect_source(cop, construct(true, false))

        expect(new_source).to eq(construct(true, true).join("\n"))
      end
    end
  end

  context 'new_line style' do
    let(:cop_config) { { 'EnforcedStyle' => 'new_line' } }

    context 'opening brace on same line as first element' do
      it 'allows closing brace on different line from last element' do
        inspect_source(construct(false, true))

        expect(cop.offenses).to be_empty
      end

      it 'allows closing brace on different line from multi-line element' do
        inspect_source(construct(false, a, make_multi(multi), true))

        expect(cop.offenses).to be_empty
      end

      it 'detects closing brace on same line as last element' do
        src = construct(false, false)
        inspect_source(src)

        expect(cop.offenses.size).to eq(1)
        expect(cop.offenses.first.line)
          .to eq(src.length - (suffix.empty? ? 0 : 1))
        expect(cop.highlights).to eq([close])
        expect(cop.messages).to eq([described_class::ALWAYS_NEW_LINE_MESSAGE])
      end

      it 'detects closing brace on same line as last multiline element' do
        src = construct(false, a, make_multi(multi), false)
        inspect_source(src)

        expect(cop.offenses.size).to eq(1)
        expect(cop.offenses.first.line)
          .to eq(src.length - (suffix.empty? ? 0 : 1))
        expect(cop.highlights).to eq([close])
        expect(cop.messages).to eq([described_class::ALWAYS_NEW_LINE_MESSAGE])
      end

      it 'autocorrects closing brace on same line as last element' do
        new_source = autocorrect_source(cop, ["#{prefix}#{open}#{a}, # a",
                                              "#{b}#{close} # b",
                                              suffix])

        expect(new_source)
          .to eq("#{prefix}#{open}#{a}, # a\n#{b}\n#{close} # b\n#{suffix}")
      end
    end

    context 'opening brace on separate line from first element' do
      it 'allows closing brace on separate line from last element' do
        inspect_source(construct(true, true))

        expect(cop.offenses).to be_empty
      end

      it 'allows closing brace on separate line from last multiline element' do
        inspect_source(construct(true, a, make_multi(multi), true))

        expect(cop.offenses).to be_empty
      end

      it 'detects closing brace on same line as last element' do
        src = construct(true, false)
        inspect_source(src)

        expect(cop.offenses.size).to eq(1)
        expect(cop.offenses.first.line)
          .to eq(src.length - (suffix.empty? ? 0 : 1))
        expect(cop.highlights).to eq([close])
        expect(cop.messages).to eq([described_class::ALWAYS_NEW_LINE_MESSAGE])
      end

      it 'autocorrects closing brace on same line from last element' do
        new_source = autocorrect_source(cop, construct(true, false))

        expect(new_source).to eq(construct(true, true).join("\n"))
      end
    end
  end

  context 'same_line style' do
    let(:cop_config) { { 'EnforcedStyle' => 'same_line' } }

    context 'opening brace on same line as first element' do
      it 'allows closing brace on same line from last element' do
        inspect_source(construct(false, false))

        expect(cop.offenses).to be_empty
      end

      it 'allows closing brace on same line as multi-line element' do
        inspect_source(construct(false, a, make_multi(multi), false))

        expect(cop.offenses).to be_empty
      end

      it 'detects closing brace on different line from last element' do
        src = construct(false, true)
        inspect_source(src)

        expect(cop.offenses.size).to eq(1)
        expect(cop.offenses.first.line)
          .to eq(src.length - (suffix.empty? ? 0 : 1))
        expect(cop.highlights).to eq([close])
        expect(cop.messages).to eq([described_class::ALWAYS_SAME_LINE_MESSAGE])
      end

      it 'detects closing brace on different line from multiline element' do
        src = construct(false, a, make_multi(multi), true)
        inspect_source(src)

        expect(cop.offenses.size).to eq(1)
        expect(cop.offenses.first.line)
          .to eq(src.length - (suffix.empty? ? 0 : 1))
        expect(cop.highlights).to eq([close])
        expect(cop.messages).to eq([described_class::ALWAYS_SAME_LINE_MESSAGE])
      end

      it 'autocorrects closing brace on different line as last element' do
        new_source = autocorrect_source(cop, ["#{prefix}#{open}#{a}, # a",
                                              "#{b} # b",
                                              close,
                                              suffix])

        expect(new_source)
          .to eq("#{prefix}#{open}#{a}, # a\n#{b}#{close} # b\n#{suffix}")
      end
    end

    context 'opening brace on separate line from first element' do
      it 'allows closing brace on same line as last element' do
        inspect_source(construct(true, false))

        expect(cop.offenses).to be_empty
      end

      it 'allows closing brace on same line as last multiline element' do
        inspect_source(construct(true, a, make_multi(multi), false))

        expect(cop.offenses).to be_empty
      end

      it 'detects closing brace on different line from last element' do
        src = construct(true, true)
        inspect_source(src)
        expect(cop.offenses.size).to eq(1)
        expect(cop.offenses.first.line)
          .to eq(src.length - (suffix.empty? ? 0 : 1))
        expect(cop.highlights).to eq([close])
        expect(cop.messages).to eq([described_class::ALWAYS_SAME_LINE_MESSAGE])
      end

      it 'autocorrects closing brace on different line from last element' do
        new_source = autocorrect_source(cop, construct(true, true))

        expect(new_source).to eq(construct(true, false).join("\n"))
      end
    end
  end
end
