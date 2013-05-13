# encoding: utf-8

module Rubocop
  module Cop
    module Util
      module_function

      def strip_quotes(str)
        if str[0] == '"' || str[0] == "'"
          str[0] = ''
          str[-1] = ''
        else
          # we're dealing with %q or %Q
          str[0, 3] = ''
          str[-1] = ''
        end

        str
      end
    end
  end
end
