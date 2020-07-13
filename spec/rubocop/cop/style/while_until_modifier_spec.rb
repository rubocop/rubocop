# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::WhileUntilModifier, :config do
  it_behaves_like 'condition modifier cop', :while
  it_behaves_like 'condition modifier cop', :until
end
