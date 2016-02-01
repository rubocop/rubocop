# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # Look for things like params.try(:something).try(something_else)
      # Ruby 2.3.x introduces the safe navigation operator which is much faster
      class Try < Cop
        MSG = 'prefer safe navigation operator'.freeze

        def on_send(node)
          _receiver, method_name, *_args = *node

          # TODO: not too sure about this check - maybe this should be done at
          # the top level in the requires.
          if method_name == :try! && RUBY_VERSION.match(/^2.3/)
            add_offense(node, :selector)
          end
        end
      end
    end
  end
end
