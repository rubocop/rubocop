# frozen_string_literal: true

module RuboCop
  module Cop
    module Lint
      # This cop checks for calls to debugger or pry.
      #
      # @example
      #
      #   # bad (ok during development)
      #
      #   # using pry
      #   def some_method
      #     binding.pry
      #     do_something
      #   end
      #
      # @example
      #
      #   # bad (ok during development)
      #
      #   # using byebug
      #   def some_method
      #     byebug
      #     do_something
      #   end
      #
      # @example
      #
      #   # good
      #
      #   def some_method
      #     do_something
      #   end
      class Debugger < Cop
        MSG = 'Remove debugger entry point `%s`.'.freeze

        def_node_matcher :debugger_call?, <<-PATTERN
          {(send nil {:debugger :byebug} ...)
           (send (send nil :binding)
             {:pry :remote_pry :pry_remote} ...)
           (send (const nil :Pry) :rescue ...)
           (send nil {:save_and_open_page
                      :save_and_open_screenshot
                      :save_screenshot} ...)}
        PATTERN

        def_node_matcher :binding_irb_call?, <<-PATTERN
          (send (send nil :binding) :irb ...)
        PATTERN

        def_node_matcher :pry_rescue?, '(send (const nil :Pry) :rescue ...)'

        def on_send(node)
          return unless debugger_call?(node) || binding_irb?(node)

          add_offense(node)
        end

        private

        def message(node)
          format(MSG, node.source)
        end

        def binding_irb?(node)
          target_ruby_version >= 2.4 && binding_irb_call?(node)
        end
      end
    end
  end
end
