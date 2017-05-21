# frozen_string_literal: true

describe RuboCop::Cop::Layout::IndentAssignment, :config do
  subject(:cop) { described_class.new(config) }
  let(:config) do
    RuboCop::Config.new('Layout/IndentAssignment' => {
                          'IndentationWidth' => cop_indent
                        },
                        'Layout/IndentationWidth' => { 'Width' => 2 })
  end
  let(:cop_indent) { nil } # use indentation with from Layout/IndentationWidth

  let(:message) do
    'Indent the first line of the right-hand-side of a multi-line assignment.'
  end

  it 'registers an offense for incorrectly indented rhs' do
    inspect_source(cop, <<-END.strip_indent)
      a =
      if b ; end
    END

    expect(cop.offenses.length).to eq(1)
    expect(cop.highlights).to eq(['if b ; end'])
    expect(cop.message).to eq(message)
  end

  it 'allows assignments that do not start on a newline' do
    expect_no_offenses(<<-END.strip_indent)
      a = if b
            foo
          end
    END
  end

  it 'allows a properly indented rhs' do
    expect_no_offenses(<<-END.strip_indent)
      a =
        if b ; end
    END
  end

  it 'allows a properly indented rhs with fullwidth characters' do
    expect_no_offenses(<<-END.strip_indent)
      f 'Ｒｕｂｙ', a =
                      b
    END
  end

  it 'registers an offense for multi-lhs' do
    inspect_source(cop, <<-END.strip_indent)
      a,
      b =
      if b ; end
    END

    expect(cop.offenses.length).to eq(1)
    expect(cop.highlights).to eq(['if b ; end'])
    expect(cop.message).to eq(message)
  end

  it 'ignores comparison operators' do
    expect_no_offenses(<<-END.strip_indent)
      a ===
      if b ; end
    END
  end

  it 'auto-corrects indentation' do
    new_source = autocorrect_source(
      cop, <<-END.strip_indent
        a =
        if b ; end
      END
    )

    expect(new_source)
      .to eq(<<-END.strip_indent)
        a =
          if b ; end
      END
  end

  context 'when indentation width is overridden for this cop only' do
    let(:cop_indent) { 7 }

    it 'allows a properly indented rhs' do
      expect_no_offenses(<<-END.strip_indent)
        a =
               if b ; end
      END
    end

    it 'auto-corrects indentation' do
      new_source = autocorrect_source(
        cop, <<-END.strip_indent
          a =
            if b ; end
        END
      )

      expect(new_source)
        .to eq(<<-END.strip_indent)
          a =
                 if b ; end
        END
    end
  end
end
