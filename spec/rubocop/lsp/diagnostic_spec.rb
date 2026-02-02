# frozen_string_literal: true

require 'rubocop/lsp/diagnostic'

RSpec.describe RuboCop::LSP::Diagnostic do
  include CopHelper

  subject(:diagnostic) do
    described_class.new(nil, offense, 'file:///path/to/file.rb', nil, processed_source)
  end

  let(:source) do
    <<~RUBY
      # frozen_string_literal: true
      sql = <<~SQL
        SELECT * FROM some_table_with_long_name_that_is_over_limit
      SQL
    RUBY
  end

  let(:processed_source) do
    RuboCop::ProcessedSource.new(source, ruby_version, 'file.rb', parser_engine: parser_engine)
  end
  let(:location) { processed_source.buffer.line_range(3) }
  let(:offense) do
    RuboCop::Cop::Offense.new(:warning, location, 'Line is too long.', 'Layout/LineLength')
  end

  it 'inserts block disable comments for multiline string literals' do
    edits = diagnostic.send(:line_disable_comment).map do |edit|
      range = edit.range
      {
        range: {
          start: range.start.to_hash,
          end: range.end.to_hash
        },
        newText: edit.new_text
      }
    end

    expect(edits).to eq(
      [
        {
          range: {
            start: { line: 1, character: 0 },
            end: { line: 1, character: 0 }
          },
          newText: "# rubocop:disable Layout/LineLength\n"
        },
        {
          range: {
            start: { line: 3, character: 3 },
            end: { line: 3, character: 3 }
          },
          newText: "\n# rubocop:enable Layout/LineLength"
        }
      ]
    )
  end
end
