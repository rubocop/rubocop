# frozen_string_literal: true

RSpec.describe RuboCop::AST::ArgsNode do
  let(:args_node) { parse_source(source).ast.arguments }

  describe '.new' do
    context 'with a method definition' do
      let(:source) { 'def foo(x) end' }

      it { expect(args_node.is_a?(described_class)).to be(true) }
    end

    context 'with a block' do
      let(:source) { 'foo { |x| bar }' }

      it { expect(args_node.is_a?(described_class)).to be(true) }
    end

    context 'with a lambda literal' do
      let(:source) { '-> (x) { bar }' }

      it { expect(args_node.is_a?(described_class)).to be(true) }
    end
  end

  describe '#empty_and_without_delimiters?' do
    subject { args_node.empty_and_without_delimiters? }

    context 'with empty arguments' do
      context 'with a method definition' do
        let(:source) { 'def x; end' }

        it { is_expected.to be(true) }
      end

      context 'with a block' do
        let(:source) { 'x { }' }

        it { is_expected.to be(true) }
      end

      context 'with a lambda literal' do
        let(:source) { '-> { }' }

        it { is_expected.to be(true) }
      end
    end

    context 'with delimiters' do
      context 'with a method definition' do
        let(:source) { 'def x(); end' }

        it { is_expected.to be(false) }
      end

      context 'with a block' do
        let(:source) { 'x { || }' }

        it { is_expected.to be(false) }
      end

      context 'with a lambda literal' do
        let(:source) { '-> () { }' }

        it { is_expected.to be(false) }
      end
    end

    context 'with arguments' do
      context 'with a method definition' do
        let(:source) { 'def x a; end' }

        it { is_expected.to be(false) }
      end

      context 'with a lambda literal' do
        let(:source) { '-> a { }' }

        it { is_expected.to be(false) }
      end
    end
  end
end
