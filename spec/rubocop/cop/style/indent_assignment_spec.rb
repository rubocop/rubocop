# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::IndentAssignment, :config do
  subject(:cop) { described_class.new(config) }
  let(:config) do
    RuboCop::Config.new('Style/IndentAssignment' => {
                          'IndentationWidth' => cop_indent
                        },
                        'Style/IndentationWidth' => { 'Width' => 2 })
  end
  let(:cop_indent) { nil } # use indentation with from Style/IndentationWidth

  it 'registers an offense for incorrectly indented rhs' do
    inspect_source(cop, ['a =',
                         'if b ; end'])

    expect(cop.offenses.length).to eq(1)
    expect(cop.highlights).to eq(['if b ; end'])
    expect(cop.message).to eq(described_class::MSG)
  end

  it 'allows assignments that do not start on a newline' do
    inspect_source(cop, ['a = if b',
                         '      foo',
                         '    end'])

    expect(cop.offenses).to be_empty
  end

  it 'allows a properly indented rhs' do
    inspect_source(cop, ['a =',
                         '  if b ; end'])

    expect(cop.offenses).to be_empty
  end

  it 'registers an offense for multi-lhs' do
    inspect_source(cop, ['a,',
                         'b =',
                         'if b ; end'])

    expect(cop.offenses.length).to eq(1)
    expect(cop.highlights).to eq(['if b ; end'])
    expect(cop.message).to eq(described_class::MSG)
  end

  it 'ignores comparison operators' do
    inspect_source(cop, ['a ===',
                         'if b ; end'])

    expect(cop.offenses).to be_empty
  end

  it 'auto-corrects indentation' do
    new_source = autocorrect_source(
      cop, ['a =',
            'if b ; end'])

    expect(new_source)
      .to eq(['a =',
              '  if b ; end'].join("\n"))
  end

  context 'when indentation width is overridden for this cop only' do
    let(:cop_indent) { 7 }

    it 'allows a properly indented rhs' do
      inspect_source(cop, ['a =',
                           '       if b ; end'])

      expect(cop.offenses).to be_empty
    end

    it 'auto-corrects indentation' do
      new_source = autocorrect_source(
        cop, ['a =',
              '  if b ; end'])

      expect(new_source)
        .to eq(['a =',
                '       if b ; end'].join("\n"))
    end
  end
end
