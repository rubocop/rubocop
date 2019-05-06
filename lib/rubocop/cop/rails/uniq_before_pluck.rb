# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # Prefer the use of uniq (or distinct), before pluck instead of after.
      #
      # The use of uniq before pluck is preferred because it executes within
      # the database.
      #
      # This cop has two different enforcement modes. When the EnforcedStyle
      # is conservative (the default) then only calls to pluck on a constant
      # (i.e. a model class) before uniq are added as offenses.
      #
      # When the EnforcedStyle is aggressive then all calls to pluck before
      # uniq are added as offenses. This may lead to false positives as the cop
      # cannot distinguish between calls to pluck on an ActiveRecord::Relation
      # vs a call to pluck on an ActiveRecord::Associations::CollectionProxy.
      #
      # Autocorrect is disabled by default for this cop since it may generate
      # false positives.
      #
      # @example EnforcedStyle: conservative (default)
      #   # bad
      #   Model.pluck(:id).uniq
      #
      #   # good
      #   Model.uniq.pluck(:id)
      #
      # @example EnforcedStyle: aggressive
      #   # bad
      #   # this will return a Relation that pluck is called on
      #   Model.where(cond: true).pluck(:id).uniq
      #
      #   # bad
      #   # an association on an instance will return a CollectionProxy
      #   instance.assoc.pluck(:id).uniq
      #
      #   # bad
      #   Model.pluck(:id).uniq
      #
      #   # good
      #   Model.uniq.pluck(:id)
      #
      class UniqBeforePluck < RuboCop::Cop::Cop
        include ConfigurableEnforcedStyle
        include RangeHelp

        MSG = 'Use `%<method>s` before `pluck`.'
        NEWLINE = "\n"
        PATTERN = '[!^block (send (send %<type>s :pluck ...) ' \
                  '${:uniq :distinct} ...)]'

        def_node_matcher :conservative_node_match,
                         format(PATTERN, type: 'const')

        def_node_matcher :aggressive_node_match,
                         format(PATTERN, type: '_')

        def on_send(node)
          method = if style == :conservative
                     conservative_node_match(node)
                   else
                     aggressive_node_match(node)
                   end

          return unless method

          add_offense(node, location: :selector,
                            message: format(MSG, method: method))
        end

        def autocorrect(node)
          lambda do |corrector|
            method = node.method_name

            corrector.remove(dot_method_with_whitespace(method, node))
            corrector.insert_before(node.receiver.loc.dot.begin, ".#{method}")
          end
        end

        private

        def style_parameter_name
          'EnforcedStyle'
        end

        def dot_method_with_whitespace(method, node)
          range_between(dot_method_begin_pos(method, node),
                        node.loc.selector.end_pos)
        end

        def dot_method_begin_pos(method, node)
          lines = node.source.split(NEWLINE)

          if lines.last.strip == ".#{method}"
            node.source.rindex(NEWLINE)
          else
            node.loc.dot.begin_pos
          end
        end
      end
    end
  end
end
