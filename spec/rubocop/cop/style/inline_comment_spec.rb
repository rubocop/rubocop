# frozen_string_literal: true

describe RuboCop::Cop::Style::InlineComment do
  subject(:cop) { described_class.new }

  it 'registers an offense for a trailing inline comment' do
    inspect_source(cop, 'two = 1 + 1 # A trailing inline comment')

    expect(cop.offenses.size).to eq(1)
    expect(cop.messages).to eq(['Avoid trailing inline comments.'])
    expect(cop.highlights).to eq(['# A trailing inline comment'])
  end

  it 'does not register an offense for a standalone comment' do
    expect_no_offenses('# A standalone comment')
  end
end
