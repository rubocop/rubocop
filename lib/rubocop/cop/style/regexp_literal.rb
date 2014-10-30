# encoding: utf-8

module RuboCop
  module Cop
    module Style
      # This cop checks for regexp literals and reports offenses based
      # on how many escaped slashes there are in the regexp and on the
      # value of the configuration parameter MaxSlashes.
      class RegexpLiteral < Cop
        class << self
          attr_accessor :slash_count
        end

        def on_regexp(node)
          string_parts = node.children.select { |child| child.type == :str }
          total_string = string_parts.map { |s| s.loc.expression.source }.join
          slashes = total_string.count('/')
          delimiter_start = node.loc.begin.source[0]

          if delimiter_start == '/'
            if slashes > max_slashes
              add_offense(node, :expression, error_message(''))
            end
          elsif slashes <= max_slashes
            add_offense(node, :expression, error_message('only '))
          end

          configure_max(delimiter_start, slashes) if @options[:auto_gen_config]
        end

        private

        def max_slashes
          m = cop_config['MaxSlashes']
          unless m.is_a?(Fixnum) && m >= 0
            fail "Illegal value for MaxSlashes: #{m}"
          end
          m
        end

        def configure_max(delimiter_start, value)
          self.class.slash_count ||= {
            '/' => Set.new([0]),
            '%' => Set.new([100_000])
          }

          self.class.slash_count[delimiter_start].add(value)

          # To avoid reports, MaxSlashes must be set equal to the highest
          # number of slashes used within //, and also one less than the
          # highest number of slashes used within %r{}. If no value can satisfy
          # both requirements, just disable.
          max = self.class.slash_count['/'].max
          min = self.class.slash_count['%'].min

          self.config_to_allow_offenses = calculate_config(max, min)
        end

        def calculate_config(max, min)
          if max > max_slashes
            if max < min
              { 'MaxSlashes' => max }
            else
              { 'Enabled' => false }
            end
          elsif min < max_slashes + 1
            if max < min
              { 'MaxSlashes' => min - 1 }
            else
              { 'Enabled' => false }
            end
          end
        end

        def error_message(word)
          format('Use %%r %sfor regular expressions matching more ' \
                 "than %d '/' character%s.",
                 word,
                 max_slashes,
                 max_slashes == 1 ? '' : 's')
        end
      end
    end
  end
end
