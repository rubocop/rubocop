# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # This cop checks dynamic `find_by_*` methods.
      # Use `find_by` instead of dynamic method.
      # See. https://github.com/rubocop-hq/rails-style-guide#find_by
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
        MSG = 'Use `%<static_name>s` instead of dynamic `%<method>s`.'.freeze
        METHOD_PATTERN = /^find_by_(.+?)(!)?$/.freeze

        def on_send(node)
          method_name = node.method_name.to_s

          return if whitelist.include?(method_name)

          static_name = static_method_name(method_name)

          return unless static_name

          add_offense(node,
                      message: format(MSG, static_name: static_name,
                                           method: node.method_name))
        end

        def autocorrect(node)
          keywords = column_keywords(node.method_name)

          return if keywords.size != node.arguments.size

          lambda do |corrector|
            autocorrect_method_name(corrector, node)
            autocorrect_argument_keywords(corrector, node, keywords)
          end
        end

        private

        def autocorrect_method_name(corrector, node)
          corrector.replace(node.loc.selector,
                            static_method_name(node.method_name.to_s))
        end

        def autocorrect_argument_keywords(corrector, node, keywords)
          keywords.each.with_index do |keyword, idx|
            corrector.insert_before(node.arguments[idx].loc.expression, keyword)
          end
        end

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
