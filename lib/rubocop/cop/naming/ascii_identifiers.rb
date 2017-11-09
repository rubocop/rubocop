# frozen_string_literal: true

module RuboCop
  module Cop
    module Naming
      # rubocop:disable Style/AsciiComments
      # This cop checks for non-ascii characters in identifier names.
      #
      # @example
      #   # bad
      #   def καλημερα # Greek alphabet (non-ascii)
      #   end
      #
      #   # bad
      #   def こんにちはと言う # Japanese character (non-ascii)
      #   end
      #
      #   # bad
      #   def hello_🍣 # Emoji (non-ascii)
      #   end
      #
      #   # good
      #   def say_hello
      #   end
      #
      #   # bad
      #   신장 = 10 # Hangul character (non-ascii)
      #
      #   # good
      #   height = 10
      #
      #   # bad
      #   params[:عرض_gteq] # Arabic character (non-ascii)
      #
      #   # good
      #   params[:width_gteq]
      #
      # rubocop:enable Style/AsciiComments
      class AsciiIdentifiers < Cop
        MSG = 'Use only ascii symbols in identifiers.'.freeze

        def investigate(processed_source)
          processed_source.tokens.each do |token|
            next unless token.type == :tIDENTIFIER && !token.text.ascii_only?
            add_offense(token, location: first_offense_range(token))
          end
        end

        private

        def first_offense_range(identifier)
          expression    = identifier.pos
          first_offense = first_non_ascii_chars(identifier.text)

          start_position = expression.begin_pos +
                           identifier.text.index(first_offense)
          end_position   = start_position + first_offense.length

          range_between(start_position, end_position)
        end

        def first_non_ascii_chars(string)
          string.match(/[^[:ascii:]]+/).to_s
        end
      end
    end
  end
end
