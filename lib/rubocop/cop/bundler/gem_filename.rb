# frozen_string_literal: true

module RuboCop
  module Cop
    module Bundler
      # This cop verifies that a project contains Gemfile or gems.rb file and correct
      # associated lock file based on the configuration.
      #
      # @example EnforcedStyle: Gemfile (default)
      #   # bad
      #   Project contains gems.rb and gems.locked files
      #
      #   # bad
      #   Project contains Gemfile and gems.locked file
      #
      #   # good
      #   Project contains Gemfile and Gemfile.lock
      #
      # @example EnforcedStyle: gems.rb
      #   # bad
      #   Project contains Gemfile and Gemfile.lock files
      #
      #   # bad
      #   Project contains gems.rb and Gemfile.lock file
      #
      #   # good
      #   Project contains gems.rb and gems.locked files
      class GemFilename < Base
        include ConfigurableEnforcedStyle
        include RangeHelp

        MSG_GEMFILE_REQUIRED = '`gems.rb` file was found but `Gemfile` is required.'
        MSG_GEMS_RB_REQUIRED = '`Gemfile` was found but `gems.rb` file is required.'
        MSG_GEMFILE_MISMATCHED = 'Expected a `Gemfile.lock` with `Gemfile` but found '\
                                 '`gems.locked` file.'
        MSG_GEMS_RB_MISMATCHED = 'Expected a `gems.locked` file with `gems.rb` but found '\
                                 '`Gemfile.lock`.'
        GEMFILE_FILES = %w[Gemfile Gemfile.lock].freeze
        GEMS_RB_FILES = %w[gems.rb gems.locked].freeze

        def on_new_investigation
          file_path = processed_source.file_path
          return if expected_gemfile?(file_path)

          register_offense(processed_source, file_path)
        end

        private

        def register_offense(processed_source, file_path)
          register_gemfile_offense(processed_source, file_path) if gemfile_required?
          register_gems_rb_offense(processed_source, file_path) if gems_rb_required?
        end

        def register_gemfile_offense(processed_source, file_path)
          message = case file_path
                    when 'gems.rb'
                      MSG_GEMFILE_REQUIRED
                    when 'gems.locked'
                      MSG_GEMFILE_MISMATCHED
                    end

          return if message.nil?

          add_offense(source_range(processed_source.buffer, 1, 0), message: message)
        end

        def register_gems_rb_offense(processed_source, file_path)
          message = case file_path
                    when 'Gemfile'
                      MSG_GEMS_RB_REQUIRED
                    when 'Gemfile.lock'
                      MSG_GEMS_RB_MISMATCHED
                    end

          return if message.nil?

          add_offense(source_range(processed_source.buffer, 1, 0), message: message)
        end

        def expected_gemfile?(file_path)
          (gemfile_required? && GEMFILE_FILES.include?(file_path)) ||
            (gems_rb_required? && GEMS_RB_FILES.include?(file_path))
        end

        def gemfile_required?
          style == :Gemfile
        end

        def gems_rb_required?
          style == :'gems.rb'
        end
      end
    end
  end
end
