# frozen_string_literal: true

RSpec.describe RuboCop::AST::WhenNode do
  let(:when_node) { parse_source(source).ast.children[1] }

  describe '.new' do
    let(:source) do
      ['case',
       'when :foo then bar',
       'end'].join("\n")
    end

    it { expect(when_node.is_a?(described_class)).to be(true) }
  end

  describe '#conditions' do
    context 'with a single condition' do
      let(:source) do
        ['case',
         'when :foo then bar',
         'end'].join("\n")
      end

      it { expect(when_node.conditions.size).to eq(1) }
      it { expect(when_node.conditions).to all(be_literal) }
    end

    context 'with a multiple conditions' do
      let(:source) do
        ['case',
         'when :foo, :bar, :baz then bar',
         'end'].join("\n")
      end

      it { expect(when_node.conditions.size).to eq(3) }
      it { expect(when_node.conditions).to all(be_literal) }
    end
  end

  describe '#each_condition' do
    let(:source) do
      ['case',
       'when :foo, :bar, :baz then bar',
       'end'].join("\n")
    end

    context 'when not passed a block' do
      it { expect(when_node.each_condition.is_a?(Enumerator)).to be(true) }
    end

    context 'when passed a block' do
      it 'yields all the conditions' do
        expect { |b| when_node.each_condition(&b) }
          .to yield_successive_args(*when_node.conditions)
      end
    end
  end

  describe '#then?' do
    context 'with a then keyword' do
      let(:source) do
        ['case',
         'when :foo then bar',
         'end'].join("\n")
      end

      it { expect(when_node.then?).to be_truthy }
    end

    context 'without a then keyword' do
      let(:source) do
        ['case',
         'when :foo',
         '  bar',
         'end'].join("\n")
      end

      it { expect(when_node.then?).to be_falsey }
    end
  end

  describe '#body' do
    context 'with a then keyword' do
      let(:source) do
        ['case',
         'when :foo then :bar',
         'end'].join("\n")
      end

      it { expect(when_node.body.sym_type?).to be(true) }
    end

    context 'without a then keyword' do
      let(:source) do
        ['case',
         'when :foo',
         '  [:bar, :baz]',
         'end'].join("\n")
      end

      it { expect(when_node.body.array_type?).to be(true) }
    end
  end

  describe '#branch_index' do
    let(:source) do
      ['case',
       'when :foo then 1',
       'when :bar then 2',
       'when :baz then 3',
       'end'].join("\n")
    end

    let(:whens) { parse_source(source).ast.children[1...-1] }

    it { expect(whens[0].branch_index).to eq(0) }
    it { expect(whens[1].branch_index).to eq(1) }
    it { expect(whens[2].branch_index).to eq(2) }
  end
end
