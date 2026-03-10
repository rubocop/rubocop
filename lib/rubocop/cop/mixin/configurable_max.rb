# frozen_string_literal: true

module RuboCop
  module Cop
    # Handles `Max` configuration parameters, especially setting them to an
    # appropriate value with --auto-gen-config.
    # @deprecated Use `exclude_limit <ParameterName>` instead.
    module ConfigurableMax
      private

      def max=(value)
        warn Rainbow(<<~WARNING).yellow, uplevel: 1
          `max=` is deprecated. Use `exclude_limit <ParameterName>` instead.
        WARNING

        cop_dir = RuboCop::ExcludeLimit.cop_dir_for(self.class.badge.to_s)
        return unless cop_dir

        cop_dir.mkpath
        filepath = cop_dir.join(max_parameter_name)
        filepath.write("#{value}\n", mode: 'a')
      end

      def max_parameter_name
        'Max'
      end
    end
  end
end
