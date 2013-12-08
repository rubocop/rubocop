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
          return if matches_blacklist?(processed_source)
          receiver, method_name, *_args = *node

          if receiver.nil? && BLACKLIST.include?(method_name)
            add_offence(node, :selector)
          end
        end

        def matches_blacklist?(source)
          ignore_paths.any? { |regex| source.buffer.name =~ /#{regex}/ }
        end

        def ignore_paths
          cop_config['Ignore']
        end
      end
    end
  end
end
