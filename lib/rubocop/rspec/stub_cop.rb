# frozen_string_literal: true

module RuboCop
  module RSpec
    # Mixin for `stub_cop`
    #
    # This mixin makes it easier to define cops that don't exist.
    #
    # @example Usage
    #
    #     before do
    #       stub_cop('RSpec/AllYourSpecsAreWrong')
    #       stub_cop('RSpec/AndThatsWhy') do
    #         def on_block(node)
    #           add_offense(node)
    #         end
    #       end
    #     end
    #
    # NOTE: stubbing real cops is a criminal offence!
    module StubCop
      def stub_cop(class_name, &block)
        cop_class = Class.new(RuboCop::Cop::Cop, &block)
        cop_class.define_singleton_method(:name) { class_name }
        # OR
        # cop_class.instance_eval <<~RUBY, __FILE__, __LINE__ + 1
        #   def name
        #     :"#{class_name}
        #   end
        # RUBY
        # if you're afraid of closures or something
        stub_const(class_name, cop_class)
      end
    end
  end
end
