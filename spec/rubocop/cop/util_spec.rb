# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Util do
  class TestUtil
    include RuboCop::Cop::Util
  end

  describe '#line_range' do
    let(:source) do
      <<-RUBY
        foo = 1
        bar = 2
        class Test
          def some_method
            do_something
          end
        end
        baz = 8
      RUBY
    end

    let(:processed_source) { parse_source(source) }
    let(:ast) { processed_source.ast }

    let(:node) { ast.each_node.find(&:class_type?) }

    it 'returns line range of the expression' do
      line_range = described_class.line_range(node)
      expect(line_range).to eq(3..7)
    end
  end

  describe '#to_supported_styles' do
    subject { described_class.to_supported_styles(enforced_style) }

    context 'when EnforcedStyle' do
      let(:enforced_style) { 'EnforcedStyle' }

      it { is_expected.to eq('SupportedStyles') }
    end

    context 'when EnforcedStyleInsidePipes' do
      let(:enforced_style) { 'EnforcedStyleInsidePipes' }

      it { is_expected.to eq('SupportedStylesInsidePipes') }
    end
  end
end
