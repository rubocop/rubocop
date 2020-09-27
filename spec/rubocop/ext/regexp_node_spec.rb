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

    context 'with interpolation: :ignore' do
      context 'with a regexp containing interpolation' do
        it { expect(node.parsed_tree(interpolation: :ignore)).to eq(nil) }
      end

      context 'with a regexp not containing interpolation' do
        let(:source) { '/foobaz/' }

        it 'returns the expected tree' do
          tree = node.parsed_tree(interpolation: :ignore)

          expect(tree).to be_an(Regexp::Expression::Root)
          expect(tree.to_s).to eq('foobaz')
        end
      end
    end

    context 'with interpolation: :blank' do
      context 'with a regexp containing interpolation' do
        it 'returns the expected blanked tree' do
          tree = node.parsed_tree(interpolation: :blank)

          expect(tree).to be_an(Regexp::Expression::Root)
          expect(tree.to_s).to eq('foo      baz')
        end
      end

      context 'with a regexp not containing interpolation' do
        let(:source) { '/foobaz/' }

        it 'returns the expected tree' do
          tree = node.parsed_tree(interpolation: :blank)

          expect(tree).to be_an(Regexp::Expression::Root)
          expect(tree.to_s).to eq('foobaz')
        end
      end
    end

    context 'with interpolation: :other' do
      it { expect { node.parsed_tree(interpolation: :other) }.to raise_error(ArgumentError) }
    end
  end
end
