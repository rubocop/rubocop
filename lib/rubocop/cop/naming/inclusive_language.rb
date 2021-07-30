# frozen_string_literal: true

module RuboCop
  module Cop
    module Naming
      # This cops recommends the use of inclusive language instead of problematic terms.
      # The cop can check the following locations for offenses:
      # - identifiers
      # - constants
      # - variables
      # - strings
      # - symbols
      # - comments
      # - file paths
      # Each of these locations can be individually enabled/disabled via configuration,
      # for example CheckIdentifiers = true/false.
      #
      # Flagged terms are configurable for the cop. For each flagged term an optional
      # Regex can be specified to identify offenses. Suggestions for replacing a flagged term can
      # be configured and will be displayed as part of the offense message.
      # An AllowedRegex can be specified for a flagged term to exempt allowed uses of the term.
      # `WholeWord: true` can be set on a flagged term to indicate the cop should only match when
      # a term matches the whole word (partial matches will not be offenses).
      #
      # @example FlaggedTerms: { whitelist: { Suggestions: ['allowlist'] } }
      #   # Suggest replacing identifier whitelist with allowlist
      #
      #   # bad
      #   whitelist_users = %w(user1 user1)
      #
      #   # good
      #   allowlist_users = %w(user1 user2)
      #
      # @example FlaggedTerms: { master: { Suggestions: ['main', 'primary', 'leader'] } }
      #   # Suggest replacing master in an instance variable name with main, primary, or leader
      #
      #   # bad
      #   @master_node = 'node1.example.com'
      #
      #   # good
      #   @primary_node = 'node1.example.com'
      #
      # @example FlaggedTerms: { whitelist: { Regex: !ruby/regexp '/white[-_\s]?list' } }
      #   # Identify problematic terms using a Regexp
      #
      #   # bad
      #   white_list = %w(user1 user2)
      #
      #   # good
      #   allow_list = %w(user1 user2)
      #
      # @example FlaggedTerms: { master: { AllowedRegex: 'master\'?s degree' } }
      #   # Specify allowed uses of the flagged term as a string or regexp.
      #
      #   # bad
      #   # They had a masters
      #
      #   # good
      #   # They had a master's degree
      #
      # @example FlaggedTerms: { slave: { WholeWord: true } }
      #   # Specify that only terms that are full matches will be flagged.
      #
      #   # bad
      #   Slave
      #
      #   # good (won't be flagged despite containing `slave`)
      #   TeslaVehicle
      class InclusiveLanguage < Base
        include RangeHelp

        EMPTY_ARRAY = [].freeze

        WordLocation = Struct.new(:word, :position)

        def initialize(config = nil, options = nil)
          super
          @flagged_term_hash = {}
          @flagged_terms_regex = nil
          @allowed_regex = nil
          @check_token = preprocess_check_config
          preprocess_flagged_terms
        end

        def on_new_investigation
          investigate_filepath if cop_config['CheckFilepaths']
          investigate_tokens
        end

        private

        def investigate_tokens
          processed_source.each_token do |token|
            next unless check_token?(token.type)

            word_locations = scan_for_words(token.text)
            next if word_locations.empty?

            add_offenses_for_token(token, word_locations)
          end
        end

        def add_offenses_for_token(token, word_locations)
          word_locations.each do |word_location|
            start_position = token.pos.begin_pos + token.pos.source.index(word_location.word)
            range = range_between(start_position, start_position + word_location.word.length)
            add_offense(range, message: create_message(word_location.word))
          end
        end

        def check_token?(type)
          !!@check_token[type]
        end

        def preprocess_check_config # rubocop:disable Metrics/AbcSize
          {
            tIDENTIFIER: cop_config['CheckIdentifiers'],
            tCONSTANT: cop_config['CheckConstants'],
            tIVAR: cop_config['CheckVariables'],
            tCVAR: cop_config['CheckVariables'],
            tGVAR: cop_config['CheckVariables'],
            tSYMBOL: cop_config['CheckSymbols'],
            tSTRING: cop_config['CheckStrings'],
            tSTRING_CONTENT: cop_config['CheckStrings'],
            tCOMMENT: cop_config['CheckComments']
          }.freeze
        end

        def preprocess_flagged_terms
          allowed_strings = []
          flagged_term_strings = []
          cop_config['FlaggedTerms'].each do |term, term_definition|
            next if term_definition.nil?

            allowed_strings.concat(process_allowed_regex(term_definition['AllowedRegex']))
            regex_string = ensure_regex_string(extract_regexp(term, term_definition))
            flagged_term_strings << regex_string

            add_to_flagged_term_hash(regex_string, term, term_definition)
          end

          set_regexes(flagged_term_strings, allowed_strings)
        end

        def extract_regexp(term, term_definition)
          return term_definition['Regex'] if term_definition['Regex']
          return /(?:\b|(?<=[\W_]))#{term}(?:\b|(?=[\W_]))/ if term_definition['WholeWord']

          term
        end

        def add_to_flagged_term_hash(regex_string, term, term_definition)
          @flagged_term_hash[Regexp.new(regex_string, Regexp::IGNORECASE)] =
            term_definition.merge('Term' => term,
                                  'SuggestionString' =>
                                    preprocess_suggestions(term_definition['Suggestions']))
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

        def investigate_filepath
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
          add_offense(range, message: message)
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

          safe_str = if str.valid_encoding?
                       str
                     else
                       str.encode('UTF-8', invalid: :replace, undef: :replace)
                     end
          safe_str.gsub(@allowed_regex) { |match| '*' * match.size }
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
