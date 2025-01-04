# frozen_string_literal: true

module RuboCop
  module Plugin
    # An exception raised when a plugin fails to load.
    # @api private
    class LoadError < Error
      def initialize(plugin_name)
        super

        @plugin_name = plugin_name
      end

      def message
        <<~MESSAGE
          Failed loading plugin `#{@plugin_name}` because we couldn't determine the corresponding plugin class to instantiate.
          First, try upgrading it. If the issue persists, please check with the developer regarding the following points.

          RuboCop plugin class names must either be:

            - If the plugin is a gem, defined in the gemspec as `default_lint_roller_plugin'

              spec.metadata['default_lint_roller_plugin'] = 'MyModule::Plugin'

            - Set in YAML as `plugin_class_name'; example:

              plugins:
                - incomplete:
                    require_path: my_module/plugin
                    plugin_class_name: "MyModule::Plugin"
        MESSAGE
      end
    end
  end
end
