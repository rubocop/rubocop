# frozen_string_literal: true

module RuboCop
  class CLI
    module Command
      # Lists the cops that will inspect the given file or directory.
      # @api private
      class ListEnabledCopsFor < Base
        self.command_name = :list_enabled_cops_for

        def initialize(env)
          super

          # Load the configs so the require()s are done for custom cops
          @config = @config_store.for(@options[:list_enabled_cops_for])
        end

        def run
          print_available_cops
        end

        private

        def print_available_cops
          registry = Cop::Registry.global

          registry.departments.sort.each do |department|
            puts cops_of_department(registry, department).sort
          end
        end

        def cops_of_department(registry, department)
          registry.with_department(department)
                  .map(&:cop_name)
                  .select { |cop_name| @config.cop_enabled?(cop_name) }
        end
      end
    end
  end
end
