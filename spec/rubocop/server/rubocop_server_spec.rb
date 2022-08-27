# frozen_string_literal: true

RSpec.describe 'rubocop --server', :isolated_environment do # rubocop:disable RSpec/DescribeClass
  let(:rubocop) { "#{RuboCop::ConfigLoader::RUBOCOP_HOME}/exe/rubocop" }

  include_context 'cli spec behavior'

  if RuboCop::Server.support_server?
    context 'when using `--server` option after updating RuboCop' do
      before do
        options = '--server --only Style/FrozenStringLiteralComment,Style/StringLiterals'
        `ruby -I . "#{rubocop}" #{options}`

        # Emulating RuboCop updates. `0.99.9` is a version value for testing that
        # will never be used in the real world RuboCop version.
        RuboCop::Server::Cache.write_version_file('0.99.9')
      end

      after do
        `ruby -I . "#{rubocop}" --stop-server`
      end

      it 'displays a restart information message' do
        # FIXME: Avoid flaky test for RSpec 4. It may be related that test-queue is not available.
        # https://github.com/rubocop/rubocop/pull/10806#discussion_r918415067
        skip if ENV['GITHUB_JOB'] == 'rspec4'

        create_file('example.rb', <<~RUBY)
          # frozen_string_literal: true

          x = 0
          puts x
        RUBY
        options = '--server --only Style/FrozenStringLiteralComment,Style/StringLiterals'
        expect(`ruby -I . "#{rubocop}" #{options}`).to start_with(
          'RuboCop version incompatibility found, RuboCop server restarting...'
        )
      end
    end
  end
end
