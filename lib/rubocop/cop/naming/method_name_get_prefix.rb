# frozen_string_literal: true

module RuboCop
  module Cop
    module Naming
      # Checks for methods with `get_` or `set_` prefixes that take arguments.
      #
      # For `get_` prefixed methods, suggests using `_for` suffix or `find_` prefix.
      # For `set_` prefixed methods with a single required argument, suggests using
      # `=` method syntax for regular methods, or `create_`, `put_`, or `update_`
      # prefixes for API methods. Methods with 2+ required arguments are excluded
      # since the `=` suffix is only idiomatic for single-argument setters.
      #
      # @example
      #   # bad
      #   def get_user(id)
      #     User.find(id)
      #   end
      #
      #   # good
      #   def user_for(id)
      #     User.find(id)
      #   end
      #
      # @example
      #   # bad
      #   def set_custom_var(val)
      #     @custom_var = val
      #   end
      #
      #   # good
      #   def custom_var=(val)
      #     @custom_var = val
      #   end
      class MethodNameGetPrefix < Base
        extend AutoCorrector

        MSG_GET = 'Avoid using `get_` prefix for methods with arguments. ' \
                  'Consider using `%<method_name>s_for` or `find_%<method_name>s` instead.'

        MSG_SET = 'Avoid using `set_` prefix for methods with arguments. ' \
                  'Consider using `%<method_name>s=` instead.'

        MSG_SET_API = 'Avoid using `set_` prefix for methods with arguments. ' \
                      'Consider using `%<suggestions>s` instead.'

        # Patterns that indicate HTTP GET requests (methods that should be excluded)
        HTTP_GET_PATTERNS = [
          /\.get\(/,                    # connection.get, HTTP.get, etc.
          /connection\.get/,            # Faraday connection.get
          /HTTP\.get/,                  # Net::HTTP.get
          /RestClient\.get/,            # RestClient.get
          /Faraday\.get/,               # Direct Faraday.get
          /Net::HTTP\.get/,             # Net::HTTP.get
          /\.get\s*\(/,                 # Any .get( call
          /Net::HTTP::Get\.new/,        # Net::HTTP::Get.new (like in affirm.rb)
          /Net::HTTP::Get/,             # Net::HTTP::Get class reference
          /http\.request/,              # http.request(request) where request is GET
          /https\.request/,             # https.request(request) where request is GET
          /Net::HTTP\.new/              # Net::HTTP.new (indicates HTTP client usage)
        ].freeze

        # Patterns for standalone get() calls that are likely HTTP GET wrappers
        # (only checked in API client files)
        HTTP_GET_WRAPPER_PATTERNS = [
          /\bget\s*\(/ # get(...) method call
        ].freeze

        # File path patterns that indicate API clients/controllers
        API_FILE_PATTERNS = [
          /client/i, # *client*.rb
          /api_client/i, # *api_client*.rb
          /controller/i, # *controller*.rb
          %r{/api/}, # files in /api/ directory
          %r{/clients/} # files in /clients/ directory
        ].freeze

        def on_def(node)
          method_name = node.method_name.to_s

          if method_name.start_with?('get_')
            handle_get_prefix(node)
          elsif method_name.start_with?('set_')
            handle_set_prefix(node)
          end
        end

        def handle_get_prefix(node)
          return if node.arguments.empty? # Let Naming/AccessorMethodName handle these

          # Skip if method makes HTTP GET requests
          return if makes_http_get_request?(node)

          # Skip if file path suggests it's an API client/controller
          # AND method calls get() which is likely an HTTP GET wrapper
          return if api_file?(node) && calls_get_method?(node)

          method_name_without_prefix = node.method_name.to_s.sub(/^get_/, '')
          suggested_name = "#{method_name_without_prefix}_for"

          message = format(MSG_GET, method_name: method_name_without_prefix)
          add_offense(node, message: message) do |corrector|
            corrector.replace(node.loc.name, suggested_name)
          end
        end

        def handle_set_prefix(node)
          return if node.arguments.empty? # Let Naming/AccessorMethodName handle these

          # Skip if method has 2+ required arguments (without defaults)
          # The `=` suffix is only idiomatic for single-argument setters
          return if required_argument_count(node) >= 2

          method_name_without_prefix = node.method_name.to_s.sub(/^set_/, '')
          is_api_file = api_file?(node)

          message = build_set_message(method_name_without_prefix, is_api_file)
          suggested_name = build_set_suggested_name(method_name_without_prefix, is_api_file)

          add_offense(node, message: message) do |corrector|
            corrector.replace(node.loc.name, suggested_name)
          end
        end

        def build_set_message(method_name_without_prefix, is_api_file)
          if is_api_file
            suggested_names = [
              "create_#{method_name_without_prefix}",
              "put_#{method_name_without_prefix}",
              "update_#{method_name_without_prefix}"
            ]
            format(MSG_SET_API, suggestions: suggested_names.join('`, `'))
          else
            format(MSG_SET, method_name: method_name_without_prefix)
          end
        end

        def build_set_suggested_name(method_name_without_prefix, is_api_file)
          if is_api_file
            "create_#{method_name_without_prefix}"
          else
            "#{method_name_without_prefix}="
          end
        end

        private

        def makes_http_get_request?(node)
          source = node.source
          HTTP_GET_PATTERNS.any? { |pattern| source.match?(pattern) }
        end

        def api_file?(_node)
          file_path = processed_source.file_path
          API_FILE_PATTERNS.any? { |pattern| file_path.match?(pattern) }
        end

        def calls_get_method?(node)
          source = node.source
          HTTP_GET_WRAPPER_PATTERNS.any? { |pattern| source.match?(pattern) }
        end

        def required_argument_count(node)
          node.arguments.count do |arg|
            # Count required positional arguments (arg) and required keyword arguments (kwarg)
            # Exclude optional args (optarg, kwoptarg), splat args (restarg, kwrestarg),
            # and block args (blockarg)
            arg.arg_type? || arg.kwarg_type?
          end
        end
      end
    end
  end
end
