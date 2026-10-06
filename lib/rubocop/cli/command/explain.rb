# frozen_string_literal: true

module RuboCop
  class CLI
    module Command
      # Explains what cops do, as described by {Cop::CopExplanation}.
      # @api private
      class Explain < Base
        include CopNames

        self.command_name = :explain

        def initialize(env)
          super

          @config = @config_store.for(PathUtil.pwd)
        end

        def run
          names = @options[:explain]

          known_cop_classes(names).each_with_index do |cop_class, index|
            puts if index.positive?
            puts Cop::CopExplanation.new(cop_class, @config)
          end

          # Checked after printing, so a typo in a list does not cost you the
          # explanations you asked for alongside it.
          validate_cop_names!(names)
        end
      end
    end
  end
end
