# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # This cop is used to identify usages of file path joining process
      # to use `Rails.root.join` clause. It is used to add uniformity when
      # joining paths.
      #
      # @example EnforcedStyle: arguments (default)
      #   # bad
      #   Rails.root.join('app/models/goober')
      #   File.join(Rails.root, 'app/models/goober')
      #   "#{Rails.root}/app/models/goober"
      #
      #   # good
      #   Rails.root.join('app', 'models', 'goober')
      #
      # @example EnforcedStyle: slashes
      #   # bad
      #   Rails.root.join('app', 'models', 'goober')
      #   File.join(Rails.root, 'app/models/goober')
      #   "#{Rails.root}/app/models/goober"
      #
      #   # good
      #   Rails.root.join('app/models/goober')
      #
      class FilePath < Cop
        include ConfigurableEnforcedStyle
        include RangeHelp

        MSG_SLASHES = 'Please use `Rails.root.join(\'path/to\')` ' \
                      'instead.'
        MSG_ARGUMENTS = 'Please use `Rails.root.join(\'path\', \'to\')` ' \
                        'instead.'

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
          return unless rails_root_nodes?(node)
          return unless node.children.last.source.start_with?('.') ||
                        node.children.last.source.include?(File::SEPARATOR)

          register_offense(node)
        end

        def on_send(node)
          check_for_file_join_with_rails_root(node)
          check_for_rails_root_join_with_slash_separated_path(node)
          check_for_rails_root_join_with_string_arguments(node)
        end

        private

        def check_for_file_join_with_rails_root(node)
          return unless file_join_nodes?(node)
          return unless node.arguments.any? { |e| rails_root_nodes?(e) }

          register_offense(node)
        end

        def check_for_rails_root_join_with_string_arguments(node)
          return unless style == :slashes
          return unless rails_root_nodes?(node)
          return unless rails_root_join_nodes?(node)
          return unless node.arguments.size > 1
          return unless node.arguments.all?(&:str_type?)

          register_offense(node)
        end

        def check_for_rails_root_join_with_slash_separated_path(node)
          return unless style == :arguments
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

        def message(_node)
          format(style == :arguments ? MSG_ARGUMENTS : MSG_SLASHES)
        end
      end
    end
  end
end
