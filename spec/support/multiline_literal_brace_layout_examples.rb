# encoding: utf-8
# frozen_string_literal: true

shared_examples_for 'multiline literal brace layout' do
  let(:prefix) { '' } # A prefix before the opening brace.
  let(:suffix) { '' } # A suffix for the line after the closing brace.
  let(:open) { nil } # The opening brace.
  let(:close) { nil } # The closing brace.
  let(:a) { 'a' } # The first element.
  let(:b) { 'b' } # The second element.
  let(:multi) { ['{', 'foo: bar', '}'] } # A viable multi-line element.

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

  context 'symmetrical style' do
    let(:cop_config) { { 'EnforcedStyle' => 'symmetrical' } }

    context 'opening brace on same line as first element' do
      it 'allows closing brace on same line as last element' do
        inspect_source(cop, construct(false, false))

        expect(cop.offenses).to be_empty
      end

      it 'allows closing brace on same line as last multiline element' do
        inspect_source(cop, construct(false, a, multi, false))

        expect(cop.offenses).to be_empty
      end

      it 'detects closing brace on different line from last element' do
        inspect_source(cop, construct(false, true))

        expect(cop.offenses.size).to eq(1)
        expect(cop.offenses.first.line).to eq(1)
        expect(cop.highlights).to eq([braces(false, true)])
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
        inspect_source(cop, construct(true, true))

        expect(cop.offenses).to be_empty
      end

      it 'allows closing brace on separate line from last multiline element' do
        inspect_source(cop, construct(true, a, multi, true))

        expect(cop.offenses).to be_empty
      end

      it 'detects closing brace on same line as last element' do
        inspect_source(cop, construct(true, false))

        expect(cop.offenses.size).to eq(1)
        expect(cop.offenses.first.line).to eq(1)
        expect(cop.highlights).to eq([braces(true, false)])
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
        inspect_source(cop, construct(false, true))

        expect(cop.offenses).to be_empty
      end

      it 'allows closing brace on different line from multi-line element' do
        inspect_source(cop, construct(false, a, multi, true))

        expect(cop.offenses).to be_empty
      end

      it 'detects closing brace on same line as last element' do
        inspect_source(cop, construct(false, false))

        expect(cop.offenses.size).to eq(1)
        expect(cop.offenses.first.line).to eq(1)
        expect(cop.highlights).to eq([braces(false, false)])
        expect(cop.messages).to eq([described_class::ALWAYS_NEW_LINE_MESSAGE])
      end

      it 'detects closing brace on same line as last multiline element' do
        inspect_source(cop, construct(false, a, multi, false))

        expect(cop.offenses.size).to eq(1)
        expect(cop.offenses.first.line).to eq(1)
        expect(cop.highlights).to eq([braces(false, a, multi, false)])
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
        inspect_source(cop, construct(true, true))

        expect(cop.offenses).to be_empty
      end

      it 'allows closing brace on separate line from last multiline element' do
        inspect_source(cop, construct(true, a, multi, true))

        expect(cop.offenses).to be_empty
      end

      it 'detects closing brace on same line as last element' do
        inspect_source(cop, construct(true, false))

        expect(cop.offenses.size).to eq(1)
        expect(cop.offenses.first.line).to eq(1)
        expect(cop.highlights).to eq([braces(true, false)])
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
        inspect_source(cop, construct(false, false))

        expect(cop.offenses).to be_empty
      end

      it 'allows closing brace on same line as multi-line element' do
        inspect_source(cop, construct(false, a, multi, false))

        expect(cop.offenses).to be_empty
      end

      it 'detects closing brace on different line from last element' do
        inspect_source(cop, construct(false, true))

        expect(cop.offenses.size).to eq(1)
        expect(cop.offenses.first.line).to eq(1)
        expect(cop.highlights).to eq([braces(false, true)])
        expect(cop.messages).to eq([described_class::ALWAYS_SAME_LINE_MESSAGE])
      end

      it 'detects closing brace on different line from multiline element' do
        inspect_source(cop, construct(false, a, multi, true))

        expect(cop.offenses.size).to eq(1)
        expect(cop.offenses.first.line).to eq(1)
        expect(cop.highlights).to eq([braces(false, a, multi, true)])
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
        inspect_source(cop, construct(true, false))

        expect(cop.offenses).to be_empty
      end

      it 'allows closing brace on same line as last multiline element' do
        inspect_source(cop, construct(true, a, multi, false))

        expect(cop.offenses).to be_empty
      end

      it 'detects closing brace on different line from last element' do
        inspect_source(cop, construct(true, true))

        expect(cop.offenses.size).to eq(1)
        expect(cop.offenses.first.line).to eq(1)
        expect(cop.highlights).to eq([braces(true, true)])
        expect(cop.messages).to eq([described_class::ALWAYS_SAME_LINE_MESSAGE])
      end

      it 'autocorrects closing brace on different line from last element' do
        new_source = autocorrect_source(cop, construct(true, true))

        expect(new_source).to eq(construct(true, false).join("\n"))
      end
    end
  end
end
