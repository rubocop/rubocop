# frozen_string_literal: true

module RuboCop
  class CLI
    module Command
      # Prints out url to documentation of provided cops
      # or documentation base url by default.
      # @api private
      class ShowDocsUrl < Base
        include CopNames

        self.command_name = :show_docs_url

        def initialize(env)
          super

          @config = @config_store.for(PathUtil.pwd)
        end

        def run
          print_documentation_url
          # Checked after printing, so a typo alongside good names still gives
          # you the urls you asked for.
          validate_cop_names!(cops_array)
        end

        private

        def print_documentation_url
          puts Cop::Documentation.default_base_url if cops_array.empty?

          known_cop_classes(cops_array).each do |cop|
            url = Cop::Documentation.url_for(cop, @config)
            puts url if url
          end

          puts
        end

        def cops_array
          @cops_array ||= @options[:show_docs_url]
        end
      end
    end
  end
end
