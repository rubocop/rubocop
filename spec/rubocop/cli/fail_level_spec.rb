# frozen_string_literal: true

RSpec.describe 'RuboCop::CLI --fail-level and AllCops: FailLevel', :isolated_environment do # rubocop:disable RSpec/DescribeClass
  subject(:cli) { RuboCop::CLI.new }

  include_context 'cli spec behavior'

  before do
    # A convention offense (trailing whitespace) and nothing else.
    create_file('example.rb', "# frozen_string_literal: true\n\nputs 1 \n")
  end

  it 'fails on a convention offense by default' do
    expect(cli.run(['--format', 'simple', 'example.rb'])).to eq(1)
  end

  context 'when the configuration raises the fail level' do
    before do
      create_file('.rubocop.yml', <<~YAML)
        AllCops:
          FailLevel: warning
      YAML
    end

    it 'still reports the offense but exits with 0' do
      expect(cli.run(['--format', 'simple', 'example.rb'])).to eq(0)
      expect($stdout.string).to include('Layout/TrailingWhitespace')
    end

    it 'fails once a warning-level offense is present' do
      create_file('example.rb', "# frozen_string_literal: true\n\ndef m\n  x = 1\nend\n")

      expect(cli.run(['--format', 'simple', 'example.rb'])).to eq(1)
      expect($stdout.string).to include('Lint/UselessAssignment')
    end

    it 'lets --fail-level override the configuration' do
      expect(cli.run(['--fail-level', 'C', '--format', 'simple', 'example.rb'])).to eq(1)
    end

    it 'is honored by --display-only-fail-level-offenses' do
      cli.run(['--display-only-fail-level-offenses', '--format', 'simple', 'example.rb'])

      expect($stdout.string).not_to include('Layout/TrailingWhitespace')
    end

    it 'is used by the GitHub Actions formatter to pick the annotation level' do
      cli.run(['--format', 'github', 'example.rb'])

      expect($stdout.string).to include('::warning file=')
      expect($stdout.string).not_to include('::error file=')
    end
  end

  it 'rejects an unknown fail level' do
    create_file('.rubocop.yml', <<~YAML)
      AllCops:
        FailLevel: severe
    YAML

    expect(cli.run(['--format', 'simple', 'example.rb'])).to eq(2)
    expect($stderr.string).to include('invalid severe for `FailLevel`')
  end
end
