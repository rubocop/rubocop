# frozen_string_literal: true

require 'timeout'

RSpec.describe RuboCop::Ext::RegexpNode do
  let(:source) { '/(hello)(?<foo>world)(?:not captured)/' }
  let(:processed_source) { parse_source(source) }
  let(:ast) { processed_source.ast }
  let(:node) { ast }

  describe '#each_capture' do
    subject(:captures) { node.each_capture(**arg).to_a }

    let(:named) { be_instance_of(Regexp::Expression::Group::Named) }
    let(:positional) { be_instance_of(Regexp::Expression::Group::Capture) }

    context 'when called without argument' do
      let(:arg) { {} }

      it { is_expected.to match [positional, named] }
    end

    context 'when called with a `named: false`' do
      let(:arg) { { named: false } }

      it { is_expected.to match [positional] }
    end

    context 'when called with a `named: true`' do
      let(:arg) { { named: true } }

      it { is_expected.to match [named] }
    end
  end

  describe '#parsed_tree' do
    let(:source) { '/foo#{bar}baz/' }

    context 'with an extended mode regexp with comment' do
      let(:source) { '/42 # the answer/x' }

      it 'returns the expected tree' do
        tree = node.parsed_tree

        expect(tree.is_a?(Regexp::Expression::Root)).to be(true)
        expect(tree.map(&:token)).to eq(%i[literal whitespace comment])
      end
    end

    context 'with a regexp containing interpolation' do
      it 'returns the expected blanked tree' do
        tree = node.parsed_tree

        expect(tree.is_a?(Regexp::Expression::Root)).to be(true)
        expect(tree.to_s).to eq('foo      baz')
      end
    end

    context 'with a regexp containing a multi-line interpolation' do
      let(:source) do
        <<~'REGEXP'
          /
            foo
            #{
              bar(
                42
              )
            }
            baz
          /
        REGEXP
      end

      it 'returns the expected blanked tree' do
        tree = node.parsed_tree

        expect(tree.is_a?(Regexp::Expression::Root)).to be(true)
        expect(tree.to_s.split("\n")).to eq(['', '  foo', ' ' * 32, '  baz'])
      end
    end

    context 'with a regexp not containing interpolation' do
      let(:source) { '/foobaz/' }

      it 'returns the expected tree' do
        tree = node.parsed_tree

        expect(tree.is_a?(Regexp::Expression::Root)).to be(true)
        expect(tree.to_s).to eq('foobaz')
      end
    end

    context 'with a regexp with subexpressions' do
      let(:source) { '/([a-z]+)\d*\s?(?:foo)/' }

      it 'has location information' do
        nodes = node.parsed_tree.each_expression.map { |exp, _index| exp }

        # `Parser::Source::Map` does not have `source_range` method.
        # rubocop:disable InternalAffairs/LocationExpression
        sources = nodes.map { |n| n.loc.expression.source }
        # rubocop:enable InternalAffairs/LocationExpression

        expect(sources).to eq %w{([a-z]+) [a-z]+ a-z a z \d* \s? (?:foo) foo}

        loc = nodes[1].loc
        delim = loc.begin, loc.body, loc.end, loc.quantifier
        expect(delim.map(&:source)).to eq %w{[ [a-z] ] +}
      end
    end
  end
end
