# frozen_string_literal: true

require_relative 'severity'

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
    # Diagnostic for Language Server Protocol of RuboCop.
    # @api private
    class Diagnostic
      def initialize(position_encoding, offense, uri, cop_class)
        @position_encoding = position_encoding
        @offense = offense
        @uri = uri
        @cop_class = cop_class
      end

      def to_lsp_code_actions
        code_actions = []

        code_actions << autocorrect_action if correctable?
        code_actions << disable_line_action

        code_actions
      end

      # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      def to_lsp_diagnostic(config)
        highlighted = @offense.highlighted_area

        LanguageServer::Protocol::Interface::Diagnostic.new(
          message: message,
          source: 'RuboCop',
          code: @offense.cop_name,
          code_description: code_description(config),
          severity: severity,
          range: LanguageServer::Protocol::Interface::Range.new(
            start: LanguageServer::Protocol::Interface::Position.new(
              line: @offense.line - 1,
              character: char_pos(highlighted.begin_pos)
            ),
            end: LanguageServer::Protocol::Interface::Position.new(
              line: @offense.line - 1,
              character: char_pos(highlighted.end_pos)
            )
          ),
          data: {
            correctable: correctable?,
            code_actions: to_lsp_code_actions
          }
        )
      end
      # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

      private

      def message
        message = @offense.message
        message += "\n\nThis offense is not autocorrectable.\n" unless correctable?
        message
      end

      def severity
        Severity.find_by(@offense.severity.name)
      end

      def code_description(config)
        return unless @cop_class
        return unless (doc_url = @cop_class.documentation_url(config))

        LanguageServer::Protocol::Interface::CodeDescription.new(href: doc_url)
      end

      # rubocop:disable Metrics/MethodLength
      def autocorrect_action
        LanguageServer::Protocol::Interface::CodeAction.new(
          title: "Autocorrect #{@offense.cop_name}",
          kind: LanguageServer::Protocol::Constant::CodeActionKind::QUICK_FIX,
          edit: LanguageServer::Protocol::Interface::WorkspaceEdit.new(
            document_changes: [
              LanguageServer::Protocol::Interface::TextDocumentEdit.new(
                text_document: LanguageServer::Protocol::Interface::OptionalVersionedTextDocumentIdentifier.new(
                  uri: ensure_uri_scheme(@uri.to_s).to_s,
                  version: nil
                ),
                edits: correctable? ? offense_replacements : []
              )
            ]
          ),
          is_preferred: true
        )
      end
      # rubocop:enable Metrics/MethodLength

      # rubocop:disable Metrics/MethodLength
      def offense_replacements
        @offense.corrector.as_replacements.map do |range, replacement|
          LanguageServer::Protocol::Interface::TextEdit.new(
            range: LanguageServer::Protocol::Interface::Range.new(
              start: LanguageServer::Protocol::Interface::Position.new(
                line: range.line - 1,
                character: char_pos(range.column)
              ),
              end: LanguageServer::Protocol::Interface::Position.new(
                line: range.last_line - 1,
                character: char_pos(range.last_column)
              )
            ),
            new_text: replacement
          )
        end
      end
      # rubocop:enable Metrics/MethodLength

      # rubocop:disable Metrics/MethodLength
      def disable_line_action
        LanguageServer::Protocol::Interface::CodeAction.new(
          title: "Disable #{@offense.cop_name} for this line",
          kind: LanguageServer::Protocol::Constant::CodeActionKind::QUICK_FIX,
          edit: LanguageServer::Protocol::Interface::WorkspaceEdit.new(
            document_changes: [
              LanguageServer::Protocol::Interface::TextDocumentEdit.new(
                text_document: LanguageServer::Protocol::Interface::OptionalVersionedTextDocumentIdentifier.new(
                  uri: ensure_uri_scheme(@uri.to_s).to_s,
                  version: nil
                ),
                edits: line_disable_comment
              )
            ]
          )
        )
      end
      # rubocop:enable Metrics/MethodLength

      def line_disable_comment
        new_text = if @offense.source_line.include?(' # rubocop:disable ')
                     ",#{@offense.cop_name}"
                   else
                     " # rubocop:disable #{@offense.cop_name}"
                   end

        eol = LanguageServer::Protocol::Interface::Position.new(
          line: @offense.line - 1,
          character: char_pos
        )

        # TODO: fails for multiline strings - may be preferable to use block
        # comments to disable some offenses
        inline_comment = LanguageServer::Protocol::Interface::TextEdit.new(
          range: LanguageServer::Protocol::Interface::Range.new(start: eol, end: eol),
          new_text: new_text
        )

        [inline_comment]
      end

      def correctable?
        !@offense.corrector.nil?
      end

      def ensure_uri_scheme(uri)
        uri = URI.parse(uri)
        uri.scheme = 'file' if uri.scheme.nil?
        uri
      end

      def char_pos(nchars = nil)
        str = nchars ? @offense.source_line[0, nchars] : @offense.source_line
        case @position_encoding
        when 'utf-32'
          str.size
        when 'utf-8'
          str.bytesize
        else # 'utf-16'
          str.size + str.count("\u{10000}-\u{10FFFF}")
        end
      end
    end
  end
end
