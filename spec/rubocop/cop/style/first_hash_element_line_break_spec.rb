# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::FirstHashElementLineBreak do
  subject(:cop) { described_class.new }

  context 'elements listed on the first line' do
    let(:source) do
      ['a = { a: 1,',
       '      b: 2}']
    end

    it 'detects the offense' do
      inspect_source(cop, source)

      expect(cop.offenses.length).to eq(1)
      expect(cop.offenses.first.line).to eq(1)
      expect(cop.highlights).to eq(['a: 1'])
    end

    it 'autocorrects the offense' do
      new_source = autocorrect_source(cop, source)

      expect(new_source).to eq(
        "a = { \n" \
        "a: 1,\n" \
        '      b: 2}'
      )
    end
  end

  context 'hash nested in a method call' do
    let(:source) do
      ['method({ foo: 1,',
       '         bar: 2 })']
    end

    it 'detects the offense' do
      inspect_source(cop, source)

      expect(cop.offenses.length).to eq(1)
      expect(cop.offenses.first.line).to eq(1)
      expect(cop.highlights).to eq(['foo: 1'])
    end

    it 'autocorrects the offense' do
      new_source = autocorrect_source(cop, source)

      expect(new_source).to eq(
        "method({ \n" \
        "foo: 1,\n" \
        '         bar: 2 })'
      )
    end
  end

  it 'ignores implicit hashes in method calls with parens' do
    inspect_source(
      cop,
      ['method(',
       '  foo: 1,',
       '  bar: 2)']
    )

    expect(cop.offenses).to be_empty
  end

  it 'ignores implicit hashes in method calls without parens' do
    inspect_source(
      cop,
      ['method foo: 1,',
       ' bar:2']
    )

    expect(cop.offenses).to be_empty
  end

  it 'ignores implicit hashes in method calls that are improperly formatted' do
    # These are covered by Style/FirstMethodArgumentLineBreak
    inspect_source(
      cop,
      ['method(foo: 1,',
       '  bar: 2)']
    )

    expect(cop.offenses).to be_empty
  end

  it 'ignores elements listed on a single line' do
    inspect_source(
      cop,
      ['b = {',
       '  a: 1,',
       '  b: 2}']
    )

    expect(cop.offenses).to be_empty
  end
end
