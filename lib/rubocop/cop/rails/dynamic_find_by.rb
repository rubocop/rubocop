# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # This cop checks dynamic `find_by_*` methods.
      # Use `find_by` instead of dynamic method.
      # See. https://github.com/bbatsov/rails-style-guide#find_by
      #
      # @example
      #   # bad
      #   User.find_by_name(name)
      #
      #   # bad
      #   User.find_by_name_and_email(name)
      #
      #   # bad
      #   User.find_by_email!(name)
      #
      #   # good
      #   User.find_by(name: name)
      #
      #   # good
      #   User.find_by(name: name, email: email)
      #
      #   # good
      #   User.find_by!(email: email)
      class DynamicFindBy < Cop
        MSG = 'Use `%s` instead of dynamic `%s`.'.freeze
        METHOD_PATTERN = /^find_by_(.+?)(!)?$/

        def on_send(node)
          method_name = node.method_name.to_s

          return if whitelist.include?(method_name)

          static_name = static_method_name(method_name)

          return unless static_name

          add_offense(node,
                      message: format(MSG, static_name, node.method_name))
        end

        def autocorrect(node)
          _receiver, method, *args = *node
          static_name = static_method_name(method.to_s)
          keywords = column_keywords(method)

          return if keywords.size != args.size

          lambda do |corrector|
            corrector.replace(node.loc.selector, static_name)
            keywords.each.with_index do |keyword, idx|
              corrector.insert_before(args[idx].loc.expression, keyword)
            end
          end
        end

        private

        def whitelist
          cop_config['Whitelist']
        end

        def column_keywords(method)
          keyword_string = method.to_s[METHOD_PATTERN, 1]
          keyword_string.split('_and_').map { |keyword| "#{keyword}: " }
        end

        # Returns static method name.
        # If code isn't wrong, returns nil
        def static_method_name(method_name)
          match = METHOD_PATTERN.match(method_name)
          return nil unless match
          match[2] ? 'find_by!' : 'find_by'
        end
      end
    end
  end
end
