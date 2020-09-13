# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::StringMethods, :config do
  let(:cop_config) { { 'intern' => 'to_sym' } }

  it 'registers an offense' do
    expect_offense(<<~RUBY)
      'something'.intern
                  ^^^^^^ Prefer `to_sym` over `intern`.
    RUBY

    expect_correction(<<~RUBY)
      'something'.to_sym
    RUBY
  end

  context 'when using safe navigation operator' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        something&.intern
                   ^^^^^^ Prefer `to_sym` over `intern`.
      RUBY

      expect_correction(<<~RUBY)
        something&.to_sym
      RUBY
    end
  end
end
