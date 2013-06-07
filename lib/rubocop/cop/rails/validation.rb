module Rubocop
  module Cop
    module Rails
      class Validation < Cop
        MSG = 'Use the new "sexy" validations (validates ...).'

        BLACKLIST = [:validates_acceptance_of,
                     :validates_confirmation_of,
                     :validates_exclusion_of,
                     :validates_format_of,
                     :validates_inclusion_of,
                     :validates_length_of,
                     :validates_numericality_of,
                     :validates_presence_of,
                     :validates_size_of]

        def self.rails?
          true
        end

        def on_send(node)
          receiver, method_name, *_args = *node

          if receiver.nil? && BLACKLIST.include?(method_name)
            add_offence(:convention, node.loc.selector, MSG)
          end
        end
      end
    end
  end
end
