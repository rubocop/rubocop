# frozen_string_literal: true

# TODO
# - message for file names
# - detect in file path? or basename
# - cleanup code

module RuboCop
  module Cop
    module Naming
      # This cop recommends the use of inclusive language instead of problematic terms.
      #
      # @example FlaggedTerms: { whitelist: { Suggestions: ['allowlist'] } }
      #   # Suggest replacing whitelist with allowlist
      #
      #   # bad
      #   whitelist_users = %w(user1 user1)
      #
      #   # good
      #   allowlist_users = %w(user1 user2)
      #
      # @example FlaggedTerms: { master: { Suggestions: ['main', 'primary', 'leader'] } }
      #   # Suggest replacing master with main, primary, or leader
      #
      #   # bad
      #   master_node = 'node1.example.com'
      #
      #   # good
      #   primary_node = 'node1.example.com'
      #
      # @example FlaggedTerms: { whitelist: { Regexp: !ruby/regexp '/white[-_\s]?list' } }
      #   # Identify problematic terms using a Regexp
      #
      #   # bad
      #   white_list = %w(user1 user2)
      #
      #   # good
      #   allow_list = %w(user1 user2)
      #
      # @example FlaggedTerms: { master: { Allowed: 'master\'?s degree' } }
      #   # Specify allowed uses (regexp supported) of the flagged term.
      #
      #   # bad
      #   # They had a masters
      #
      #   # good
      #   # They had a master's degree
      #
      class InclusiveLanguage < Cop
        include RangeHelp

        EMPTY_ARRAY = [].freeze

        WordLocation = Struct.new(:word, :position)

        def initialize(config = nil, options = nil)
          super
          @flagged_term_hash = {}
          @flagged_terms_regex = nil
          @allowed_regex = nil
          preprocess_flagged_terms
        end

        def investigate(processed_source)
          investigate_lines(processed_source)
          investigate_filepath(processed_source)
        end

        private

        def preprocess_flagged_terms
          allowed_strings = []
          flagged_term_strings = []
          cop_config['FlaggedTerms'].each do |term, term_definition|
            allowed_strings.concat(process_allowed_regex(term_definition['AllowedRegex']))
            regex_string = ensure_regex_string(term_definition['Regex'] || term)
            flagged_term_strings << regex_string

            @flagged_term_hash[Regexp.new(regex_string, Regexp::IGNORECASE)] =
              term_definition.merge('Term' => term,
                                    'SuggestionString' =>
                                      preprocess_suggestions(term_definition['Suggestions']))
          end

          set_regexes(flagged_term_strings, allowed_strings)
        end

        def set_regexes(flagged_term_strings, allowed_strings)
          @flagged_terms_regex = array_to_ignorecase_regex(flagged_term_strings)
          @allowed_regex = array_to_ignorecase_regex(allowed_strings) unless allowed_strings.empty?
        end

        def process_allowed_regex(allowed)
          return EMPTY_ARRAY if allowed.nil?

          Array(allowed).map do |allowed_term|
            next if allowed_term.is_a?(String) && allowed_term.strip.empty?

            ensure_regex_string(allowed_term)
          end
        end

        def ensure_regex_string(regex)
          regex.is_a?(Regexp) ? regex.source : regex
        end

        def array_to_ignorecase_regex(strings)
          Regexp.new(strings.join('|'), Regexp::IGNORECASE)
        end

        def investigate_lines(processed_source)
          processed_source.lines.each_with_index do |line, line_number|
            word_locations = scan_for_words(line)

            next if word_locations.empty?

            word_locations.each do |word_location|
              range = source_range(processed_source.buffer, line_number + 1,
                                   word_location.position, word_location.word.length)
              add_offense(range, location: range, message: create_message(word_location.word))
            end
          end
        end

        def investigate_filepath(processed_source)
          word_locations = scan_for_words(processed_source.file_path)

          case word_locations.length
          when 0
            return
          when 1
            message = create_single_word_message_for_file(word_locations.first.word)
          else
            words = word_locations.map(&:word)
            message = create_multiple_word_message_for_file(words)
          end

          range = source_range(processed_source.buffer, 1, 0)
          add_offense(range, location: range, message: message)
        end

        def create_single_word_message_for_file(word)
          create_message(word).sub(/\.$/, ' in file path.')
        end

        def create_multiple_word_message_for_file(words)
          quoted_words = words.map { |word| "'#{word}'" }
          "Consider replacing problematic terms #{quoted_words.join(', ')} in file path."
        end

        def scan_for_words(input)
          mask_input(input).enum_for(:scan, @flagged_terms_regex).map do
            match = Regexp.last_match
            WordLocation.new(match.to_s, match.offset(0).first)
          end
        end

        def mask_input(str)
          return str if @allowed_regex.nil?

          str.gsub(@allowed_regex) { |match| '*' * match.size }
        end

        def create_message(word)
          flagged_term = find_flagged_term(word)
          "Consider replacing problematic term '#{word}'#{flagged_term['SuggestionString']}."
        end

        def find_flagged_term(word)
          _regexp, flagged_term = @flagged_term_hash.find do |key, _term|
            key.match?(word)
          end
          flagged_term
        end

        def create_message_for_file(word)
          create_message(word).sub(/\.$/, ' in file path.')
        end

        def preprocess_suggestions(suggestions)
          return '' if suggestions.nil? ||
                       (suggestions.is_a?(String) && suggestions.strip.empty?) || suggestions.empty?

          format_suggestions(suggestions)
        end

        def format_suggestions(suggestions)
          quoted_suggestions = Array(suggestions).map { |word| "'#{word}'" }
          suggestion_str = case quoted_suggestions.size
                           when 1
                             quoted_suggestions.first
                           when 2
                             quoted_suggestions.join(' or ')
                           else
                             last_quoted = quoted_suggestions.pop
                             quoted_suggestions << "or #{last_quoted}"
                             quoted_suggestions.join(', ')
                           end
          " with #{suggestion_str}"
        end
      end
    end
  end
end
