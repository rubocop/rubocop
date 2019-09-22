# frozen_string_literal: true

module RuboCop
  module Cop
    module Migration
      # Check that cop names in rubocop:disable comments are given with
      # department name.
      class DepartmentName < Cop
        include RangeHelp

        MSG = 'Department name is missing.'

        def investigate(processed_source)
          processed_source.each_comment do |comment|
            next if comment.text !~ /\A(# *rubocop:((dis|en)able|todo) +)(.*)/

            offset = Regexp.last_match(1).length
            Regexp.last_match(4).scan(%r{[\w/]+|\W+}) do |name|
              check_cop_name(name, comment, offset)
              offset += name.length
            end
          end
        end

        def autocorrect(range)
          shall_warn = false
          qualified_cop_name = Cop.registry.qualified_cop_name(range.source,
                                                               nil, shall_warn)
          ->(corrector) { corrector.replace(range, qualified_cop_name) }
        end

        private

        def check_cop_name(name, comment, offset)
          return if name !~ /^[A-Z]/ || name =~ %r{/}

          start = comment.location.expression.begin_pos + offset
          range = range_between(start, start + name.length)
          add_offense(range, location: range)
        end
      end
    end
  end
end
