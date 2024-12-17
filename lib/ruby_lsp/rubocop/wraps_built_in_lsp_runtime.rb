# frozen_string_literal: true

module RubyLsp
  module RuboCop
    # Wrap RuboCop's built-in runtime for Ruby LSP's add-on.
    class WrapsBuiltinLspRuntime
      include RubyLsp::Requests::Support::Formatter

      def initialize
        init!
      end

      def init!
        config = ::RuboCop::ConfigStore.new
        @runtime = ::RuboCop::LSP::Runtime.new(config)
        @rubocop_config = config.for_pwd
        @cop_registry = ::RuboCop::Cop::Registry.global.to_h
      end

      # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      def run_diagnostic(uri, document)
        offenses = @runtime.offenses(uri_to_path(uri), document.source)

        # rubocop:disable Metrics/BlockLength
        offenses.map do |o|
          cop_name = o[:cop_name]

          msg = o[:message].delete_prefix(cop_name)
          loc = o[:location]

          severity = case o[:severity]
                     when 'error', 'fatal'
                       RubyLsp::Constant::DiagnosticSeverity::ERROR
                     when 'warning'
                       RubyLsp::Constant::DiagnosticSeverity::WARNING
                     when 'convention'
                       RubyLsp::Constant::DiagnosticSeverity::INFORMATION
                     when 'refactor', 'info'
                       RubyLsp::Constant::DiagnosticSeverity::HINT
                     else # the above cases fully cover what RuboCop sends at this time
                       logger.puts "Unknown severity: #{severity.inspect}"
                       RubyLsp::Constant::DiagnosticSeverity::HINT
                     end

          RubyLsp::Interface::Diagnostic.new(
            code: cop_name,
            code_description: code_description(cop_name),
            message: msg,
            source: 'RuboCop',
            severity: severity,
            range: RubyLsp::Interface::Range.new(
              start: RubyLsp::Interface::Position.new(
                line: loc[:start_line] - 1, character: loc[:start_column] - 1
              ),

              end: RubyLsp::Interface::Position.new(
                line: loc[:last_line] - 1, character: loc[:last_column]
              )
            )
            # TODO: We need to do something like to support quickfixes thru code actions
            # See: https://github.com/Shopify/ruby-lsp/blob/4c1906172add4d5c39c35d3396aa29c768bfb898/lib/ruby_lsp/requests/support/rubocop_diagnostic.rb#L62
            # data: {
            #   correctable: correctable?(offense),
            #   code_actions: to_lsp_code_actions
            # }
            #
            # Right now, our offenses are all just JSON parsed from stdout shelling to RuboCop, so
            # it seems we don't have the corrector available to us.
            #
            # Lifted from:
            # https://github.com/Shopify/ruby-lsp/blob/8d4c17efce4e8ecc8e7c557ab2981db6b22c0b6d/lib/ruby_lsp/requests/support/rubocop_diagnostic.rb#L201
            # def correctable?(offense)
            #   !offense.corrector.nil?
            # end
          )
        end
        # rubocop:enable Metrics/BlockLength
      end
      # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

      def run_formatting(uri, document)
        @runtime.format(uri_to_path(uri), document.source, command: 'rubocop.formatAutocorrects')
      end

      private

      # duplicated from: lib/standard/lsp/routes.rb
      # modified to incorporate Ruby LSP's to_standardized_path method
      def uri_to_path(uri)
        if uri.respond_to?(:to_standardized_path) && (standardized_path = uri.to_standardized_path)
          standardized_path
        else
          uri.to_s.delete_prefix('file://')
        end
      end

      # lifted from:
      # https://github.com/Shopify/ruby-lsp/blob/4c1906172add4d5c39c35d3396aa29c768bfb898/lib/ruby_lsp/requests/support/rubocop_diagnostic.rb#L84
      def code_description(cop_name)
        return unless (cop_class = @cop_registry[cop_name]&.first)
        return unless (doc_url = cop_class.documentation_url(@rubocop_config))

        Interface::CodeDescription.new(href: doc_url)
      end
    end
  end
end
