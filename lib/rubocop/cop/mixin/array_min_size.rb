# frozen_string_literal: true

module RuboCop
  module Cop
    # Handles the `MinSize` configuration option for array-based cops
    # `Style/SymbolArray` and `Style/WordArray`, which check for use of the
    # relevant percent literal syntax such as `%i[...]` and `%w[...]`
    module ArrayMinSize
      # Merge lambdas for parallel --auto-gen-config.
      # When workers see different subsets of files, these lambdas specify
      # how to combine each config option from _config_overrides.
      module ClassMethods
        def config_to_allow_offenses_mergers
          {
            'EnforcedStyle' => ->(_a, _b) { 'percent' },
            'MinSize' => ->(a, b) { [a, b].max }
          }.freeze
        end
      end

      def self.included(base)
        base.extend(ClassMethods)
      end

      private

      def below_array_length?(node)
        node.values.length < min_size_config
      end

      def min_size_config
        cop_config['MinSize']
      end

      def array_style_detected(style, ary_size) # rubocop:todo Metrics/AbcSize, Metrics/MethodLength
        cfg = config_to_allow_offenses
        return if cfg['Enabled'] == false

        largest_brackets = largest_brackets_size(style, ary_size)
        smallest_percent = smallest_percent_size(style, ary_size)

        if cfg['EnforcedStyle'] == style.to_s
          # do nothing
        elsif cfg['EnforcedStyle'].nil?
          cfg['EnforcedStyle'] = style.to_s
        elsif smallest_percent <= largest_brackets
          self.config_to_allow_offenses = { 'Enabled' => false }
          cfg = config_to_allow_offenses
        else
          cfg['EnforcedStyle'] = 'percent'
          cfg['MinSize'] = largest_brackets + 1
        end

        persist_config_overrides(cfg, largest_brackets)
      end

      # Persist a fallback config for parallel merge resolution.
      # When workers see different subsets of files, they may resolve
      # to different styles. This provides the "most permissive" config
      # (percent with a MinSize that accommodates all observed bracket
      # arrays) so the merge can reconstruct the correct result.
      def persist_config_overrides(cfg, largest_brackets)
        return unless largest_brackets > -Float::INFINITY

        cfg.set_metadata(
          '_config_overrides',
          'EnforcedStyle' => 'percent',
          'MinSize' => largest_brackets + 1
        )
      end

      def largest_brackets_size(style, ary_size)
        self.class.largest_brackets ||= -Float::INFINITY

        if style == :brackets && ary_size > self.class.largest_brackets
          self.class.largest_brackets = ary_size
        end

        self.class.largest_brackets
      end

      def smallest_percent_size(style, ary_size)
        @smallest_percent ||= Float::INFINITY

        @smallest_percent = ary_size if style == :percent && ary_size < @smallest_percent

        @smallest_percent
      end
    end
  end
end
