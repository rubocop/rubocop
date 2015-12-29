# encoding: utf-8

module RuboCop
  module Cop
    module Lint
      # This cop checks for non-local exit from iterator, without return value.
      # It warns only when satisfies all of these: `return` doesn't have return
      # value, the block is preceded by a method chain, the block has arguments,
      # and the method which receives the block is not `define_method`.
      #
      # @example
      #
      #   class ItemApi
      #     rescue_from ValidationError do |e| # non-iteration block with arg
      #       return message: 'validation error' unless e.errors # allowd
      #       error_array = e.errors.map do |error| # block with method chain
      #         return if error.suppress? # warned
      #         return "#{error.param}: invalid" unless error.message # allowed
      #         "#{error.param}: #{error.message}"
      #       end
      #       message: 'validation error', errors: error_array
      #     end
      #
      #     def update_items
      #       transaction do # block without arguments
      #         return unless update_necessary? # allowed
      #         find_each do |item| # block without method chain
      #           return if item.stock == 0 # false-negative...
      #           item.update!(foobar: true)
      #         end
      #       end
      #     end
      #   end
      #
      class NonLocalExitFromIterator < Cop
        MSG = 'Non-local exit from iterator, without return value. ' \
          '`next`, `break`, `Array#find`, `Array#any?`, etc. is preferred.'

        def on_return(return_node)
          return if return_value?(return_node)
          return_node.each_ancestor(:block) do |block_node|
            send_node, args_node, _body_node = *block_node

            # `return` does not exit to outside of lambda block, this is safe.
            break if block_node.lambda?
            # if a proc is passed to `Module#define_method`, `return` will not
            # cause a non-local exit error
            break if define_method?(send_node)

            next if args_node.children.empty?
            if chained_send?(send_node)
              add_offense(return_node, :keyword)
              break
            end
          end
        end

        def return_value?(return_node)
          !return_node.children.empty?
        end

        def chained_send?(send_node)
          receiver_node, _selector_node = *send_node
          !receiver_node.nil?
        end

        def define_method?(send_node)
          _receiver, selector = *send_node
          selector == :define_method
        end
      end
    end
  end
end
