# frozen_string_literal: true

describe RuboCop::Cop::Style::AsciiComments do
  subject(:cop) { described_class.new }

  it 'registers an offense for a comment with non-ascii chars' do
    inspect_source(cop,
                   ['# encoding: utf-8',
                    '# 这是什么？'])
    expect(cop.offenses.size).to eq(1)
    expect(cop.highlights).to eq(['这是什么？'])
    expect(cop.messages)
      .to eq(['Use only ascii symbols in comments.'])
  end

  it 'registers an offense for commentes with mixed chars' do
    inspect_source(cop,
                   ['# encoding: utf-8',
                    '# foo ∂ bar'])
    expect(cop.offenses.size).to eq(1)
    expect(cop.highlights).to eq(['∂'])
    expect(cop.messages)
      .to eq(['Use only ascii symbols in comments.'])
  end

  it 'accepts comments with only ascii chars' do
    inspect_source(cop, '# AZaz1@$%~,;*_`|')
    expect(cop.offenses).to be_empty
  end
end
