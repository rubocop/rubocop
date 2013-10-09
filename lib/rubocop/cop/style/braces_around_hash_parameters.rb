# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks for braces in method calls with hash parameters.
      class BracesAroundHashParameters < Cop

        def on_send(node)
          _, method_name, *args = *node
          return unless args.length == 1
          return if method_name.to_s.end_with?('=')
          return if OPERATOR_METHODS.include?(method_name)
          arg = args.first
          return unless arg && arg.type == :hash && arg.children.any?
          has_braces = !! arg.loc.begin
          if style == :no_braces && has_braces
            convention(arg,
                       :expression,
                       'Unnecessary braces around a hash parameter.')
          elsif style == :braces && ! has_braces
            convention(arg,
                       :expression,
                       'Missing braces around a hash parameter.')
          end
        end

        private

        def style
          case cop_config['EnforcedStyle']
          when 'braces' then :braces
          when 'no_braces' then :no_braces
          else fail 'Unknown style selected!'
          end
        end
      end
    end
  end
end
