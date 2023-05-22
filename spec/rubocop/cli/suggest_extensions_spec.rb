# frozen_string_literal: true

require 'timeout'

RSpec.describe 'RuboCop::CLI SuggestExtensions', :isolated_environment do # rubocop:disable RSpec/DescribeClass
  subject(:cli) { RuboCop::CLI.new }

  include_context 'cli spec behavior'

  describe 'extension suggestions', :config do
    matcher :suggest_extensions do
      supports_block_expectations
      attr_accessor :install_suggested, :load_suggested

      def extensions_to_install_suggest
        @extensions_to_install_suggest ||= []
      end

      def extensions_to_load_suggest
        @extensions_to_load_suggest ||= []
      end

      def install_suggestion_regex
        Regexp.new(<<~REGEXP, Regexp::MULTILINE).freeze
          Tip: Based on detected gems, the following RuboCop extension libraries might be helpful:
          (?<suggestions>.*?)
          ^$
        REGEXP
      end

      def load_suggestion_regex
        Regexp.new(<<~REGEXP, Regexp::MULTILINE).freeze
          The following RuboCop extension libraries are installed but not loaded in config:
          (?<suggestions>.*?)
          ^$
        REGEXP
      end

      def find_suggestions
        actual.call
        suggestions = (install_suggestion_regex.match($stdout.string) || {})[:suggestions]
        self.install_suggested = suggestions ? suggestions.scan(/(?<=\* )[a-z0-9_-]+\b/.freeze) : []

        suggestions = (load_suggestion_regex.match($stdout.string) || {})[:suggestions]
        self.load_suggested = suggestions ? suggestions.scan(/(?<=\* )[a-z0-9_-]+\b/.freeze) : []
      end

      chain :to_install do |*extensions|
        @extensions_to_install_suggest = extensions
      end

      chain :to_load do |*extensions|
        @extensions_to_load_suggest = extensions
      end

      match do
        find_suggestions
        install_suggested == extensions_to_install_suggest &&
          load_suggested == extensions_to_load_suggest
      end

      match_when_negated do
        find_suggestions
        install_suggested.none? && load_suggested.none?
      end

      failure_message do
        'expected to suggest extensions to install ' \
          "[#{extensions_to_install_suggest.join(', ')}], " \
          "load [#{extensions_to_load_suggest.join(', ')}], " \
          "but got [#{install_suggested.join(', ')}], [#{load_suggested.join(', ')}]"
      end

      failure_message_when_negated do
        'expected to not suggest extensions, ' \
          "but got [#{install_suggested.join(', ')}] as install suggestion, " \
          "[#{load_suggested.join(', ')}] as load suggestion"
      end
    end

    let(:loaded_features) { %w[] }

    let(:lockfile) do
      create_file('Gemfile.lock', <<~LOCKFILE)
        GEM
          specs:
            rake (13.0.1)
            rspec (3.9.0)

        PLATFORMS
          ruby

        DEPENDENCIES
          rake (~> 13.0)
          rspec (~> 3.7)
      LOCKFILE
    end

    before do
      create_file('example.rb', <<~RUBY)
        # frozen_string_literal: true

        puts 'ok'
      RUBY

      # Ensure that these specs works in CI, since the feature is generally
      # disabled in when ENV['CI'] is set.
      allow(ENV).to receive(:fetch).and_call_original
      allow(ENV).to receive(:fetch).with('CI', nil).and_return(false)

      # Mock the lockfile to be parsed by bundler
      allow(Bundler).to receive(:default_lockfile)
        .and_return(lockfile ? Pathname.new(lockfile) : nil)

      allow_any_instance_of(RuboCop::Config).to receive(:loaded_features)
        .and_return(loaded_features)
    end

    context 'when bundler is not loaded' do
      before do
        hide_const('Bundler')
      end

      it 'does not show the suggestion' do
        expect { cli.run(['example.rb']) }.not_to suggest_extensions
        expect($stderr.string.blank?).to be(true)
      end
    end

    context 'when there are gems to suggest' do
      context 'that are not installed' do
        it 'shows the suggestion' do
          expect do
            cli.run(['example.rb'])
          end.to suggest_extensions.to_install('rubocop-rake', 'rubocop-rspec')
        end
      end

      context 'that are dependencies' do
        before do
          create_file('Gemfile.lock', <<~TEXT)
            GEM
              remote: https://rubygems.org/
              specs:
                rake (13.0.1)
                rspec (3.9.0)
                  rspec-core (~> 3.9.0)
                rspec-core (3.9.3)
                rubocop-rake (0.5.1)
                rubocop-rspec (2.0.1)

            DEPENDENCIES
              rake (~> 13.0)
              rspec (~> 3.7)
              rubocop-rake (~> 0.5)
              rubocop-rspec (~> 2.0.0)
          TEXT
        end

        it 'does not show the load suggestion' do
          expect do
            cli.run(['example.rb'])
          end.to suggest_extensions.to_load('rubocop-rake', 'rubocop-rspec')
        end
      end

      context 'that some are dependencies' do
        before do
          create_file('Gemfile.lock', <<~TEXT)
            GEM
              remote: https://rubygems.org/
              specs:
                rake (13.0.1)
                rspec (3.9.0)
                  rspec-core (~> 3.9.0)
                rspec-core (3.9.3)
                rubocop-rake (0.5.1)

            DEPENDENCIES
              rake (~> 13.0)
              rspec (~> 3.7)
              rubocop-rake (~> 0.5)
          TEXT
        end

        it 'only suggests unused gems' do
          expect do
            cli.run(['example.rb'])
          end.to suggest_extensions.to_install('rubocop-rspec').to_load('rubocop-rake')
        end
      end

      context 'that are added by dependencies' do
        let(:lockfile) do
          create_file('Gemfile.lock', <<~TEXT)
            GEM
              specs:
                rake (13.0.1)
                rspec (3.9.0)
                shared-gem (1.0.0)
                  rubocop-rake (0.5.1)
                  rubocop-rspec (2.0.1)

            DEPENDENCIES
              rake (~> 13.0)
              rspec (~> 3.7)
              shared-gem (~> 1.0.0)
          TEXT
        end

        it 'does not show the suggestion' do
          expect do
            cli.run(['example.rb'])
          end.to suggest_extensions.to_load('rubocop-rake', 'rubocop-rspec')
        end
      end

      context 'that are dependencies and required in config' do
        let(:lockfile) do
          create_file('Gemfile.lock', <<~TEXT)
            GEM
              remote: https://rubygems.org/
              specs:
                rake (13.0.1)
                rspec (3.9.0)
                  rspec-core (~> 3.9.0)
                rspec-core (3.9.3)
                rubocop-rake (0.5.1)
                rubocop-rspec (2.0.1)

            DEPENDENCIES
              rake (~> 13.0)
              rspec (~> 3.7)
              rubocop-rake (~> 0.5)
              rubocop-rspec (~> 2.0.0)
          TEXT
        end

        let(:loaded_features) { %w[rubocop-rspec rubocop-rake] }

        it 'does not show the suggestion' do
          expect { cli.run(['example.rb']) }.not_to suggest_extensions
        end
      end
    end

    context 'when gems with suggestions are not primary dependencies' do
      let(:lockfile) do
        create_file('Gemfile.lock', <<~LOCKFILE)
          GEM
            specs:
              shared-gem (1.0.0)
                rake (13.0.1)
                rspec (3.9.0)

          PLATFORMS
            ruby

          DEPENDENCIES
            shared-gem (~> 1.0)
        LOCKFILE
      end

      it 'does not show the suggestion' do
        expect { cli.run(['example.rb']) }.not_to suggest_extensions
      end
    end

    context 'when there are multiple gems loaded that have the same suggestion' do
      let(:lockfile) do
        create_file('Gemfile.lock', <<~LOCKFILE)
          GEM
            specs:
              rspec (3.9.0)
              rspec-rails (4.0.1)

          PLATFORMS
            ruby

          DEPENDENCIES
            rspec (~> 3.9)
            rspec-rails (~> 4.0)
        LOCKFILE
      end

      it 'shows the suggestion' do
        expect { cli.run(['example.rb']) }.to suggest_extensions.to_install('rubocop-rspec')
      end
    end

    context 'with AllCops/SuggestExtensions: false' do
      before do
        create_file('.rubocop.yml', <<~YAML)
          AllCops:
            SuggestExtensions: false
        YAML
      end

      it 'does not show the suggestion' do
        expect { cli.run(['example.rb']) }.not_to suggest_extensions
      end
    end

    context 'with AllCops/SuggestExtensions: true' do
      before do
        create_file('.rubocop.yml', <<~YAML)
          AllCops:
            SuggestExtensions: true
        YAML
      end

      let(:lockfile) do
        create_file('Gemfile.lock', <<~LOCKFILE)
          GEM
            specs:
              rspec (3.9.0)
              rspec-rails (4.0.1)

          PLATFORMS
            ruby

          DEPENDENCIES
            rspec (~> 3.9)
            rspec-rails (~> 4.0)
        LOCKFILE
      end

      it 'shows the suggestion' do
        expect { cli.run(['example.rb']) }.to suggest_extensions.to_install('rubocop-rspec')
      end
    end

    context 'when an extension is disabled in AllCops/SuggestExtensions' do
      before do
        create_file('.rubocop.yml', <<~YAML)
          AllCops:
            SuggestExtensions:
              rubocop-rake: false
        YAML
      end

      it 'show the suggestion for non-disabled extensions' do
        expect { cli.run(['example.rb']) }.to suggest_extensions.to_install('rubocop-rspec')
      end
    end

    context 'when in CI mode' do
      before { allow(ENV).to receive(:fetch).with('CI', nil).and_return(true) }

      it 'does not show the suggestion' do
        expect { cli.run(['example.rb']) }.not_to suggest_extensions
      end
    end

    context 'when given --only' do
      it 'does not show the suggestion' do
        expect { cli.run(['example.rb', '--only', 'Style/Alias']) }.not_to suggest_extensions
      end
    end

    context 'when given --debug' do
      it 'does not show the suggestion' do
        expect { cli.run(['example.rb', '--debug']) }.not_to suggest_extensions
      end
    end

    context 'when given --list-target-files' do
      it 'does not show the suggestion' do
        expect { cli.run(['example.rb', '--list-target-files']) }.not_to suggest_extensions
      end
    end

    context 'when given --out' do
      it 'does not show the suggestion' do
        expect { cli.run(['example.rb', '--out', 'output.txt']) }.not_to suggest_extensions
      end
    end

    context 'when given --stdin' do
      it 'does not show the suggestion' do
        $stdin = StringIO.new('p $/')
        expect { cli.run(['--stdin', 'example.rb']) }.not_to suggest_extensions
      ensure
        $stdin = STDIN
      end
    end

    context 'when given a non-supported formatter' do
      it 'does not show the suggestion' do
        expect { cli.run(['example.rb', '--format', 'simple']) }.not_to suggest_extensions
      end
    end

    context 'when given an invalid path' do
      it 'does not show the suggestion' do
        expect { cli.run(['example1.rb']) }.not_to suggest_extensions
      end
    end
  end
end
