# frozen_string_literal: true

RSpec.describe 'RuboCop::CLI --diff', :isolated_environment do # rubocop:disable RSpec/DescribeClass
  subject(:cli) { RuboCop::CLI.new }

  include_context 'cli spec behavior'

  let(:source) { <<~RUBY }
    # frozen_string_literal: true

    x = "foo"
    puts x
  RUBY

  before { create_file('example.rb', source) }

  # The diff carries the file's own line endings, which are CRLF on Windows.
  def output
    $stdout.string.gsub("\r\n", "\n")
  end

  it 'prints what autocorrection would change without writing the file' do
    expect(cli.run(['--diff', '--format', 'quiet', 'example.rb'])).to eq(1)
    expect(File.read('example.rb')).to eq(source)
    expect(output).to include(<<~DIFF)
      --- a/example.rb
      +++ b/example.rb
      @@ -1,4 +1,4 @@
       # frozen_string_literal: true
      #{' '}
      -x = "foo"
      +x = 'foo'
       puts x
    DIFF
  end

  it 'reports offenses that only unsafe autocorrection would fix when given -A' do
    create_file('example.rb', <<~RUBY)
      # frozen_string_literal: true

      x = 1
      puts x.to_s
    RUBY

    expect(cli.run(['--diff', '-A', '--format', 'quiet', 'example.rb'])).to eq(1)
    expect(output).to include('-puts x.to_s')
    expect(output).to include('+puts x')
  end

  it 'leaves offenses that cannot be autocorrected out of the diff' do
    create_file('example.rb', <<~RUBY)
      # frozen_string_literal: true

      def foo(a, b, c, d, e, f)
        [a, b, c, d, e, f]
      end
    RUBY

    expect(cli.run(['--diff', '--format', 'quiet', '--only', 'Metrics/ParameterLists',
                    'example.rb'])).to eq(1)
    expect(output).not_to include('--- a/example.rb')
  end

  it 'succeeds when there is nothing to correct' do
    create_file('example.rb', <<~RUBY)
      # frozen_string_literal: true

      x = 'foo'
      puts x
    RUBY

    expect(cli.run(['--diff', '--format', 'quiet', 'example.rb'])).to eq(0)
    expect(output).not_to include('--- a/example.rb')
  end

  it 'restricts the diff to layout changes when combined with -x' do
    create_file('example.rb', <<~RUBY)
      # frozen_string_literal: true

      x = "foo"
      puts x  if x
    RUBY

    expect(cli.run(['--diff', '-x', '--format', 'quiet', 'example.rb'])).to eq(1)
    expect(output).to include('-puts x  if x')
    expect(output).to include('+puts x if x')
    expect(output).not_to include("+x = 'foo'")
  end

  it 'diffs the source read from stdin' do
    $stdin = StringIO.new(source)

    expect(cli.run(['--diff', '--format', 'quiet', '--stdin', 'example.rb'])).to eq(1)
    expect(output).to include('-x = "foo"')
    expect(output).to include("+x = 'foo'")
  ensure
    $stdin = STDIN
  end

  it 'fails whatever the fail level says, since a patch means work is left' do
    expect(cli.run(['--diff', '--fail-level', 'error', '--format', 'quiet', 'example.rb'])).to eq(1)
    expect(output).to include('--- a/example.rb')
  end

  it 'refuses to run with --auto-gen-config, which exists to write a file' do
    expect(cli.run(['--diff', '--auto-gen-config', 'example.rb'])).to eq(2)
    expect($stderr.string).to include('--diff cannot be used with --auto-gen-config.')
    expect(Pathname.new('.rubocop_todo.yml')).not_to exist
  end

  it 'omits the diff when a machine-readable format was requested' do
    expect(cli.run(['--diff', '--format', 'json', 'example.rb'])).to eq(1)
    expect(output).not_to include('--- a/example.rb')
    expect { JSON.parse($stdout.string) }.not_to raise_error
  end
end
