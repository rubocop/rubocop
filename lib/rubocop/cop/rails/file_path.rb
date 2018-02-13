# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # This cop is used to identify usages of file path joining process
      # to use `Rails.root.join` clause. This is to avoid bugs on operating
      # system that don't use '/' as the path separator.
      #
      # @example
      #  # bad
      #  Rails.root.join('app/models/goober')
      #  File.join(Rails.root, 'app/models/goober')
      #  "#{Rails.root}/app/models/goober"
      #
      #  # good
      #  Rails.root.join('app', 'models', 'goober')
      class FilePath < Cop
        include RangeHelp

        MSG = 'Please use `Rails.root.join(\'path\', \'to\')` instead.'.freeze

        def_node_matcher :file_join_nodes?, <<-PATTERN
          (send (const nil? :File) :join ...)
        PATTERN

        def_node_search :rails_root_nodes?, <<-PATTERN
          (send (const nil? :Rails) :root)
        PATTERN

        def_node_matcher :rails_root_join_nodes?, <<-PATTERN
          (send (send (const nil? :Rails) :root) :join ...)
        PATTERN

        def on_dstr(node)
          unless node.children.last.source.start_with?('.')
            return unless rails_root_nodes?(node)
            return unless node.children.last.source.include?(File::SEPARATOR)
          end

          register_offense(node)
        end

        def on_send(node)
          check_for_file_join_with_rails_root(node)
          check_for_rails_root_join_with_slash_separated_path(node)
        end

        private

        def check_for_file_join_with_rails_root(node)
          return unless file_join_nodes?(node)
          return unless node.arguments.any? { |e| rails_root_nodes?(e) }

          register_offense(node)
        end

        def check_for_rails_root_join_with_slash_separated_path(node)
          return unless rails_root_nodes?(node)
          return unless rails_root_join_nodes?(node)
          return unless node.arguments.any? { |arg| string_with_slash?(arg) }

          register_offense(node)
        end

        def string_with_slash?(node)
          node.str_type? && node.source =~ %r{/}
        end

        def register_offense(node)
          line_range = node.loc.column...node.loc.last_column
          source_range = source_range(processed_source.buffer, node.first_line,
                                      line_range)
          add_offense(node, location: source_range)
        end
      end
    end
  end
end
