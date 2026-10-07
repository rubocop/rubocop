# frozen_string_literal: true

module RuboCop
  module MCP
    # The `rubocop_explain` tool: what cops do, as `--explain` prints it.
    # @api private
    class ExplainTool
      include RuboCop::CLI::Command::CopNames

      DESCRIPTION =
        'Explain what cops do: the problem each one targets, bad and good examples, ' \
        'its configuration as this project resolves it, and whether it autocorrects. ' \
        'Takes cop names as offenses report them, such as `Style/StringLiterals`. ' \
        'Pass the `path` of a file to see the configuration that applies to it.'
      INPUT_SCHEMA = {
        properties: {
          cop_names: { type: 'array', items: { type: 'string' }, minItems: 1 },
          path: { type: 'string' }
        },
        required: ['cop_names']
      }.freeze
      ANNOTATIONS = {
        title: "RuboCop's cop explanation", destructive_hint: false, idempotent_hint: true,
        open_world_hint: false, read_only_hint: true
      }.freeze

      def initialize(config_store)
        @config_store = config_store
      end

      # The tool's block does not run in this instance, so it reaches
      # `explain` through a method object it closes over.
      def to_tool
        explain = method(:explain)

        ::MCP::Tool.define(
          name: 'rubocop_explain',
          description: DESCRIPTION,
          input_schema: INPUT_SCHEMA,
          annotations: ANNOTATIONS
        ) do |cop_names:, path: nil|
          ::MCP::Tool::Response.new([{ type: 'text', text: explain.call(cop_names, path) }])
        rescue RuboCop::Error => e
          ::MCP::Tool::Response.new([{ type: 'text', text: e.message }], error: true)
        end
      end

      private

      # Explains the cops it recognizes and then names the ones it does not, as
      # `--explain` does, so a typo does not cost the explanations asked for
      # alongside it. The configuration is loaded first, since that is what
      # registers the cops of any plugins it names.
      def explain(cop_names, path)
        config = path ? @config_store.for_file(path) : @config_store.for_pwd
        explanations = known_cop_classes(cop_names).map do |cop_class|
          Cop::CopExplanation.new(cop_class, config).to_s
        end
        validate_cop_names!(cop_names)

        explanations.join("\n\n")
      rescue IncorrectCopNameError => e
        raise RuboCop::Error, [*explanations, e.message].join("\n\n")
      end
    end
  end
end
