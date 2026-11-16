# frozen_string_literal: true

RSpec.describe 'RuboCop::CLI --files-from', :isolated_environment do # rubocop:disable RSpec/DescribeClass
  subject(:cli) { RuboCop::CLI.new }

  include_context 'cli spec behavior'

  let(:offending_source) { "# frozen_string_literal: true\n\nputs \"offense\"\n" }

  def inspected_basenames
    $stdout.string.split("\n").map { |path| File.basename(path) }
  end

  before do
    create_file('.rubocop.yml', <<~YAML)
      AllCops:
        NewCops: disable
        SuggestExtensions: false
    YAML
    create_file('listed.rb', offending_source)
    create_file('also listed.rb', offending_source)
    create_file('unlisted.rb', offending_source)
  end

  it 'inspects the newline-delimited paths in the list' do
    create_file('list.txt', "listed.rb\r\nalso listed.rb\n\n")

    expect(cli.run(['--files-from', 'list.txt', '--format', 'files'])).to eq(1)
    expect(inspected_basenames).to contain_exactly('listed.rb', 'also listed.rb')
  end

  it 'inspects the NUL-delimited paths in the list' do
    File.binwrite('list.txt', "listed.rb\0also listed.rb\0")

    expect(cli.run(['--files-from', 'list.txt', '--format', 'files'])).to eq(1)
    expect(inspected_basenames).to contain_exactly('listed.rb', 'also listed.rb')
  end

  it 'inspects the listed paths alongside the ones on the command line' do
    create_file('list.txt', "listed.rb\n")

    expect(cli.run(['--files-from', 'list.txt', '--format', 'files', 'unlisted.rb'])).to eq(1)
    expect(inspected_basenames).to contain_exactly('listed.rb', 'unlisted.rb')
  end

  it 'expands a listed directory' do
    create_file('lib/nested.rb', offending_source)
    create_file('list.txt', "lib\n")

    expect(cli.run(['--files-from', 'list.txt', '--format', 'files'])).to eq(1)
    expect(inspected_basenames).to eq(['nested.rb'])
  end

  it 'inspects nothing when the list is empty' do
    create_empty_file('list.txt')

    expect(cli.run(['--files-from', 'list.txt', '--format', 'simple'])).to eq(0)
    expect($stdout.string).to include('0 files inspected, no offenses detected')
  end

  it 'reports a list it cannot read' do
    expect(cli.run(['--files-from', 'missing.txt'])).to eq(2)
    expect($stderr.string).to include('--files-from could not read missing.txt')
  end

  it 'cannot be combined with --stdin' do
    create_file('list.txt', "listed.rb\n")

    expect(cli.run(['--files-from', 'list.txt', '--stdin', 'example.rb'])).to eq(2)
    expect($stderr.string).to include('--files-from cannot be used with --stdin.')
  end
end
