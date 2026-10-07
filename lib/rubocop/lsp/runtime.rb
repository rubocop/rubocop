# frozen_string_literal: true

require_relative 'diagnostic'
require_relative 'stdin_runner'

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
  module LSP
    # Runtime for Language Server Protocol of RuboCop.
    # @api private
    class Runtime
      attr_writer :safe_autocorrect, :lint_mode, :layout_mode, :raise_cop_error

      def initialize(config_store)
        RuboCop::LSP.enable

        @runner = RuboCop::Lsp::StdinRunner.new(config_store)

        @safe_autocorrect = true
        @lint_mode = false
        @layout_mode = false
        @raise_cop_error = true
      end

      def format(path, text, command:, prism_result: nil, cops: nil)
        safe_autocorrect = if command
                             command == 'rubocop.formatAutocorrects'
                           else
                             @safe_autocorrect
                           end

        formatting_options = {
          autocorrect: true, safe_autocorrect: safe_autocorrect, raise_cop_error: @raise_cop_error
        }.merge(cop_options(cops))

        @runner.run(path, text, formatting_options, prism_result: prism_result)
        @runner.formatted_source
      end

      def reset_project_index
        @runner.reset_project_index
      end

      def offenses(path, text, document_encoding = nil, prism_result: nil)
        found = raw_offenses(path, text, prism_result: prism_result)
        processed_source = @runner.processed_source
        config = @runner.config_for_working_directory
        found.map do |offense|
          build_diagnostic(offense, path, document_encoding, processed_source, config)
        end
      end

      # The offenses before they are converted to LSP diagnostics, for callers
      # that do not speak LSP.
      def raw_offenses(path, text, prism_result: nil, cops: nil)
        diagnostic_options = { raise_cop_error: @raise_cop_error }.merge(cop_options(cops))

        @runner.run(path, text, diagnostic_options, prism_result: prism_result)
        @runner.offenses
      end

      # What went wrong in the last run. Cop errors only end up here when
      # `raise_cop_error` is off; otherwise they are raised.
      def errors
        @runner.errors
      end

      def warnings
        @runner.warnings
      end

      private

      def build_diagnostic(offense, path, document_encoding, processed_source, config)
        Diagnostic.new(
          document_encoding,
          offense,
          path,
          RuboCop::Cop::Registry.global.find_by_cop_name(offense.cop_name),
          processed_source
        ).to_lsp_diagnostic(config)
      end

      # The cops to run: the caller's `only` and `except`, or the departments a
      # lint or layout mode limits the server to.
      def cop_options(cops)
        only, except = cops&.values_at(:only, :except)
        only ||= config_only_options if @lint_mode || @layout_mode
        { only: only, except: except }.compact
      end

      def config_only_options
        only_options = []
        only_options << 'Lint' if @lint_mode
        only_options << 'Layout' if @layout_mode
        only_options
      end
    end
  end
end
