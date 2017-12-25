# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::BeginBlock do
  subject(:cop) { described_class.new }

  it 'reports an offense for a BEGIN block' do
    src = 'BEGIN { test }'
    inspect_source(src)
    expect(cop.offenses.size).to eq(1)
  end
end
