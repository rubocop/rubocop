# frozen_string_literal: true

module RuboCop
  module Cop
    module Migration
      # Check that cop names in rubocop:disable comments are given with
      # department name.
      class DepartmentName < Cop
        include RangeHelp

        MSG = 'Department name is missing.'

        DISABLE_COMMENT_FORMAT =
          /\A(# *rubocop *: *((dis|en)able|todo) +)(.*)/.freeze

        # The token that makes up a disable comment.
        # The token used after `# rubocop: disable` are `A-z`, `/`, and `,`.
        # Also `A-z` includes `all`.
        DISABLING_COPS_CONTENT_TOKEN = %r{[A-z/,]+}.freeze

        def investigate(processed_source)
          processed_source.each_comment do |comment|
            next if comment.text !~ DISABLE_COMMENT_FORMAT

            offset = Regexp.last_match(1).length
            Regexp.last_match(4).scan(%r{[\w/]+|\W+}) do |name|
              break unless valid_content_token?(name.strip)

              check_cop_name(name, comment, offset)

              offset += name.length
            end
          end
        end

        def autocorrect(range)
          shall_warn = false
          cop_name = range.source
          qualified_cop_name = Cop.registry.qualified_cop_name(cop_name,
                                                               nil, shall_warn)
          unless qualified_cop_name.include?('/')
            qualified_cop_name = qualified_legacy_cop_name(cop_name)
          end

          ->(corrector) { corrector.replace(range, qualified_cop_name) }
        end

        private

        def check_cop_name(name, comment, offset)
          return if name !~ /^[A-Z]/ || name =~ %r{/}

          start = comment.location.expression.begin_pos + offset
          range = range_between(start, start + name.length)
          add_offense(range, location: range)
        end

        def valid_content_token?(content_token)
          !DISABLING_COPS_CONTENT_TOKEN.match(content_token).nil?
        end

        def qualified_legacy_cop_name(cop_name)
          legacy_cop_names = RuboCop::ConfigObsoletion::OBSOLETE_COPS.keys

          legacy_cop_names.detect do |legacy_cop_name|
            legacy_cop_name.split('/')[1] == cop_name
          end
        end
      end
    end
  end
end
