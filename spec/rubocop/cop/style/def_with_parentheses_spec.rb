# frozen_string_literal: true

describe RuboCop::Cop::Style::DefWithParentheses do
  subject(:cop) { described_class.new }

  it 'reports an offense for def with empty parens' do
    src = ['def func()',
           'end']
    inspect_source(cop, src)
    expect(cop.offenses.size).to eq(1)
  end

  it 'reports an offense for class def with empty parens' do
    src = ['def Test.func()',
           'end']
    inspect_source(cop, src)
    expect(cop.offenses.size).to eq(1)
  end

  it 'accepts def with arg and parens' do
    src = ['def func(a)',
           'end']
    inspect_source(cop, src)
    expect(cop.offenses).to be_empty
  end

  it 'accepts empty parentheses in one liners' do
    src = "def to_s() join '/' end"
    inspect_source(cop, src)
    expect(cop.offenses).to be_empty
  end

  it 'auto-removes unneeded parens' do
    new_source = autocorrect_source(cop, ['def test();',
                                          'something',
                                          'end'])
    expect(new_source).to eq(['def test;',
                              'something',
                              'end'].join("\n"))
  end
end
