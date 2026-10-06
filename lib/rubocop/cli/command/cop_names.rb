# frozen_string_literal: true

module RuboCop
  class CLI
    module Command
      # Shared handling for commands that take a list of cop names.
      #
      # Validation happens here rather than during option parsing because the
      # registry is not complete until the configuration has been loaded, which
      # is also why `--only` and `--except` are validated from the runner.
      # @api private
      module CopNames
        private

        # The cops among `names` that exist, so a command can report on what it
        # understood before {#validate_cop_names!} objects to the rest.
        def known_cop_classes(names)
          names.filter_map { |name| cop_class_for(name) }
        end

        # @raise [IncorrectCopNameError] if any name is not a cop
        def validate_cop_names!(names)
          unknown = names.reject { |name| cop_class_for(name) }
          return if unknown.empty?

          raise IncorrectCopNameError, unknown.map { |name| unknown_cop_message(name) }.join("\n")
        end

        # Not memoized: the MCP server lives long enough for a plugin to register
        # a cop after a lookup has missed it.
        def cop_class_for(name)
          Cop::Registry.global.find_by_cop_name(name)
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
