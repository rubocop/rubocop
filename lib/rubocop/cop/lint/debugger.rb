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
      class Debugger < Base
        MSG = 'Remove debugger entry point `%<source>s`.'

        RESTRICT_ON_SEND = %i[
          debugger byebug remote_byebug pry remote_pry pry_remote console rescue
          save_and_open_page save_and_open_screenshot save_screenshot irb
        ].freeze

        def_node_matcher :kernel?, <<~PATTERN
          {
            (const nil? :Kernel)
            (const (cbase) :Kernel)
          }
        PATTERN

        def_node_matcher :debugger_call?, <<~PATTERN
          {(send {nil? #kernel?} {:debugger :byebug :remote_byebug} ...)
           (send (send {#kernel? nil?} :binding)
             {:pry :remote_pry :pry_remote :console} ...)
           (send (const {nil? (cbase)} :Pry) :rescue ...)
           (send nil? {:save_and_open_page
                      :save_and_open_screenshot
                      :save_screenshot} ...)}
        PATTERN

        def_node_matcher :binding_irb_call?, <<~PATTERN
          (send (send {#kernel? nil?} :binding) :irb ...)
        PATTERN

        def on_send(node)
          return unless debugger_call?(node) || binding_irb?(node)

          add_offense(node)
        end

        private

        def message(node)
          format(MSG, source: node.source)
        end

        def binding_irb?(node)
          binding_irb_call?(node)
        end
      end
    end
  end
end
