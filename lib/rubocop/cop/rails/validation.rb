# encoding: utf-8

module Rubocop
  module Cop
    module Rails
      # This cop checks for the use of old-style attribute validation macros.
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
                     :validates_size_of,
                     :validates_uniqueness_of]

        def on_send(node)
          receiver, method_name, *_args = *node

          if receiver.nil? && BLACKLIST.include?(method_name)
            add_offence(node, :selector)
          end
        end
      end
    end
  end
end
