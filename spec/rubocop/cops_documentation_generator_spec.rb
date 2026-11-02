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

  context 'when a cop has preview defaults' do
    around do |example|
      new_global = RuboCop::Cop::Registry.new([RuboCop::Cop::Style::Documentation])
      RuboCop::Cop::Registry.with_temporary_global(new_global) { example.run }
    end

    it 'renders them in their own section rather than as a parameter' do
      Dir.mktmpdir do |tmpdir|
        generator = described_class.new(departments: %w[Style], base_dir: tmpdir)
        expect { generator.call }.to output.to_stdout

        page = File.read(File.join(tmpdir, 'docs/modules/ROOT/pages/cops_style.adoc'))
        expect(page).to include(<<~ADOC)
          === Preview defaults

          These defaults apply under xref:versioning.adoc#preview[Preview] and are expected to become the regular defaults in the next major release.

          |===
          | Name | Current default | Preview default

          | Enabled
          | `true`
          | `false`
          |===
        ADOC
        expect(page).not_to include("| Preview\n")
      end
    end
  end

  context 'when the department has its own `StyleGuideBaseURL`' do
    before do
      default_config = RuboCop::ConfigLoader.default_configuration
      config_hash = default_config.to_h.merge(
        'Style' => { 'StyleGuideBaseURL' => 'https://style.example.org' }
      )
      RuboCop::ConfigLoader.default_configuration =
        RuboCop::Config.new(config_hash, default_config.loaded_path)
      # Style guide URLs are cached by their `StyleGuide` value only.
      RuboCop::Cop::MessageAnnotator.style_guide_urls.clear
    end

    after do
      RuboCop::ConfigLoader.default_configuration = nil
      RuboCop::Cop::MessageAnnotator.style_guide_urls.clear
    end

    it 'uses the department base URL for style guide references' do
      Dir.mktmpdir do |tmpdir|
        generator = described_class.new(departments: %w[Style], base_dir: tmpdir)
        expect { generator.call }.to output.to_stdout

        page = File.read(File.join(tmpdir, 'docs/modules/ROOT/pages/cops_style.adoc'))
        expect(page).to include(<<~ADOC)
          === References

          * https://style.example.org#hash-literals
        ADOC
      end
    end
  end
end
