# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::FirstArrayElementLineBreak do
  subject(:cop) { described_class.new }

  context 'elements listed on the first line' do
    let(:source) do
      ['a = [:a,',
       '     :b]']
    end
    it 'detects the offense' do
      inspect_source(cop, source)

      expect(cop.offenses.length).to eq(1)
      expect(cop.offenses.first.line).to eq(1)
      expect(cop.highlights).to eq([':a'])
    end

    it 'autocorrects the offense' do
      new_source = autocorrect_source(cop, source)
      # Alignment for the first element is set by IndentationWidth cop,
      # the rest of the elements should be aligned using the AlignArray cop.
      expect(new_source).to eq("a = [\n:a,\n     :b]")
    end
  end

  context 'word arrays' do
    let(:source) do
      ['%w(a b',
       '   c d)']
    end

    it 'detects the offense' do
      inspect_source(cop, source)

      expect(cop.offenses.length).to eq(1)
      expect(cop.offenses.first.line).to eq(1)
      expect(cop.highlights).to eq(['a'])
    end

    it 'autocorrects the offense' do
      new_source = autocorrect_source(cop, source)
      expect(new_source).to eq("%w(\na b\n   c d)")
    end
  end

  context 'array nested in a method call' do
    let(:source) do
      ['method([:foo,',
       '        :bar])']
    end

    it 'detects the offense' do
      inspect_source(cop, source)

      expect(cop.offenses.length).to eq(1)
      expect(cop.offenses.first.line).to eq(1)
      expect(cop.highlights).to eq([':foo'])
    end

    it 'autocorrects the offense' do
      new_source = autocorrect_source(cop, source)

      expect(new_source).to eq(
        "method([\n" \
        ":foo,\n" \
        '        :bar])'
      )
    end
  end

  context 'masgn implicit arrays' do
    let(:source) do
      ['a, b,',
       'c = 1,',
       '2, 3']
    end

    let(:correct_source) do
      ['a, b,',
       'c = ',
       '1,',
       '2, 3'].join("\n")
    end

    it 'detects the offense' do
      inspect_source(cop, source)

      expect(cop.offenses.length).to eq(1)
      expect(cop.offenses.first.line).to eq(2)
      expect(cop.highlights).to eq(['1'])
    end

    it 'autocorrects the offense' do
      new_source = autocorrect_source(cop, source)

      expect(new_source).to eq(correct_source)
    end
  end

  context 'send implicit arrays' do
    let(:source) do
      ['a',
       '.c = 1,',
       '2, 3']
    end

    let(:correct_source) do
      ['a',
       '.c = ',
       '1,',
       '2, 3'].join("\n")
    end

    it 'detects the offense' do
      inspect_source(cop, source)

      expect(cop.offenses.length).to eq(1)
      expect(cop.offenses.first.line).to eq(2)
      expect(cop.highlights).to eq(['1'])
    end

    it 'autocorrects the offense' do
      new_source = autocorrect_source(cop, source)

      expect(new_source).to eq(correct_source)
    end
  end

  it 'ignores properly formatted implicit arrays' do
    inspect_source(
      cop,
      ['a, b,',
       'c =',
       '1, 2,',
       '3']
    )

    expect(cop.offenses).to be_empty
  end

  context 'array assignment' do
    let(:source) do
      ['a,',
       'b = [1,',
       '2]']
    end
  end

  it 'ignores elements listed on a single line' do
    inspect_source(
      cop,
      ['b = [',
       '  :a,',
       '  :b]']
    )

    expect(cop.offenses).to be_empty
  end
end
