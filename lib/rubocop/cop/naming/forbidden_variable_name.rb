# frozen_string_literal: true

module RuboCop
  module Cop
    module Naming
      # This cop makes sur that variables used are not fordidden for use.
      # If a recommended variable is present it will display it.
      #
      # The recommendations are configured in the `Recommendations`
      # of the `Naming/ForbiddenVariableName` cop.
      #
      # @example
      #   # bad
      #   def do_something_with_class(clazz)
      #   end
      #
      #   # bad
      #   classes.map { |clazz| puts clazz.name }
      #
      #   # bad
      #   clazz = Array
      #
      #   # good
      #   def do_something_with_class(klass)
      #   end
      #
      #   # good
      #   classes.map { |klass| puts klass.name }
      #
      #   # good
      #   klass = Array
      class ForbiddenVariableName < Cop
        MSG = 'Use `%<good>s` instead of `%<bad>s`.'.freeze
        MSG_NO_RECOMENDATION = 'Do not use `%<bad>s`.'.freeze

        def on_lvasgn(node)
          name, = *node
          return unless name

          check_name(node, name.to_s.downcase)
        end
        alias on_ivasgn    on_lvasgn
        alias on_cvasgn    on_lvasgn
        alias on_arg       on_lvasgn
        alias on_optarg    on_lvasgn
        alias on_restarg   on_lvasgn
        alias on_kwoptarg  on_lvasgn
        alias on_kwarg     on_lvasgn
        alias on_kwrestarg on_lvasgn
        alias on_blockarg  on_lvasgn

        private

        def check_name(node, name)
          add_offense(node, message: message_for(name)) if invalid_name?(name)
        end

        def message_for(name)
          recommendation = recommendation_for(name)
          return format(MSG_NO_RECOMENDATION, bad: name) unless recommendation

          format(MSG, good: recommendation_for(name), bad: name)
        end

        def recommendations
          @recommendations ||= cop_config.fetch('Recommendations', {})
        end

        def recommendation_for(name)
          recommendations[name]
        end

        def invalid_name?(name)
          recommendations.key?(name)
        end
      end
    end
  end
end
