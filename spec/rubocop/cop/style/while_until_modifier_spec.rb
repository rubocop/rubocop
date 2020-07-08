# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::WhileUntilModifier, :config do
  it_behaves_like 'condition modifier cop', :while
  it_behaves_like 'condition modifier cop', :until

  # Regression: https://github.com/rubocop-hq/rubocop/issues/4006
  context 'when the modifier condition is multiline' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        foo while bar ||
            ^^^^^ Favor modifier `while` usage when having a single-line body.
          baz
      RUBY
    end
  end
end
