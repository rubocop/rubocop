# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks for braces in method calls with hash parameters.
      class BracesAroundHashParameters < Cop
        def on_send(node)
          _receiver, method_name, *args = *node

          # discard attr writer methods.
          return if method_name.to_s.end_with?('=')
          # discard operator methods
          return if OPERATOR_METHODS.include?(method_name)

          # we care only for the first argument
          arg = args.last
          return unless arg && arg.type == :hash && arg.children.any?

          has_braces = !arg.loc.begin.nil?
          all_hashes = args.length > 1 && args.all? { |a| a.type == :hash }

          if style == :no_braces && has_braces && !all_hashes
            convention(arg,
                       :expression,
                       'Redundant curly braces around a hash parameter.')
          elsif style == :braces && !has_braces
            convention(arg,
                       :expression,
                       'Missing curly braces around a hash parameter.')
          end
        end

        def autocorrect(node)
          @corrections << lambda do |corrector|
            if style == :no_braces
              corrector.remove(node.loc.begin)
              corrector.remove(node.loc.end)
            elsif style == :braces
              corrector.insert_before(node.loc.expression, '{')
              corrector.insert_after(node.loc.expression, '}')
            end
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
