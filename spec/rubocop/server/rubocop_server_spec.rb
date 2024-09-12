# frozen_string_literal: true

require 'open3'

RSpec.describe 'rubocop --server', :isolated_environment do # rubocop:disable RSpec/DescribeClass
  let(:rubocop) { "#{RuboCop::ConfigLoader::RUBOCOP_HOME}/exe/rubocop" }

  include_context 'cli spec behavior'

  before do
    # Makes sure the project dir of rubocop server is the isolated_environment
    create_empty_file('Gemfile')
  end

  after do
    `ruby -I . "#{rubocop}" --stop-server`
  end

  if RuboCop::Server.support_server?
    context 'when using `--server` option after updating RuboCop' do
      it 'displays a restart information message' do
        create_file('example.rb', <<~RUBY)
          # frozen_string_literal: true

          x = 0
          puts x
        RUBY

        create_file('Gemfile', <<~RUBY)
          # frozen_string_literal: true
        RUBY

        options = '--server --only Style/FrozenStringLiteralComment,Style/StringLiterals'
        expect(`ruby -I . "#{rubocop}" #{options}`).to start_with('RuboCop server starting on')
        # Emulating the SHA1 value of Gemfile.lock and .rubocop.yml.
        RuboCop::Server::Cache.write_version_file('615dfedabfe01face6557b935510309ae550f74f')

        expect(`ruby -I . "#{rubocop}" --server-status`).to match(/RuboCop server .* is running/)
        _stdout, stderr, _status = Open3.capture3("ruby -I . \"#{rubocop}\" #{options}")
        expect(stderr).to start_with(
          'RuboCop version incompatibility found, RuboCop server restarting...'
        )
      end
    end

    context 'when using `--server` with `--stderr`' do
      it 'sends corrected source to stdout and rest to stderr' do
        create_file('example.rb', <<~RUBY)
          puts 0
        RUBY

        stdout, stderr, status = Open3.capture3(
          'ruby', '-I', '.',
          rubocop, '--no-color', '--server', '--stderr', '-A',
          '--stdin', 'example.rb',
          stdin_data: 'puts 0'
        )
        expect(status).to be_success
        expect(stdout).to eq(<<~RUBY)
          # frozen_string_literal: true

          puts 0
        RUBY
        expect(stderr)
          .to include('[Corrected] Style/FrozenStringLiteralComment')
          .and include('[Corrected] Layout/EmptyLineAfterMagicComment')
      end
    end

    context 'when using `--server` and json is specified as the format' do
      context 'when `--format=json`' do
        it 'does not display the server start message' do
          create_file('example.rb', <<~RUBY)
            puts 0
          RUBY

          stdout, _stderr, _status = Open3.capture3(
            'ruby', '-I', '.',
            rubocop, '--server', '--format=json', '--stdin', 'example.rb', stdin_data: 'puts 0'
          )
          expect(stdout).not_to start_with 'RuboCop server starting on '
        end
      end

      context 'when `--format=j`' do
        it 'does not display the server start message' do
          create_file('example.rb', <<~RUBY)
            puts 0
          RUBY

          stdout, _stderr, _status = Open3.capture3(
            'ruby', '-I', '.',
            rubocop, '--server', '--format=j', '--stdin', 'example.rb', stdin_data: 'puts 0'
          )
          expect(stdout).not_to start_with 'RuboCop server starting on '
        end
      end

      context 'when `--format json`' do
        it 'does not display the server start message' do
          create_file('example.rb', <<~RUBY)
            puts 0
          RUBY

          stdout, _stderr, _status = Open3.capture3(
            'ruby', '-I', '.',
            rubocop, '--server', '--format', 'json', '--stdin', 'example.rb', stdin_data: 'puts 0'
          )
          expect(stdout).not_to start_with 'RuboCop server starting on '
        end
      end

      context 'when `--format j`' do
        it 'does not display the server start message' do
          create_file('example.rb', <<~RUBY)
            puts 0
          RUBY

          stdout, _stderr, _status = Open3.capture3(
            'ruby', '-I', '.',
            rubocop, '--server', '--format', 'j', '--stdin', 'example.rb', stdin_data: 'puts 0'
          )
          expect(stdout).not_to start_with 'RuboCop server starting on '
        end
      end

      context 'when `-f json`' do
        it 'does not display the server start message' do
          create_file('example.rb', <<~RUBY)
            puts 0
          RUBY

          stdout, _stderr, _status = Open3.capture3(
            'ruby', '-I', '.',
            rubocop, '--server', '-f', 'json', '--stdin', 'example.rb', stdin_data: 'puts 0'
          )
          expect(stdout).not_to start_with 'RuboCop server starting on '
        end
      end

      context 'when `-f j`' do
        it 'does not display the server start message' do
          create_file('example.rb', <<~RUBY)
            puts 0
          RUBY

          stdout, _stderr, _status = Open3.capture3(
            'ruby', '-I', '.',
            rubocop, '--server', '-f', 'j', '--stdin', 'example.rb', stdin_data: 'puts 0'
          )
          expect(stdout).not_to start_with 'RuboCop server starting on '
        end
      end
    end

    context 'when using `--server` option after running server and updating configuration' do
      it 'applies .rubocop.yml configuration changes even during server startup' do
        create_file('example.rb', <<~RUBY)
          x = 0
          puts x
        RUBY

        create_file('Gemfile', <<~RUBY)
          # frozen_string_literal: true
        RUBY

        # Disable `Style/FrozenStringLiteralComment` cop.
        create_file('.rubocop.yml', <<~RUBY)
          AllCops:
            NewCops: enable
            SuggestExtensions: false
          Style/FrozenStringLiteralComment:
            Enabled: false
        RUBY

        message = expect(`ruby -I . "#{rubocop}" --server`)
        message.to start_with('RuboCop server starting on ')
        message.to include('no offenses')

        RuboCop::Server.wait_for_running_status!(true)

        debug_output = [
          'After server start',
          RuboCop::Server.running?,
          `ruby -I . "#{rubocop}" --server-status`,
          `tail  #{RuboCop::Server::Cache.dir}/*`,
          `ps aux`,
          `env | grep HOME`,
          Dir.home,
          `ruby -I . -e 'require "rubocop/server"; puts RuboCop::Server::Cache.dir'`
        ]

        expect(`ruby -I . "#{rubocop}" --server-status`).to(
          match(/RuboCop server .* is running/), debug_output.join("\n")
        )

        # Enable `Style/FrozenStringLiteralComment` cop.
        create_file('.rubocop.yml', <<~RUBY)
          AllCops:
            NewCops: enable
            SuggestExtensions: false
          Style/FrozenStringLiteralComment:
            Enabled: true
        RUBY

        debug_output += [
          'After create file',
          RuboCop::Server.running?,
          `ruby -I . "#{rubocop}" --server-status`,
          `tail  #{RuboCop::Server::Cache.dir}/*`,
          `ps aux`,
          `env | grep HOME`,
          Dir.home,
          `ruby -I . -e 'require "rubocop/server"; puts RuboCop::Server::Cache.dir'`
        ]

        expect(`ruby -I . "#{rubocop}" --server-status`).to(
          match(/RuboCop server .* is running/), debug_output.join("\n")
        )

        # Emulating the SHA1 value of Gemfile.lock and .rubocop.yml.
        RuboCop::Server::Cache.write_version_file('f63c8f29b26472dae07bfa80c13a6f658361893d')

        message = expect(`ruby -I . "#{rubocop}" --server`)
        message.not_to start_with('RuboCop server starting on '), debug_output.join("\n")
        message.to include(<<~OFFENSE_DETECTED)
          Style/FrozenStringLiteralComment: Missing frozen string literal comment.
        OFFENSE_DETECTED
      end
    end
  end
end
