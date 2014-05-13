# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # Do not use should when describing your tests.
      # see: http://betterspecs.org/#should
      #
      # @example
      #   # bad
      #   it 'should find nothing' do
      #   end
      #
      #   # good
      #   it 'finds nothing' do
      #   end
      class Rspec < Cop
        MSG = 'Do not use should when describing your tests.'

        def on_block(node)
          method, _, _ = *node
          _, method_name, *args = *method

          return unless method_name == :it

          arguments = *(args.first)
          message = arguments.first.to_s
          return unless message.start_with?('should')

          add_offense(method, :selector, MSG)
        end
      end
    end
  end
end
