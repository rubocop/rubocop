# frozen_string_literal: true

module RuboCop
  module Cop
    # Explains what a single cop does: its description, how it is configured,
    # whether it corrects, and the examples from its own documentation.
    #
    # Rendered as plain text, which is what `--explain` prints and what the MCP
    # server hands to an agent.
    # @api private
    class CopExplanation
      # Keys that describe the cop to RuboCop itself rather than something a
      # user would set, so they are reported in their own section or not at all.
      METADATA_KEYS = %w[
        Description StyleGuide Reference References Enabled Safe SafeAutoCorrect
        AutoCorrect VersionAdded VersionChanged Include Exclude Details Preview
      ].freeze

      def initialize(cop_class, config)
        @cop_class = cop_class
        @config = config
        @cop_config = config.for_cop(cop_class.cop_name)
      end

      def to_s
        lines.join("\n")
      end

      private

      def lines
        description = description_lines

        [
          @cop_class.cop_name,
          *section(nil, description),
          *section('Properties', property_lines),
          *documentation_sections(description).flat_map { |title, body| section(title, body) },
          *section('Configuration', configuration_lines),
          *section('References', reference_lines)
        ]
      end

      def section(title, body)
        return [] if body.empty?

        heading = title ? [title, ''] : []
        ['', *heading, *body.map { |line| line.empty? ? '' : "  #{line}" }]
      end

      def description_lines
        Array(@cop_config['Description']).flat_map { |line| line.split("\n") }
      end

      def property_lines
        [
          "Enabled:     #{@cop_config.fetch('Enabled', true)}",
          "Safe:        #{@cop_config.fetch('Safe', true)}",
          "Autocorrect: #{autocorrect_description}",
          *version_lines,
          *scope_lines
        ]
      end

      # Which files the cop looks at. A cop that only runs on Gemfiles
      # explains an absent offense better than anything else here does.
      def scope_lines
        [
          *patterns_line('Applies to:  ', @cop_config['Include']),
          *patterns_line('Excludes:    ', @cop_config['Exclude'])
        ]
      end

      def patterns_line(label, patterns)
        patterns = Array(patterns).compact
        return [] if patterns.empty?

        ["#{label}#{patterns.map { |pattern| readable_pattern(pattern) }.join(', ')}"]
      end

      # `Exclude` patterns are absolutized against the config that set them,
      # which makes for a wall of identical prefixes. A user config can also
      # hold a regexp rather than a glob.
      def readable_pattern(pattern)
        pattern.is_a?(String) ? PathUtil.smart_path(pattern) : pattern.inspect
      end

      def autocorrect_description
        return 'not supported' unless @cop_class.support_autocorrect?

        # Asks the cop, so `AutoCorrect` is read the way the cop reads it.
        cop = @cop_class.new(@config)
        return 'disabled' unless cop.always_autocorrect? || cop.contextual_autocorrect?

        description = cop.safe_autocorrect? ? 'safe, applied by -a' : 'unsafe, applied by -A only'
        # Contextual corrections wait until the code is finished, which an
        # editor or an agent mid-edit cannot promise, so they have to ask.
        description += ', but through LSP or MCP only on request' if cop.contextual_autocorrect?
        description
      end

      def version_lines
        lines = []
        lines << "Added:       #{@cop_config['VersionAdded']}" if @cop_config['VersionAdded']
        lines << "Changed:     #{@cop_config['VersionChanged']}" if @cop_config['VersionChanged']
        lines
      end

      def configuration_lines
        (@cop_config.keys - METADATA_KEYS).sort.map do |key|
          "#{key}: #{format_value(@cop_config[key])}"
        end
      end

      def format_value(value)
        value.is_a?(Array) ? value.join(', ') : value.to_s
      end

      def reference_lines
        annotator = MessageAnnotator.new(@config, @cop_class.cop_name, @cop_config, {})

        [*annotator.urls, Documentation.url_for(@cop_class, @config)].compact
      end

      # The comment above the class opens by restating the description, which
      # is already printed above, so that opening is dropped.
      def documentation_sections(description)
        CopDocumentation.new(@cop_class).sections.filter_map do |title, body|
          body -= description if title == 'Details'
          body = strip_blank(body)
          [title, body] unless body.empty?
        end
      end

      def strip_blank(lines)
        lines.drop_while(&:empty?).reverse.drop_while(&:empty?).reverse
      end
    end
  end
end
