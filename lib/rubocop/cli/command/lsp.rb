# frozen_string_literal: true

require_relative '../../lsp/server'

module RuboCop
  class CLI
    module Command
      # Start Language Server Protocol of RuboCop.
      # @api private
      class Lsp < Base
        self.command_name = :lsp

        def run
          RuboCop::Lsp::Server.new(@config_store).start
        end
      end
    end
  end
end
