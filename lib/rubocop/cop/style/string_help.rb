# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # Checks for uses of double quotes where single quotes would do.
      module StringHelp
        def on_str(node)
          # Constants like __FILE__ are handled as strings,
          # but don't respond to begin.
          return unless node.loc.respond_to?(:begin) && node.loc.begin
          return if part_of_ignored_node?(node)

          convention(node, :expression) if offence?(node)
        end

        def on_dstr(node)
          ignore_node(node)
        end

        def on_regexp(node)
          ignore_node(node)
        end
      end
    end
  end
end
