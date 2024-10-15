# frozen_string_literal: true

require 'rubocop/cops_documentation_generator'

RSpec.describe CopsDocumentationGenerator, :isolated_environment do
  around do |example|
    new_global = RuboCop::Cop::Registry.new([RuboCop::Cop::Style::HashSyntax])
    RuboCop::Cop::Registry.with_temporary_global(new_global) { example.run }
  end

  it 'generates docs without errors' do
    generator = described_class.new(departments: %w[Style])
    expect do
      generator.call
    end.to output(%r{generated .*docs/modules/ROOT/pages/cops_style.adoc}).to_stdout
  end
end
