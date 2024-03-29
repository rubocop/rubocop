# frozen_string_literal: true

RSpec.describe RuboCop::Formatter::HTMLFormatter, :isolated_environment do
  spec_root = File.expand_path('../..', __dir__)

  around do |example|
    project_path = File.join(spec_root, 'fixtures/html_formatter/project')
    FileUtils.cp_r(project_path, '.')

    Dir.chdir(File.basename(project_path)) { example.run }
  end

  let(:enabled_cops) do
    [
      'Layout/EmptyLinesAroundAccessModifier', 'Layout/IndentationConsistency',
      'Layout/IndentationWidth', 'Layout/LineLength', 'Lint/UselessAssignment',
      'Naming/MethodName', 'Style/Documentation', 'Style/EmptyMethod',
      'Style/FrozenStringLiteralComment', 'Style/RedundantRegexpArgument', 'Style/RegexpLiteral',
      'Style/RescueModifier', 'Style/SymbolArray'
    ].join(',')
  end

  let(:options) do
    ['--only', enabled_cops, '--format', 'html', '--out']
  end

  let(:actual_html_path) do
    path = File.expand_path('result.html')
    RuboCop::CLI.new.run([*options, path])
    path
  end

  let(:actual_html_path_cached) do
    path = File.expand_path('result_cached.html')
    2.times { RuboCop::CLI.new.run([*options, path]) }
    path
  end

  let(:actual_html) { File.read(actual_html_path, encoding: Encoding::UTF_8) }

  let(:actual_html_cached) { File.read(actual_html_path_cached, encoding: Encoding::UTF_8) }

  let(:expected_html_path) { File.join(spec_root, 'fixtures/html_formatter/expected.html') }

  let(:expected_html) do
    html = File.read(expected_html_path, encoding: Encoding::UTF_8)
    # Avoid failure on version bump
    html.sub(/(class="version".{0,20})\d+(?:\.\d+){2}/i) do
      Regexp.last_match(1) + RuboCop::Version::STRING
    end
  end

  it 'outputs the result in HTML' do
    # FileUtils.copy(actual_html_path, expected_html_path)
    expect(actual_html).to eq(expected_html)
  end

  it 'outputs the cached result in HTML' do
    # FileUtils.copy(actual_html_path, expected_html_path)
    expect(actual_html_cached).to eq(expected_html)
  end
end
