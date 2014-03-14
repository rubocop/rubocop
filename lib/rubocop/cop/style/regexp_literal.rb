# encoding: utf-8

module Rubocop
  module Cop
    module Style
      # This cop checks for regexp literals and reports offenses based
      # on how many escaped slashes there are in the regexp and on the
      # value of the configuration parameter MaxSlashes.
      class RegexpLiteral < Cop
        def on_regexp(node)
          string_parts = node.children.select { |child| child.type == :str }
          total_string = string_parts.map { |s| s.loc.expression.source }.join
          slashes = total_string.count('/')
          if node.loc.begin.is?('/')
            if slashes > max_slashes
              add_offense(node, :expression, error_message('')) do
                self.slash_count_in_slashes_regexp = slashes
              end
            end
          elsif slashes <= max_slashes
            add_offense(node, :expression, error_message('only ')) do
              self.slash_count_in_percent_r_regexp = slashes
            end
          end
        end

        private

        def max_slashes
          m = cop_config['MaxSlashes']
          unless m.is_a?(Fixnum) && m >= 0
            fail "Illegal value for MaxSlashes: #{m}"
          end
          m
        end

        # MaxSlashes must be set equal to the highest number of slashes used
        # within // to avoid reports.
        def slash_count_in_slashes_regexp=(value)
          configure_slashes(value) { |current| [current, value].max }
        end

        # MaxSlashes must be set one less than the highest number of slashes
        # used within %r{} to avoid reports.
        def slash_count_in_percent_r_regexp=(value)
          configure_slashes(value - 1) { |current| [current, value - 1].min }
        end

        def configure_slashes(value)
          cfg = self.config_to_allow_offenses ||= {}
          return if cfg.key?('Enabled')

          if cfg['MaxSlashes']
            value = yield cfg['MaxSlashes']
            if cfg['MaxSlashes'] > max_slashes && value < max_slashes ||
                cfg['MaxSlashes'] < max_slashes && value > max_slashes
              # We can't both increase and decrease MaxSlashes to avoid
              # reports. This means that the only option is to disable the cop.
              cfg = self.config_to_allow_offenses = { 'Enabled' => false }
              return
            end
          end

          if value >= 0
            cfg['MaxSlashes'] = value
          else
            self.config_to_allow_offenses = { 'Enabled' => false }
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
