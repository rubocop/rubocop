# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks for `require` calls that can be replaced with `require_relative`.
      #
      # When loading files within a gem or application, `require_relative` is
      # preferred over `require` with a path built from `__dir__` or
      # `__FILE__`, as it is more explicit and avoids RubyGems path scanning
      # overhead.
      #
      # @example
      #   # bad
      #   require "#{__dir__}/foo"
      #   require "#{__dir__}/foo/bar"
      #
      #   # good
      #   require_relative 'foo'
      #   require_relative 'foo/bar'
      #
      #   # bad
      #   require File.expand_path('foo', __dir__)
      #   require File.expand_path('../foo', __dir__)
      #
      #   # good
      #   require_relative 'foo'
      #   require_relative '../foo'
      #
      class RequireRelative < Base
        extend AutoCorrector

        MSG = 'Use `require_relative` instead of `require` for paths relative to the current file.'
        RESTRICT_ON_SEND = %i[require].freeze

        # @!method require_with_dir_interpolation(node)
        def_node_matcher :require_with_dir_interpolation, <<~PATTERN
          (send nil? :require
            (dstr
              (begin (send nil? :__dir__))
              $(str _)))
        PATTERN

        # @!method require_with_expand_path_and_dir(node)
        def_node_matcher :require_with_expand_path_and_dir, <<~PATTERN
          (send nil? :require
            (send
              (const {nil? cbase} :File) :expand_path
              $(str _)
              (send nil? :__dir__)))
        PATTERN

        def on_send(node)
          if (path_node = require_with_dir_interpolation(node))
            handle_dir_interpolation(node, path_node)
          elsif (path_node = require_with_expand_path_and_dir(node))
            handle_expand_path_with_dir(node, path_node)
          end
        end

        private

        def handle_dir_interpolation(node, path_node)
          path = path_node.value
          # Only flag when the string starts with '/' (the separator between __dir__ and path)
          return unless path.start_with?('/')

          relative_path = path.delete_prefix('/')
          return if relative_path.empty?

          add_offense(node) do |corrector|
            corrector.replace(node, "require_relative '#{relative_path}'")
          end
        end

        def handle_expand_path_with_dir(node, path_node)
          path = path_node.value

          add_offense(node) do |corrector|
            corrector.replace(node, "require_relative '#{path}'")
          end
        end
      end
    end
  end
end
