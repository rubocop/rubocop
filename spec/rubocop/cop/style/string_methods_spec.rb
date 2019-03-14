# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::StringMethods, :config do
  subject(:cop) { described_class.new(config) }

  let(:cop_config) { { 'intern' => 'to_sym' } }

  it 'registers an offense' do
    expect_offense(<<-RUBY.strip_indent)
      'something'.intern
                  ^^^^^^ Prefer `to_sym` over `intern`.
    RUBY
  end

  it 'auto-corrects' do
    corrected = autocorrect_source("'something'.intern")

    expect(corrected).to eq("'something'.to_sym")
  end

  context 'when using safe navigation operator', :ruby23 do
    it 'registers an offense' do
      expect_offense(<<-RUBY.strip_indent)
      something&.intern
                 ^^^^^^ Prefer `to_sym` over `intern`.
      RUBY
    end

    it 'auto-corrects' do
      corrected = autocorrect_source('something&.intern')

      expect(corrected).to eq('something&.to_sym')
    end
  end
end
