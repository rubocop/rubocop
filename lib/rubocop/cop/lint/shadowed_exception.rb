# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop checks for a rescued exception that get shadowed by a
      # less specific exception being rescued before a more specific
      # exception is rescued.
      #
      # @example
      # # bad
      # begin
      #   something
      # rescue Exception
      #   handle_exception
      # rescue StandardError
      #   handle_standard_error
      # end
      #
      # #good
      # begin
      #   something
      # rescue StandardError
      #   handle_standard_error
      # rescue Exception
      #   handle_exception
      # end
      class ShadowedException < Cop
        MSG = 'Do not shadow rescued Exceptions'.freeze

        def on_rescue(node)
          return if rescue_modifier?(node)
          _body, *rescues, _else = *node
          rescued_groups = rescues.each_with_object([]) do |group, exceptions|
            rescue_group, = *group

            exceptions << evaluate_exceptions(rescue_group)
          end

          rescue_group_rescues_multiple_levels = rescued_groups.any? do |group|
            contains_multiple_levels_of_exceptions?(group)
          end

          return if !rescue_group_rescues_multiple_levels &&
                    rescued_groups == sort_rescued_groups(rescued_groups)

          add_offense(node, offense_range(node, rescues))
        end

        private

        def offense_range(node, rescues)
          first_rescue = rescues.first
          last_rescue = rescues.last
          last_exceptions, = *last_rescue
          # last_rescue clause may not specify exception class
          end_pos = if last_exceptions
                      last_exceptions.loc.expression.end_pos
                    else
                      last_rescue.loc.keyword.end_pos
                    end
          Parser::Source::Range.new(node.loc.expression.source_buffer,
                                    first_rescue.loc.expression.begin_pos,
                                    end_pos)
        end

        def rescue_modifier?(node)
          node && node.rescue_type? &&
            (node.parent.nil? || !(node.parent.kwbegin_type? ||
             node.parent.ensure_type?))
        end

        def contains_multiple_levels_of_exceptions?(group)
          if group.size > 1 && group.include?(Exception)
            # Treat `Exception` as the highest level exception unless `nil` was
            # also rescued
            return !(group.size == 2 && group.include?(NilClass))
          end

          group.any? do |exception|
            higher_exception = false
            group.each_with_index do |_e, i|
              higher_exception ||= begin
                                     if group[i].nil? || exception.nil?
                                       false
                                     else
                                       group[i] < exception
                                     end
                                   end
            end

            higher_exception
          end
        end

        def evaluate_exceptions(rescue_group)
          if rescue_group
            rescued_exceptions = rescued_exceptions(rescue_group)
            rescued_exceptions.each_with_object([]) do |exception, converted|
              begin
                converted << instance_eval(exception, __FILE__, __LINE__)
              rescue StandardError, ScriptError
                converted << nil
              end
            end
          else
            # treat an empty `rescue` as `rescue StandardError`
            [StandardError]
          end
        end

        def sort_rescued_groups(groups)
          groups.sort do |x, y|
            if x.include?(Exception)
              1
            elsif y.include?(Exception)
              -1
            elsif x.none? || y.none?
              # do not change the order if a group is empty or only contains
              # `nil`s
              0
            else
              x <=> y || 0
            end
          end
        end

        # @param [RuboCop::Node] rescue_group is a node of array_type
        def rescued_exceptions(rescue_group)
          klasses = *rescue_group
          klasses.map do |klass|
            # `rescue nil` is valid syntax in all versions of Ruby. In Ruby
            # 1.9.3, it effectively disables the `rescue`. In versions
            # after 1.9.3, a `TypeError` is thrown when the statement is
            # rescued. In order to account for this, we convert `nil` to
            # `NilClass`.
            next 'NilClass' if klass.nil_type?
            next unless klass.const_type?
            klass.source
          end.compact
        end
      end
    end
  end
end
