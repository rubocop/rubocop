# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks for uses of semicolon in if statements.
      #
      # @example
      #
      #   # bad
      #   result = if some_condition; something else another_thing end
      #
      #   # good
      #   result = some_condition ? something : another_thing
      #
      class IfWithSemicolon < Base
        include OnNormalIfUnless
        extend AutoCorrector

        MSG_IF_ELSE = 'Do not use `if %<expr>s;` - use `if/else` instead.'
        MSG_NEWLINE = 'Do not use `if %<expr>s;` - use a newline instead.'
        MSG_TERNARY = 'Do not use `if %<expr>s;` - use a ternary operator instead.'

        def on_normal_if_unless(node)
          return if node.parent&.if_type?

          beginning = node.loc.begin
          return unless beginning&.is?(';')

          message = message(node)

          add_offense(node, message: message) do |corrector|
            if node.if_branch&.begin_type?
              corrector.replace(node.loc.begin, "\n")
            else
              corrector.replace(node, replacement(node))
            end
          end
        end

        private

        def message(node)
          template = if node.if_branch&.begin_type?
                       MSG_NEWLINE
                     elsif node.else_branch&.if_type?
                       MSG_IF_ELSE
                     else
                       MSG_TERNARY
                     end

          format(template, expr: node.condition.source)
        end

        def replacement(node)
          return correct_elsif(node) if node.else_branch&.if_type?

          then_code = node.if_branch ? node.if_branch.source : 'nil'
          else_code = node.else_branch ? node.else_branch.source : 'nil'

          "#{node.condition.source} ? #{then_code} : #{else_code}"
        end

        def correct_elsif(node)
          <<~RUBY.chop
            if #{node.condition.source}
              #{node.if_branch&.source}
            #{build_else_branch(node.else_branch).chop}
            end
          RUBY
        end

        def build_else_branch(second_condition)
          result = <<~RUBY
            elsif #{second_condition.condition.source}
              #{second_condition.if_branch&.source}
          RUBY

          if second_condition.else_branch
            result += if second_condition.else_branch.if_type?
                        build_else_branch(second_condition.else_branch)
                      else
                        <<~RUBY
                          else
                            #{second_condition.else_branch.source}
                        RUBY
                      end
          end

          result
        end
      end
    end
  end
end
