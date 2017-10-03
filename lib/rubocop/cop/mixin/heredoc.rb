# frozen_string_literal: true

# Common functionality for working with heredoc strings.
module Heredoc
  OPENING_DELIMITER = /<<[~-]?['"`]?([^'"`]+)['"`]?/

  def on_str(node)
    return unless heredoc?(node)

    on_heredoc(node)
  end
  alias on_dstr on_str
  alias on_xstr on_str

  def on_heredoc(_node)
    raise NotImplementedError
  end

  private

  def heredoc?(node)
    node.loc.is_a?(Parser::Source::Map::Heredoc)
  end

  def delimiter_string(node)
    node.source.match(OPENING_DELIMITER).captures.first
  end
end
