# frozen_string_literal: true

RSpec.describe 'RuboCop::CLI --changed', :isolated_environment do # rubocop:disable RSpec/DescribeClass
  subject(:cli) { RuboCop::CLI.new }

  include_context 'cli spec behavior'

  def git(*args)
    _stdout, stderr, status = Open3.capture3('git', *args)

    raise "git #{args.join(' ')} failed: #{stderr}" unless status.success?
  end

  def commit_all(message)
    git('add', '-A')
    git('-c', 'user.email=test@example.com', '-c', 'user.name=Test', 'commit', '-m', message)
  end

  let(:offending_source) { "# frozen_string_literal: true\n\nputs \"offense\"\n" }

  before do
    git('init')
    create_file('.rubocop.yml', <<~YAML)
      AllCops:
        NewCops: disable
        SuggestExtensions: false
    YAML
    create_file('untouched.rb', offending_source)
    commit_all('init')
  end

  it 'inspects only the files that differ from HEAD' do
    create_file('modified.rb', offending_source)

    expect(cli.run(['--changed', '--format', 'files'])).to eq(1)
    expect($stdout.string.split("\n").map { |path| File.basename(path) }).to eq(['modified.rb'])
  end

  it 'inspects nothing when the working tree is clean' do
    expect(cli.run(['--changed', '--format', 'simple'])).to eq(0)
    expect($stdout.string).to include('no offenses detected')
  end

  it 'accepts a revision to compare against' do
    create_file('modified.rb', offending_source)
    commit_all('second')

    expect(cli.run(['--changed=HEAD~1', '--format', 'files'])).to eq(1)
    expect($stdout.string.split("\n").map { |path| File.basename(path) }).to eq(['modified.rb'])
  end

  it 'narrows the given paths rather than replacing them' do
    create_file('lib/modified.rb', offending_source)
    create_file('spec/modified_spec.rb', offending_source)

    expect(cli.run(['--changed', '--format', 'files', 'lib'])).to eq(1)
    expect($stdout.string.split("\n").map { |path| File.basename(path) }).to eq(['modified.rb'])
  end

  it 'explains what to do when given a path instead of a revision' do
    create_file('lib/modified.rb', offending_source)

    expect(cli.run(['--changed', 'lib'])).to eq(2)
    expect($stderr.string).to include('--changed takes a git revision, but `lib` is a path.')
  end

  it 'cannot be combined with --stdin' do
    expect(cli.run(['--changed', '--stdin', 'example.rb'])).to eq(2)
    expect($stderr.string).to include('--changed cannot be used with --stdin.')
  end

  it 'reports git failures' do
    expect(cli.run(['--changed=no-such-revision'])).to eq(2)
    expect($stderr.string).to include('--changed could not ask git which files changed')
  end
end
