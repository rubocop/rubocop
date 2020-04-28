# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # `Dir[...]` and `Dir.glob(...)` do not make any guarantees about
      # the order in which files are returned. The final order is
      # determined by the operating system and file system.
      # This means that using them in cases where the order matters,
      # such as requiring files, can lead to intermittent failures
      # that are hard to debug. To ensure this doesn't happen,
      # always sort the list.
      #
      # @example
      #
      #   # bad
      #   Dir["./lib/**/*.rb"].each do |file|
      #     require file
      #   end
      #
      #   # good
      #   Dir["./lib/**/*.rb"].sort.each do |file|
      #     require file
      #   end
      #
      # @example
      #
      #   # bad
      #   Dir.glob(Rails.root.join(__dir__, 'test', '*.rb')) do |file|
      #     require file
      #   end
      #
      #   # good
      #   Dir.glob(Rails.root.join(__dir__, 'test', '*.rb')).sort.each do |file|
      #     require file
      #   end
      #
      class NonDeterministicRequireOrder < Cop
        MSG = 'Sort files before requiring them.'

        def on_block(node)
          return unless node.body
          return unless unsorted_dir_loop?(node.send_node)

          loop_variable(node.arguments) do |var_name|
            return unless var_is_required?(node.body, var_name)

            add_offense(node.send_node)
          end
        end

        def autocorrect(node)
          if unsorted_dir_block?(node)
            lambda do |corrector|
              corrector.replace(node, "#{node.source}.sort.each")
            end
          else
            lambda do |corrector|
              source = node.receiver.source
              corrector.replace(node, "#{source}.sort.each")
            end
          end
        end

        private

        def unsorted_dir_loop?(node)
          unsorted_dir_block?(node) || unsorted_dir_each?(node)
        end

        def_node_matcher :unsorted_dir_block?, <<~PATTERN
          (send (const nil? :Dir) :glob ...)
        PATTERN

        def_node_matcher :unsorted_dir_each?, <<~PATTERN
          (send (send (const nil? :Dir) {:[] :glob} ...) :each)
        PATTERN

        def_node_matcher :loop_variable, <<~PATTERN
          (args (arg $_))
        PATTERN

        def_node_search :var_is_required?, <<~PATTERN
          (send nil? :require (lvar %1))
        PATTERN
      end
    end
  end
end
