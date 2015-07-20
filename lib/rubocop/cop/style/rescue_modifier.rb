# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # This cop checks for uses of rescue in its modifier form.
      class RescueModifier < Cop
        MSG = 'Avoid using `rescue` in its modifier form.'

        def investigate(processed_source)
          processed_source.tokens.each do |t|
            next unless t.type == :kRESCUE_MOD
            add_offense(nil, t.pos)
          end
        end
      end
    end
  end
end
