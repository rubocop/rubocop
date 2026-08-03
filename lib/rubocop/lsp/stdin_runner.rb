# frozen_string_literal: true

#
# This code is based on https://github.com/standardrb/standard.
#
# Copyright (c) 2023 Test Double, Inc.
#
# The MIT License (MIT)
#
# https://github.com/standardrb/standard/blob/main/LICENSE.txt
#
module RuboCop
  module Lsp
    # Originally lifted from:
    # https://github.com/Shopify/ruby-lsp/blob/8d4c17efce4e8ecc8e7c557ab2981db6b22c0b6d/lib/ruby_lsp/requests/support/rubocop_runner.rb#L20
    # @api private
    class StdinRunner < RuboCop::Runner
      class ConfigurationError < StandardError; end

      attr_reader :offenses, :config_for_working_directory, :processed_source

      DEFAULT_RUBOCOP_OPTIONS = {
        stderr: true,
        force_exclusion: true,
        formatters: ['RuboCop::Formatter::BaseFormatter'],
        raise_cop_error: true,
        todo_file: nil,
        todo_ignore_files: []
      }.freeze

      def initialize(config_store)
        @options = {}

        @offenses = []
        @warnings = []
        @errors = []

        @config_for_working_directory = config_store.for_pwd

        super(@options, config_store)
      end

      def run(path, contents, options, prism_result: nil)
        @options = options.merge(DEFAULT_RUBOCOP_OPTIONS)
        @options[:stdin] = contents

        @prism_result = prism_result
        @processed_source = nil

        @offenses = []
        @warnings = []
        @errors = []

        super([path])

        raise Interrupt if aborting?
      end

      def formatted_source
        @options[:stdin]
      end

      # Drop the cached project index so the next run rebuilds it. Called when a
      # file is saved or a watched file changes, i.e. when the on-disk state the
      # index is derived from may have changed.
      def reset_project_index
        @project_index = nil
        @project_index_built = false
      end

      private

      # The project index is built from files on disk, not from the in-memory
      # buffer, so it does not change while the user is typing. Build it once and
      # reuse it across runs instead of re-walking and re-indexing the whole
      # project on every request; `reset_project_index` drops the cache when the
      # on-disk state changes.
      def build_project_index(target_files)
        return if @project_index_built

        super
        @project_index_built = true
      end

      def file_finished(_file, offenses)
        @offenses = offenses
      end

      def do_inspection_loop(file)
        source, offenses = super
        @processed_source = source
        [source, offenses]
      end
    end
  end
end
