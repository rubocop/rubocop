# frozen_string_literal: true

describe RuboCop::AST::CaseNode do
  let(:case_node) { parse_source(source).ast }

  describe '.new' do
    let(:source) do
      ['case',
       'when :foo then bar',
       'end'].join("\n")
    end

    it { expect(case_node).to be_a(described_class) }
  end

  describe '#keyword' do
    let(:source) do
      ['case',
       'when :foo then bar',
       'end'].join("\n")
    end

    it { expect(case_node.keyword).to eq('case') }
  end

  describe '#when_branches' do
    let(:source) do
      ['case',
       'when :foo then 1',
       'when :bar then 2',
       'when :baz then 3',
       'end'].join("\n")
    end

    it { expect(case_node.when_branches.size).to eq(3) }
    it { expect(case_node.when_branches).to all(be_when_type) }
  end

  describe '#each_when' do
    let(:source) do
      ['case',
       'when :foo then 1',
       'when :bar then 2',
       'when :baz then 3',
       'end'].join("\n")
    end

    context 'when not passed a block' do
      it { expect(case_node.each_when).to be_an(Enumerator) }
    end

    context 'when passed a block' do
      it 'yields all the conditions' do
        expect { |b| case_node.each_when(&b) }
          .to yield_successive_args(*case_node.when_branches)
      end
    end
  end

  describe '#else?' do
    context 'without an else statement' do
      let(:source) do
        ['case',
         'when :foo then :bar',
         'end'].join("\n")
      end

      it { expect(case_node.else?).to be_falsey }
    end

    context 'with an else statement' do
      let(:source) do
        ['case',
         'when :foo then :bar',
         'else :baz',
         'end'].join("\n")
      end

      it { expect(case_node.else?).to be_truthy }
    end
  end

  describe '#else_branch' do
    describe '#else?' do
      context 'without an else statement' do
        let(:source) do
          ['case',
           'when :foo then :bar',
           'end'].join("\n")
        end

        it { expect(case_node.else_branch).to be_nil }
      end

      context 'with an else statement' do
        let(:source) do
          ['case',
           'when :foo then :bar',
           'else :baz',
           'end'].join("\n")
        end

        it { expect(case_node.else_branch).to be_sym_type }
      end
    end
  end
end
