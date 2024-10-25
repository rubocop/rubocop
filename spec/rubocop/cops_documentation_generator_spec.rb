# frozen_string_literal: true

require 'rubocop/cops_documentation_generator'

RSpec.describe CopsDocumentationGenerator do
  around do |example|
    new_global = RuboCop::Cop::Registry.new([RuboCop::Cop::Style::HashSyntax])
    RuboCop::Cop::Registry.with_temporary_global(new_global) { example.run }
  end

  it 'generates docs without errors' do
    Dir.mktmpdir do |tmpdir|
      generator = described_class.new(departments: %w[Style], base_dir: tmpdir)
      expect do
        generator.call
      end.to output(%r{generated .*docs/modules/ROOT/pages/cops_style.adoc}).to_stdout
    end
  end
end
