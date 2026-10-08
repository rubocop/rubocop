# frozen_string_literal: true

module RuboCop
  module MCP
    # What an autocorrection request asks for, shared by every file it corrects.
    # The keywords are the tool's arguments, so an unknown one is refused.
    # @api private
    class AutocorrectionRequest
      PROPERTIES = {
        safety: { type: 'boolean' },
        contextual: { type: 'boolean' },
        dry_run: { type: 'boolean' },
        max_offenses_per_cop: { type: 'integer', minimum: 1 }
      }.freeze

      # The offenses left over come back after the files are written, so they're
      # capped unless the agent asks otherwise: a result too big for the client
      # would hide what was done.
      DEFAULT_MAX_OFFENSES_PER_COP = 5

      attr_reader :scope, :limit

      def initialize(scope, safety: true, contextual: false, dry_run: false,
                     max_offenses_per_cop: DEFAULT_MAX_OFFENSES_PER_COP)
        @scope = scope
        @safety = safety
        @contextual = contextual
        @dry_run = dry_run
        @limit = OffenseLimit.new(max_offenses_per_cop)
      end

      def dry_run?
        @dry_run
      end

      # Cops with `AutoCorrect: contextual` hold back corrections that get in
      # the way of code still being written, such as removing a variable that
      # is about to be used. The server runs in LSP mode, which holds them
      # back, so an agent that is done editing has to ask for them.
      def run(&block)
        @contextual ? LSP.disable(&block) : yield
      end

      # The options `LSP::Runtime#format` takes to apply the corrections
      # `safety` allows, from the cops the scope selects.
      def format_options
        command = @safety ? 'rubocop.formatAutocorrects' : 'rubocop.formatAutocorrectsAll'
        { command: command, cops: @scope.cop_options }
      end
    end
  end
end
