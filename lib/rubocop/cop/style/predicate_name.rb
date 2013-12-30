# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop makes sure that predicates are named properly.
      #
      # @example
      #   # bad
      #   def is_even?(value) ...
      #
      #   # good
      #   def even?(value)
      #
      #   # bad
      #   def has_value? ...
      #
      #   # good
      #   def value? ...
      class PredicateName < Cop
        include CheckMethods

        private

        def check(node, method_name, args, _body)
          prefix_blacklist.each do |prefix|
            if method_name.to_s.start_with?(prefix)
              add_offence(node, :name,
                          message(method_name.to_s, prefix))
            end
          end
        end

        def message(method_name, prefix)
          new_name = method_name.sub(prefix, '')
          new_name << '?' unless method_name.end_with?('?')
          "Rename #{method_name} to #{new_name}."
        end

        def prefix_blacklist
          cop_config['NamePrefixBlacklist']
        end
      end
    end
  end
end
