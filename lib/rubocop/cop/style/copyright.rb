# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # Check that a copyright notice was given in each source file.
      #
      # The default regexp for an acceptable copyright notice can be found in
      # config/default.yml.  The default can be changed as follows:
      #
      #     Style/Copyright:
      #       Notice: '^Copyright (\(c\) )?2\d{3} Acme Inc'
      #
      # This regex string is treated as an unanchored regex.  For each file
      # that RuboCop scans, a comment that matches this regex must be found or
      # an offense is reported.
      #
      class Copyright < Cop
        include RangeHelp

        MSG = 'Include a copyright notice matching /%<notice>s/ before ' \
              'any code.'.freeze
        AUTOCORRECT_EMPTY_WARNING = 'An AutocorrectNotice must be defined in' \
                                    'your RuboCop config'.freeze

        def investigate(processed_source)
          return if notice.empty?
          return if notice_found?(processed_source)
          range = source_range(processed_source.buffer, 1, 0)
          add_offense(insert_notice_before(processed_source),
                      location: range, message: format(MSG, notice: notice))
        end

        def autocorrect(token)
          raise Warning, AUTOCORRECT_EMPTY_WARNING if autocorrect_notice.empty?
          regex = Regexp.new(notice)
          unless autocorrect_notice =~ regex
            raise Warning, "AutocorrectNotice '#{autocorrect_notice}' must " \
                           "match Notice /#{notice}/"
          end

          lambda do |corrector|
            range = token.nil? ? range_between(0, 0) : token.pos
            corrector.insert_before(range, "#{autocorrect_notice}\n")
          end
        end

        private

        def notice
          cop_config['Notice']
        end

        def autocorrect_notice
          cop_config['AutocorrectNotice']
        end

        def insert_notice_before(processed_source)
          token_index = 0
          token_index += 1 if shebang_token?(processed_source, token_index)
          token_index += 1 if encoding_token?(processed_source, token_index)
          processed_source.tokens[token_index]
        end

        def shebang_token?(processed_source, token_index)
          return false if token_index >= processed_source.tokens.size
          token = processed_source.tokens[token_index]
          token.comment? && token.text =~ /^#!.*$/
        end

        def encoding_token?(processed_source, token_index)
          return false if token_index >= processed_source.tokens.size
          token = processed_source.tokens[token_index]
          token.comment? && token.text =~ /^#.*coding\s?[:=]\s?(?:UTF|utf)-8/
        end

        def notice_found?(processed_source)
          notice_found = false
          notice_regexp = Regexp.new(notice)
          processed_source.each_token do |token|
            break unless token.comment?
            notice_found = !(token.text =~ notice_regexp).nil?
            break if notice_found
          end
          notice_found
        end
      end
    end
  end
end
