# frozen_string_literal: true

RSpec.describe RuboCop::Server::CLI, :isolated_environment do
  subject(:cli) { described_class.new }

  include_context 'cli spec behavior'

  if RuboCop::Server.support_server?
    before do
      allow_any_instance_of(RuboCop::Server::Core).to receive(:server_mode?).and_return(false) # rubocop:disable RSpec/AnyInstance
    end

    after do
      RuboCop::Server::ClientCommand::Stop.new.run
    end

    context 'when using `--server` option' do
      it 'returns exit status 0 and display an information message' do
        create_file('example.rb', <<~RUBY)
          # frozen_string_literal: true

          x = 0
          puts x
        RUBY
        expect(cli.run(['--server', '--format', 'simple', 'example.rb'])).to eq(0)
        expect(cli.exit?).to be(false)
        expect($stdout.string).to start_with 'RuboCop server starting on '
        expect($stderr.string).to eq ''
      end
    end

    context 'when using `--no-server` option' do
      it 'returns exit status 0' do
        create_file('example.rb', <<~RUBY)
          # frozen_string_literal: true

          x = 0
          puts x
        RUBY
        expect(cli.run(['--no-server', '--format', 'simple', 'example.rb'])).to eq(0)
        expect(cli.exit?).to be(false)
        expect($stdout.string).to eq ''
        expect($stderr.string).to eq ''
      end
    end

    context 'when using `--start-server` option' do
      it 'returns exit status 0 and display an information message' do
        expect(cli.run(['--start-server'])).to eq(0)
        expect(cli.exit?).to be(true)
        expect($stdout.string).to start_with 'RuboCop server starting on '
        expect($stderr.string).to eq ''
      end
    end

    context 'when using `--start-server` option with `--no-detach`' do
      it 'returns exit status 0 and display an information message' do
        expect(cli.run(['--start-server', '--no-detach'])).to eq(0)
        expect(cli.exit?).to be(true)
        expect($stdout.string).to match(/RuboCop server starting on/)
        expect($stderr.string).to eq ''
      end
    end

    context 'when using `--stop-server` option' do
      it 'returns exit status 0 and display a warning message' do
        expect(cli.run(['--stop-server'])).to eq(0)
        expect(cli.exit?).to be(true)
        expect($stdout.string).to eq ''
        expect($stderr.string).to eq "RuboCop server is not running.\n"
      end
    end

    context 'when using `--restart-server` option' do
      it 'returns exit status 0 and display an information and a warning messages' do
        expect(cli.run(['--restart-server'])).to eq(0)
        expect(cli.exit?).to be(true)
        expect($stdout.string).to start_with 'RuboCop server starting on '
        expect($stderr.string).to eq "RuboCop server is not running.\n"
      end
    end

    context 'when using `--restart-server` option with `--no-detach`' do
      it 'returns exit status 0 and display an information message' do
        expect(cli.run(['--restart-server', '--no-detach'])).to eq(0)
        expect(cli.exit?).to be(true)
        expect($stdout.string).to match(/RuboCop server starting on/)
        expect($stderr.string).to eq "RuboCop server is not running.\n"
      end
    end

    context 'when using `--server-status` option' do
      it 'returns exit status 0 and display an information message' do
        expect(cli.run(['--server-status'])).to eq(0)
        expect(cli.exit?).to be(true)
        expect($stdout.string).to eq "RuboCop server is not running.\n"
        expect($stderr.string).to eq ''
      end
    end

    context 'when not using any server options' do
      it 'returns exit status 0' do
        create_file('example.rb', <<~RUBY)
          # frozen_string_literal: true

          x = 0
          puts x
        RUBY
        expect(cli.run(['--format', 'simple', 'example.rb'])).to eq(0)
        expect(cli.exit?).to be(false)
        expect($stdout.string.blank?).to be(true)
        expect($stderr.string.blank?).to be(true)
      end
    end

    context 'when not using any server options and specifying `--server` in .rubocop file' do
      before { create_file('.rubocop', '--server') }

      it 'returns exit status 0 and display an information message' do
        create_file('example.rb', <<~RUBY)
          # frozen_string_literal: true

          x = 0
          puts x
        RUBY
        expect(cli.run(['--format', 'simple', 'example.rb'])).to eq(0)
        expect(cli.exit?).to be(false)
        expect($stdout.string).to start_with 'RuboCop server starting on '
        expect($stderr.string).to eq ''
      end
    end

    context 'when not using any server options and specifying `--server` in `RUBOCOP_OPTS` environment variable' do
      around do |example|
        ENV['RUBOCOP_OPTS'] = '--server'
        begin
          example.run
        ensure
          ENV.delete('RUBOCOP_OPTS')
        end
      end

      it 'returns exit status 0 and display an information message' do
        create_file('example.rb', <<~RUBY)
          # frozen_string_literal: true

          x = 0
          puts x
        RUBY
        expect(cli.run(['--format', 'simple', 'example.rb'])).to eq(0)
        expect(cli.exit?).to be(false)
        expect($stdout.string).to start_with 'RuboCop server starting on '
        expect($stderr.string).to eq ''
      end
    end

    context 'when using multiple server options' do
      it 'returns exit status 2 and display an error message' do
        create_file('example.rb', <<~RUBY)
          # frozen_string_literal: true

          x = 0
          puts x
        RUBY
        expect(cli.run(['--server', '--no-server', '--format', 'simple', 'example.rb'])).to eq(2)
        expect(cli.exit?).to be(true)
        expect($stdout.string).to eq ''
        expect($stderr.string).to eq "--server, --no-server cannot be specified together.\n"
      end
    end

    context 'when using exclusive `--restart-server` option' do
      it 'returns exit status 2 and display an error message' do
        expect(cli.run(['--restart-server', '--format', 'simple'])).to eq(2)
        expect(cli.exit?).to be(true)
        expect($stdout.string).to eq ''
        expect($stderr.string).to eq "--restart-server cannot be combined with --format.\n"
      end
    end

    context 'when using exclusive `--start-server` option' do
      it 'returns exit status 2 and display an error message' do
        expect(cli.run(['--start-server', '--format', 'simple'])).to eq(2)
        expect(cli.exit?).to be(true)
        expect($stdout.string).to eq ''
        expect($stderr.string).to eq "--start-server cannot be combined with --format.\n"
      end
    end

    context 'when using exclusive `--stop-server` option' do
      it 'returns exit status 2 and display an error message' do
        expect(cli.run(['--stop-server', '--format', 'simple'])).to eq(2)
        expect(cli.exit?).to be(true)
        expect($stdout.string).to eq ''
        expect($stderr.string).to eq "--stop-server cannot be combined with --format.\n"
      end
    end

    context 'when using exclusive `--server-status` option' do
      it 'returns exit status 2 and display an error message' do
        expect(cli.run(['--server-status', '--format', 'simple'])).to eq(2)
        expect(cli.exit?).to be(true)
        expect($stdout.string).to eq ''
        expect($stderr.string).to eq "--server-status cannot be combined with --format.\n"
      end
    end

    context 'when using server option with `--no-detach` option' do
      it 'returns exit status 2 and display an error message' do
        expect(cli.run(['--server-status', '--no-detach'])).to eq(2)
        expect(cli.exit?).to be(true)
        expect($stdout.string).to eq ''
        expect($stderr.string).to eq "--server-status cannot be combined with --no-detach.\n"
      end
    end

    context 'when using server option with `--cache-root path` option' do
      it 'returns exit status 0 and display an error message' do
        expect(cli.run(['--server-status', '--cache-root', '/tmp'])).to eq(0)
        expect(cli.exit?).to be(true)
        expect($stdout.string).to eq "RuboCop server is not running.\n"
        expect($stderr.string).not_to eq "--server-status cannot be combined with other options.\n"
      end
    end

    context 'when using server option with `--cache-root=path` option' do
      it 'returns exit status 0 and display an information message' do
        expect(cli.run(['--server-status', '--cache-root=/tmp'])).to eq(0)
        expect(cli.exit?).to be(true)
        expect($stdout.string).to eq "RuboCop server is not running.\n"
        expect($stderr.string).not_to eq "--server-status cannot be combined with other options.\n"
      end
    end
  else
    context 'when using `--server` option' do
      it 'returns exit status 2 and display an error message' do
        expect(cli.run(['--server', '--format', 'simple'])).to eq(2)
        expect(cli.exit?).to be(true)
        expect($stdout.string).to eq ''
        expect($stderr.string).to eq "RuboCop server is not supported by this Ruby.\n"
      end
    end
  end
end
