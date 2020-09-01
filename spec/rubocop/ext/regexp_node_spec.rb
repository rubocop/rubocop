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
end
