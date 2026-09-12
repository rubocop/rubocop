# frozen_string_literal: true

module RuboCop
  class CLI
    module Command
      # Explains what a single cop does: its description, how it is configured,
      # whether it corrects, and the examples from its own documentation.
      # @api private
      class Explain < Base
        self.command_name = :explain

        # Keys that describe the cop to RuboCop itself rather than something a
        # user would set, so they are reported in their own section or not at all.
        METADATA_KEYS = %w[
          Description StyleGuide Reference References Enabled Safe SafeAutoCorrect
          AutoCorrect VersionAdded VersionChanged Include Exclude Details Preview
        ].freeze

        def initialize(env)
          super

          @config = @config_store.for(PathUtil.pwd)
        end

        def run
          found, missing = @options[:explain].partition { |name| cop_class_for(name) }

          found.each_with_index do |name, index|
            puts if index.positive?
            print_explanation(cop_class_for(name))
          end

          # Reported after the cops that were found, so a typo in a list does
          # not cost you the explanations you asked for alongside it.
          raise IncorrectCopNameError, unknown_cops_message(missing) if missing.any?
        end

        private

        def print_explanation(cop_class)
          cop_config = @config.for_cop(cop_class.cop_name)

          description = description_lines(cop_config)

          puts cop_class.cop_name
          print_section(nil, description)
          print_section('Properties', property_lines(cop_class, cop_config))
          documentation_sections(cop_class, description).each do |title, body|
            print_section(title, body)
          end
          print_section('Configuration', configuration_lines(cop_config))
          print_section('References', reference_lines(cop_class, cop_config))
        end

        def print_section(title, lines)
          return if lines.empty?

          puts
          if title
            puts title
            puts
          end
          lines.each { |line| puts line.empty? ? '' : "  #{line}" }
        end

        def description_lines(cop_config)
          Array(cop_config['Description']).flat_map { |line| line.split("\n") }
        end

        def property_lines(cop_class, cop_config)
          [
            "Enabled:     #{cop_config.fetch('Enabled', true)}",
            "Safe:        #{cop_config.fetch('Safe', true)}",
            "Autocorrect: #{autocorrect_description(cop_class, cop_config)}",
            *version_lines(cop_config),
            *scope_lines(cop_config)
          ]
        end

        # Which files the cop looks at. A cop that only runs on Gemfiles
        # explains an absent offense better than anything else here does.
        def scope_lines(cop_config)
          [
            *patterns_line('Applies to:  ', cop_config['Include']),
            *patterns_line('Excludes:    ', cop_config['Exclude'])
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

        def autocorrect_description(cop_class, cop_config)
          return 'not supported' unless cop_class.support_autocorrect?

          if cop_config.fetch('Safe', true) && cop_config.fetch('SafeAutoCorrect', true)
            'safe, applied by -a'
          else
            'unsafe, applied by -A only'
          end
        end

        def version_lines(cop_config)
          lines = []
          lines << "Added:       #{cop_config['VersionAdded']}" if cop_config['VersionAdded']
          lines << "Changed:     #{cop_config['VersionChanged']}" if cop_config['VersionChanged']
          lines
        end

        def configuration_lines(cop_config)
          (cop_config.keys - METADATA_KEYS).sort.map do |key|
            "#{key}: #{format_value(cop_config[key])}"
          end
        end

        def format_value(value)
          value.is_a?(Array) ? value.join(', ') : value.to_s
        end

        def reference_lines(cop_class, cop_config)
          annotator = Cop::MessageAnnotator.new(@config, cop_class.cop_name, cop_config, {})

          [*annotator.urls, Cop::Documentation.url_for(cop_class, @config)].compact
        end

        # The comment above the class opens by restating the description, which
        # is already printed above, so that opening is dropped.
        def documentation_sections(cop_class, description)
          sections = Cop::CopDocumentation.new(cop_class).sections
          sections.filter_map do |title, body|
            body -= description if title == 'Details'
            body = strip_blank(body)
            [title, body] unless body.empty?
          end
        end

        def strip_blank(lines)
          lines.drop_while(&:empty?).reverse.drop_while(&:empty?).reverse
        end

        def cop_class_for(name)
          @cop_classes ||= {}
          @cop_classes.fetch(name) { @cop_classes[name] = Cop::Registry.global.find_by_cop_name(name) }
        end

        def unknown_cops_message(names)
          names.map { |name| unknown_cop_message(name) }.join("\n")
        end

        def unknown_cop_message(name)
          return department_message(name) if department?(name)

          message = "Unrecognized cop: #{name}."
          similar = NameSimilarity.find_similar_names(name, Cop::Registry.global.names)
          return message if similar.empty?

          "#{message}\nDid you mean? #{similar.join(', ')}"
        end

        def department?(name)
          Cop::Registry.global.departments.any? { |department| department.to_s == name }
        end

        def department_message(name)
          example = Cop::Registry.global.names.find { |cop| cop.start_with?("#{name}/") }

          "#{name} is a department, not a cop. Name one of its cops, such as #{example}."
        end
      end
    end
  end
end
