# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Checks for `File.open` without a block, which can leak file descriptors.
      #
      # When `File.open` is called without a block, the caller is responsible
      # for closing the file descriptor. If it is not explicitly closed, it
      # will only be closed when the garbage collector runs, which may lead
      # to resource exhaustion. Using the block form ensures the file is
      # automatically closed when the block exits.
      #
      # @safety
      #   This cop is unsafe because it detects all `File.open` calls without
      #   a block, including intentional uses such as one-shot reads
      #   (`File.open("f").read`) where the file descriptor is closed by the
      #   garbage collector.
      #
      # @example
      #   # bad
      #   f = File.open('file')
      #
      #   # bad
      #   File.open('file').read
      #
      #   # good
      #   File.open('file') do |f|
      #     f.read
      #   end
      #
      #   # good
      #   File.open('file', &:read)
      #
      #   # good - use File.read for one-shot reads
      #   File.read('file')
      #
      class FileOpen < Base
        MSG = '`File.open` without a block may leak a file descriptor; use the block form.'
        RESTRICT_ON_SEND = %i[open].freeze

        # @!method file_open?(node)
        def_node_matcher :file_open?, <<~PATTERN
          (send (const {nil? cbase} :File) :open ...)
        PATTERN

        def on_send(node)
          return unless file_open?(node)
          return if block_form?(node)

          add_offense(node)
        end
        alias on_csend on_send

        private

        def block_form?(node)
          node.block_argument? || node.parent&.block_type?
        end
      end
    end
  end
end
