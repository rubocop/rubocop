# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # This cop is used to identify usages of http methods
      # like `get`, `post`, `put`, `path` without the usage of keyword arguments
      # in your tests and change them to use keyword arguments.
      #
      # @example
      #   # bad
      #   get :new, { user_id: 1}
      #
      #   # good
      #   get :new, params: { user_id: 1 }
      class HttpPositionalArguments < Cop
        MSG = 'Use keyword arguments instead of ' \
              'positional arguments for http call: `%s`.'.freeze
        KEYWORD_ARGS = [
          :headers, :env, :params, :body, :flash, :as,
          :xhr, :session, :method, :format
        ].freeze
        HTTP_METHODS = [:get, :post, :put, :patch, :delete, :head].freeze

        def on_send(node)
          receiver, http_method, http_path, data = *node
          # if the first word on the line is not an http method, then skip
          return unless HTTP_METHODS.include?(http_method)
          # if the data is nil then we don't need to add keyword arguments
          # because there is no data to put in params or headers, so skip
          return if data.nil?
          return unless needs_conversion?(data)
          # ensures this is the first method on the line
          # there is an edge case here where sometimes the http method is
          # wrapped into another method, but its just safer to skip those
          # cases and process manually
          return unless receiver.nil?
          # a http_method without a path?, must be something else
          return if http_path.nil?
          add_offense(node, node.loc.selector, format(MSG, node.method_name))
        end

        # @return [Boolean] true if the line needs to be converted
        def needs_conversion?(data)
          # if the line has already been converted to use keyword args
          # then skip
          # ie. get :new, params: { user_id: 1 }  (looking for keyword arg)
          value = data.descendants.find do |d|
            KEYWORD_ARGS.include?(d.children.first) if d.type == :sym
          end
          value.nil?
        end

        def convert_hash_data(data, type)
          # empty hash or no hash return empty string
          return '' if data.nil? || data.children.count < 1
          hash_data = if data.hash_type?
                        format('{ %s }', data.children.map(&:source).join(', '))
                      else
                        # user supplies an object,
                        # no need to surround with braces
                        data.source
                      end
          format(', %s: %s', type, hash_data)
        end

        # given a pre Rails 5 method: get :new, user_id: @user.id, {}
        #
        # @return lambda of auto correct procedure
        # the result should look like:
        #     get :new, params: { user_id: @user.id }, headers: {}
        # the http_method is the method use to call the controller
        # the controller node can be a symbol, method, object or string
        # that represents the path/action on the Rails controller
        # the data is the http parameters and environment sent in
        # the Rails 5 http call
        def autocorrect(node)
          _receiver, http_method, http_path, *data = *node
          controller_action = http_path.source
          params = convert_hash_data(data.first, 'params')
          headers = convert_hash_data(data.last, 'headers') if data.count > 1
          # the range of the text to replace, which is the whole line
          code_to_replace = node.loc.expression
          # what to replace with
          new_code = format('%s %s%s%s', http_method, controller_action,
                            params, headers)
          ->(corrector) { corrector.replace(code_to_replace, new_code) }
        end
      end
    end
  end
end
