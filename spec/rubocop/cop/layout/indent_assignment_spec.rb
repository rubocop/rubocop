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
    inspect_source(cop, <<-RUBY.strip_indent)
      a =
      if b ; end
    RUBY

    expect(cop.offenses.length).to eq(1)
    expect(cop.highlights).to eq(['if b ; end'])
    expect(cop.message).to eq(message)
  end

  it 'allows assignments that do not start on a newline' do
    expect_no_offenses(<<-RUBY.strip_indent)
      a = if b
            foo
          end
    RUBY
  end

  it 'allows a properly indented rhs' do
    expect_no_offenses(<<-RUBY.strip_indent)
      a =
        if b ; end
    RUBY
  end

  it 'allows a properly indented rhs with fullwidth characters' do
    expect_no_offenses(<<-RUBY.strip_indent)
      f 'Ｒｕｂｙ', a =
                      b
    RUBY
  end

  it 'registers an offense for multi-lhs' do
    inspect_source(cop, <<-RUBY.strip_indent)
      a,
      b =
      if b ; end
    RUBY

    expect(cop.offenses.length).to eq(1)
    expect(cop.highlights).to eq(['if b ; end'])
    expect(cop.message).to eq(message)
  end

  it 'ignores comparison operators' do
    expect_no_offenses(<<-RUBY.strip_indent)
      a ===
      if b ; end
    RUBY
  end

  it 'auto-corrects indentation' do
    new_source = autocorrect_source(
      cop, <<-RUBY.strip_indent
        a =
        if b ; end
      RUBY
    )

    expect(new_source)
      .to eq(<<-RUBY.strip_indent)
        a =
          if b ; end
      RUBY
  end

  context 'when indentation width is overridden for this cop only' do
    let(:cop_indent) { 7 }

    it 'allows a properly indented rhs' do
      expect_no_offenses(<<-RUBY.strip_indent)
        a =
               if b ; end
      RUBY
    end

    it 'auto-corrects indentation' do
      new_source = autocorrect_source(
        cop, <<-RUBY.strip_indent
          a =
            if b ; end
        RUBY
      )

      expect(new_source)
        .to eq(<<-RUBY.strip_indent)
          a =
                 if b ; end
        RUBY
    end
  end
end
