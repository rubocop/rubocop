# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::StringMethods, :config do
  subject(:cop) { described_class.new(config) }

  let(:cop_config) { { 'intern' => 'to_sym' } }

  let(:source) { "'something'.intern" }
  let(:corrected) { autocorrect_source(source) }

  it 'registers an offense' do
    inspect_source(source)

    expect(cop.offenses.size).to eq(1)
    expect(cop.messages).to eq(['Prefer `to_sym` over `intern`.'])
    expect(cop.highlights).to eq(%w[intern])

    expect(corrected).to eq("'something'.to_sym")
  end
end
