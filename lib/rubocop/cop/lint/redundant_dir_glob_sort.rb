# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # Sort globbed results by default in Ruby 3.0.
      # This cop checks for redundant `sort` method to `Dir.glob` and `Dir[]`.
      #
      # @safety
      #   This cop is unsafe, in case of having a file and a directory with
      #   identical names, since directory will be loaded before the file, which
      #   will break `exe/files.rb` that rely on `exe.rb` file.
      #
      # @example
      #
      #   # bad
      #   Dir.glob('./lib/**/*.rb').sort.each do |file|
      #   end
      #
      #   Dir['./lib/**/*.rb'].sort.each do |file|
      #   end
      #
      #   # good
      #   Dir.glob('./lib/**/*.rb').each do |file|
      #   end
      #
      #   Dir['./lib/**/*.rb'].each do |file|
      #   end
      #
      class RedundantDirGlobSort < Base
        extend AutoCorrector
        extend TargetRubyVersion

        minimum_target_ruby_version 3.0

        MSG = 'Remove redundant `sort`.'
        RESTRICT_ON_SEND = %i[sort].freeze
        GLOB_METHODS = %i[glob []].freeze

        def on_send(node)
          return unless dir_glob?(node.receiver)
          # `sort` with a comparator block or block-pass changes the order, so it is
          # not redundant with the default sorting performed by `Dir.glob`/`Dir[]`.
          return if sort_with_comparator?(node) || multiple_argument?(node.receiver)

          selector = node.loc.selector

          add_offense(selector) do |corrector|
            corrector.remove(selector)
            corrector.remove(node.loc.dot)
          end
        end

        private

        def dir_glob?(receiver)
          return false unless receiver&.receiver&.const_type?
          return false unless receiver.receiver.short_name == :Dir

          GLOB_METHODS.include?(receiver.method_name)
        end

        def multiple_argument?(glob_method)
          glob_method.arguments.count >= 2 || glob_method.first_argument&.splat_type?
        end

        def sort_with_comparator?(node)
          node.parent&.any_block_type? || node.last_argument&.block_pass_type?
        end
      end
    end
  end
end
