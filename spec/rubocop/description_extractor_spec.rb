# frozen_string_literal: true

require 'yard'
require 'rubocop/description_extractor'

RSpec.describe RuboCop::DescriptionExtractor do
  let(:yardocs) do
    YARD.parse_string(<<-RUBY)
      # Summary description
      #
      # Some more description
      #
      # @example
      #   # bad
      #   something
      #
      #   # good
      #   something
      #
      # @note only works with foo
      #
      class RuboCop::Cop::Layout::EmptyLines < RuboCop::Cop::Cop
        # Hello
        def bar
        end
      end
      # Only line of description
      #
      class RuboCop::Cop::Layout::EndOfLine < RuboCop::Cop::Cop
        # Hello
        def bar
        end
      end
    RUBY

    YARD::Registry.all
  end

  it 'builds a hash of descriptions' do
    expect(described_class.new(yardocs).to_h).to include(
      'Layout/EmptyLines' => { 'Description' => 'Summary description' },
      'Layout/EndOfLine' => { 'Description' => 'Only line of description' }
    )
  end
end
