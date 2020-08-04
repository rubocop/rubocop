# frozen_string_literal: true

module RuboCop
  # Common methods and behaviors for dealing with tokens.
  module TokensUtil
    module_function

    # rubocop:disable Metrics/AbcSize
    def tokens(node)
      @tokens ||= {}
      return @tokens[node.object_id] if @tokens[node.object_id]

      @tokens[node.object_id] =
        # The tokens list is always sorted by token position,
        # except for cases when heredoc is passed as a method argument.
        # In this case tokens are interleaved by heredoc contents' tokens.
        # We can try a fast (binary) search, assuming the mentioned cases are rare,
        # and fallback to linear search if failed.
        if (tokens = fast_tokens(node))
          tokens
        else
          begin_pos = node.source_range.begin_pos
          end_pos   = node.source_range.end_pos

          processed_source.tokens.select do |token|
            token.end_pos <= end_pos && token.begin_pos >= begin_pos
          end
        end
    end
    # rubocop:enable Metrics/AbcSize

    def index_of_first_token(node)
      index = fast_index_of_first_token(node)
      return index if index

      begin_pos = node.source_range.begin_pos
      processed_source.tokens.index { |token| token.begin_pos == begin_pos }
    end

    def index_of_last_token(node)
      index = fast_index_of_last_token(node)
      return index if index

      end_pos = node.source_range.end_pos
      processed_source.tokens.index { |token| token.end_pos == end_pos }
    end

    private

    def fast_index_of_first_token(node)
      begin_pos = node.source_range.begin_pos
      tokens = processed_source.tokens

      index = tokens.bsearch_index { |token| token.begin_pos >= begin_pos }
      index if index && tokens[index].begin_pos == begin_pos
    end

    def fast_index_of_last_token(node)
      end_pos = node.source_range.end_pos
      tokens = processed_source.tokens

      index = tokens.bsearch_index { |token| token.end_pos >= end_pos }
      index if index && tokens[index].end_pos == end_pos
    end

    def fast_tokens(node)
      begin_index = index_of_first_token(node)
      end_index   = index_of_last_token(node)

      tokens = processed_source.tokens[begin_index..end_index]
      tokens if sorted_tokens?(tokens)
    end

    def sorted_tokens?(tokens)
      prev_begin_pos = -1
      tokens.each do |token|
        return false if token.begin_pos < prev_begin_pos

        prev_begin_pos = token.begin_pos
      end
      true
    end
  end
end
