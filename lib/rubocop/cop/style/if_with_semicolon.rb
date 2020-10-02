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

        MSG = 'Do not use if x; Use the ternary operator instead or if else structure.'

        def on_normal_if_unless(node)
          return unless node.else_branch
          return if node.parent&.if_type?

          beginning = node.loc.begin
          return unless beginning&.is?(';')

          add_offense(node) do |corrector|
            corrector.replace(node, correct_to_structure(node))
          end
        end

        private

        def correct_to_structure(node)
          return correct_elsif_structure(node) if node.else_branch.if_type?

          else_code = node.else_branch ? node.else_branch.source : 'nil'

          "#{node.condition.source} ? #{node.if_branch.source} : #{else_code}"
        end

        def correct_elsif_structure(node)
          <<~RUBY.chop
            if #{node.condition.source}
              #{node.if_branch.source}
            #{build_second_condition_structure(node.else_branch).chop}
            end
          RUBY
        end

        def build_second_condition_structure(second_condition)
          result = <<~RUBY
            elsif #{second_condition.condition.source}
              #{second_condition.if_branch.source}
          RUBY
          if second_condition.else_branch
            result += if second_condition.else_branch.if_type?
                        build_second_condition_structure(second_condition.else_branch)
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
