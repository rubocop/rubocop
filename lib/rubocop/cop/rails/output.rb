# encoding: utf-8

module Rubocop
  module Cop
    module Rails
      # This cop checks for the use of output calls like puts and print
      class Output < Cop
        MSG = 'Do not write to stdout. Use Rails\' logger if you want to log.'

        BLACKLIST = [:puts,
                     :print,
                     :p,
                     :pp,
                     :pretty_print]

        def on_send(node)
          receiver, method_name, *_args = *node

          if receiver.nil? && BLACKLIST.include?(method_name)
            add_offense(node, :selector)
          end
        end
      end
    end
  end
end
