# frozen_string_literal: true

RSpec.describe RuboCop::TargetRuby, :isolated_environment do
  include FileHelper

  subject(:target_ruby) { described_class.new(configuration) }

  let(:configuration) { RuboCop::Config.new(hash, loaded_path) }
  let(:default_version) { described_class::DEFAULT_VERSION }

  let(:hash) { {} }
  let(:loaded_path) { 'example/.rubocop.yml' }

  context 'when TargetRubyVersion is set' do
    let(:ruby_version) { 2.3 }

    let(:hash) do
      {
        'AllCops' => {
          'TargetRubyVersion' => ruby_version
        }
      }
    end

    it 'uses TargetRubyVersion' do
      expect(target_ruby.version).to eq ruby_version
    end

    it 'does not read .ruby-version' do
      expect(File).not_to receive(:file?).with('.ruby-version')
      target_ruby.version
    end

    it 'does not read Gemfile.lock or gems.locked' do
      expect(File).not_to receive(:file?).with('Gemfile')
      expect(File).not_to receive(:file?).with('gems.locked')
      target_ruby.version
    end
  end

  context 'when TargetRubyVersion is not set' do
    context 'when .ruby-version is present' do
      before do
        dir = configuration.base_dir_for_path_parameters
        create_file(File.join(dir, '.ruby-version'), ruby_version)
      end

      context 'when .ruby-version contains an MRI version' do
        let(:ruby_version) { '2.3.8' }
        let(:ruby_version_to_f) { 2.3 }

        it 'reads it to determine the target ruby version' do
          expect(target_ruby.version).to eq ruby_version_to_f
        end
      end

      context 'when the MRI version contains multiple digits' do
        let(:ruby_version) { '10.11.0' }
        let(:ruby_version_to_f) { 10.11 }

        it 'reads it to determine the target ruby version' do
          expect(target_ruby.version).to eq ruby_version_to_f
        end
      end

      context 'when .ruby-version contains a version prefixed by "ruby-"' do
        let(:ruby_version) { 'ruby-2.3.0' }
        let(:ruby_version_to_f) { 2.3 }

        it 'correctly determines the target ruby version' do
          expect(target_ruby.version).to eq ruby_version_to_f
        end
      end

      context 'when .ruby-version contains a JRuby version' do
        let(:ruby_version) { 'jruby-9.1.2.0' }

        it 'uses the default target ruby version' do
          expect(target_ruby.version).to eq default_version
        end
      end

      context 'when .ruby-version contains a Rbx version' do
        let(:ruby_version) { 'rbx-3.42' }

        it 'uses the default target ruby version' do
          expect(target_ruby.version).to eq default_version
        end
      end

      context 'when .ruby-version contains "system" version' do
        let(:ruby_version) { 'system' }

        it 'uses the default target ruby version' do
          expect(target_ruby.version).to eq default_version
        end
      end

      it 'does not read Gemfile.lock or gems.locked' do
        expect(File).not_to receive(:file?).with('Gemfile')
        expect(File).not_to receive(:file?).with('gems.locked')
        target_ruby.version
      end
    end

    context 'when .ruby-version is not present' do
      ['Gemfile.lock', 'gems.locked'].each do |file_name|
        context "and #{file_name} exists" do
          let(:base_path) { configuration.base_dir_for_path_parameters }
          let(:lock_file_path) { File.join(base_path, file_name) }

          it "uses MRI Ruby version when it is present in #{file_name}" do
            content =
              <<-HEREDOC
                GEM
                  remote: https://rubygems.org/
                  specs:
                    actionmailer (4.1.0)
                    actionpack (= 4.1.0)
                  rails (4.1.0)
                    actionmailer (= 4.1.0)
                    actionpack (= 4.1.0)

                PLATFORMS
                  ruby

                DEPENDENCIES
                  ruby-extensions (~> 1.9.0)

                RUBY VERSION
                    ruby 2.0.0p0

                BUNDLED WITH
                  1.16.1
              HEREDOC
            create_file(lock_file_path, content)
            expect(target_ruby.version).to eq 2.0
          end

          it 'uses MRI Ruby version when it has multiple digits' do
            content =
              <<-HEREDOC
                GEM
                  remote: https://rubygems.org/
                  specs:
                    actionmailer (4.1.0)
                    actionpack (= 4.1.0)
                  rails (4.1.0)
                    actionmailer (= 4.1.0)
                    actionpack (= 4.1.0)

                PLATFORMS
                  ruby

                DEPENDENCIES
                  ruby-extensions (~> 1.9.0)

                RUBY VERSION
                    ruby 20.10.100p450

                BUNDLED WITH
                  1.16.1
              HEREDOC
            create_file(lock_file_path, content)
            expect(target_ruby.version).to eq 20.10
          end

          it "uses the default Ruby when Ruby is not in #{file_name}" do
            content =
              <<-HEREDOC
                GEM
                  remote: https://rubygems.org/
                  specs:
                    addressable (2.5.2)
                      public_suffix (>= 2.0.2, < 4.0)
                    ast (2.4.0)
                    bump (0.5.4)

                PLATFORMS
                  ruby

                DEPENDENCIES
                  bump
                  bundler (~> 1.3)
                  ruby-extensions (~> 1.9.0)

                BUNDLED WITH
                  1.16.1
              HEREDOC
            create_file(lock_file_path, content)
            expect(target_ruby.version).to eq default_version
          end

          it "uses the default Ruby when rbx is in #{file_name}" do
            content =
              <<-HEREDOC
                GEM
                  remote: https://rubygems.org/
                  specs:
                    addressable (2.5.2)
                      public_suffix (>= 2.0.2, < 4.0)
                    ast (2.4.0)
                    bump (0.5.4)

                PLATFORMS
                  ruby

                DEPENDENCIES
                  bump
                  bundler (~> 1.3)
                  ruby-extensions (~> 1.9.0)

                RUBY VERSION
                    ruby 2.0.0p0 (rbx 3.42)

                BUNDLED WITH
                  1.16.1
              HEREDOC
            create_file(lock_file_path, content)
            expect(target_ruby.version).to eq default_version
          end

          it "uses the default Ruby when jruby is in #{file_name}" do
            content =
              <<-HEREDOC
                GEM
                  remote: https://rubygems.org/
                  specs:
                    addressable (2.5.2)
                      public_suffix (>= 2.0.2, < 4.0)
                    ast (2.4.0)
                    bump (0.5.4)

                PLATFORMS
                  ruby

                DEPENDENCIES
                  bump
                  bundler (~> 1.3)
                  ruby-extensions (~> 1.9.0)

                RUBY VERSION
                    ruby 2.0.0p0 (jruby 9.1.13.0)

                BUNDLED WITH
                  1.16.1
              HEREDOC
            create_file(lock_file_path, content)
            expect(target_ruby.version).to eq default_version
          end
        end
      end

      context 'when bundler lock files are not present' do
        it 'uses the default target ruby version' do
          expect(target_ruby.version).to eq default_version
        end
      end
    end

    context 'when .ruby-version is in a parent directory' do
      before do
        dir = configuration.base_dir_for_path_parameters
        create_file(File.join(dir, '..', '.ruby-version'), '2.4.1')
      end

      it 'reads it to determine the target ruby version' do
        expect(target_ruby.version).to eq 2.4
      end
    end

    context 'when .ruby-version is not in a parent directory' do
      ['Gemfile.lock', 'gems.locked'].each do |file_name|
        context "when #{file_name} is in a parent directory" do
          it 'does' do
            content =
              <<-HEREDOC
                GEM
                  remote: https://rubygems.org/
                  specs:
                    actionmailer (4.1.0)
                    actionpack (= 4.1.0)
                  rails (4.1.0)
                    actionmailer (= 4.1.0)
                    actionpack (= 4.1.0)

                PLATFORMS
                  ruby

                DEPENDENCIES
                  ruby-extensions (~> 1.9.0)

                RUBY VERSION
                    ruby 2.0.0p0

                BUNDLED WITH
                  1.16.1
              HEREDOC
            dir = configuration.base_dir_for_path_parameters
            create_file(File.join(dir, '..', file_name), content)
            expect(target_ruby.version).to eq 2.0
          end
        end
      end
    end
  end
end
