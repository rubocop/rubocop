# frozen_string_literal: true

RSpec.describe RuboCop::Formatter::MarkdownFormatter, :isolated_environment do
  spec_root = File.expand_path('../..', __dir__)

  around do |example|
    project_path = File.join(spec_root, 'fixtures/markdown_formatter/project')
    FileUtils.cp_r(project_path, '.')

    Dir.chdir(File.basename(project_path)) { example.run }
  end

  # Run without Style/EndOfLine as it gives different results on
  # different platforms.
  # Metrics/AbcSize is very strict, exclude it too
  let(:options) { %w[--except Layout/EndOfLine,Metrics/AbcSize --format markdown --out] }

  let(:actual_markdown_path) do
    path = File.expand_path('result.md')
    RuboCop::CLI.new.run([*options, path])
    path
  end

  let(:actual_markdown_path_cached) do
    path = File.expand_path('result_cached.md')
    2.times { RuboCop::CLI.new.run([*options, path]) }
    path
  end

  let(:actual_markdown) { File.read(actual_markdown_path, encoding: Encoding::UTF_8) }

  let(:actual_markdown_cached) { File.read(actual_markdown_path_cached, encoding: Encoding::UTF_8) }

  let(:expected_markdown_path) { File.join(spec_root, 'fixtures/markdown_formatter/expected.md') }

  let(:expected_markdown) do
    markdown = File.read(expected_markdown_path, encoding: Encoding::UTF_8)
    # Avoid failure on version bump
    markdown.sub(/(class="version".{0,20})\d+(?:\.\d+){2}/i) do
      Regexp.last_match(1) + RuboCop::Version::STRING
    end
  end

  it 'outputs the result in Markdown' do
    expect(actual_markdown).to eq(expected_markdown)
  end

  it 'outputs the cached result in Markdown' do
    expect(actual_markdown_cached).to eq(expected_markdown)
  end
end
