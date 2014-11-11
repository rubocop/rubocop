# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::Style::EmptyElse do
  subject(:cop) { described_class.new(config) }
  let(:config) do
    RuboCop::Config.new
  end

  context 'given an if-statement' do
    context 'with a completely empty else-clause' do
      it 'registers an offense' do
        inspect_source(cop, 'if a; foo else end')
        expect(cop.messages).to eq(['Redundant empty `else`-clause.'])
      end
    end

    context 'with an else-clause containing only the literal nil' do
      it 'registers an offense' do
        inspect_source(cop, 'if a; foo elsif b; bar else nil end')
        expect(cop.messages).to eq(['Redundant empty `else`-clause.'])
      end
    end

    context 'with an else-clause with side-effects' do
      it "doesn't register an offence" do
        inspect_source(cop, 'if cond; foo else bar; nil end')
        expect(cop.messages).to be_empty
      end
    end

    context 'with no else-clause' do
      it "doesn't register an offence" do
        inspect_source(cop, 'if cond; foo end')
        expect(cop.messages).to be_empty
      end
    end
  end

  context 'given an unless-statement' do
    context 'with a completely empty else-clause' do
      it 'registers an offense' do
        inspect_source(cop, 'unless cond; foo else end')
        expect(cop.messages).to eq(['Redundant empty `else`-clause.'])
      end
    end

    context 'with an else-clause containing only the literal nil' do
      it 'registers an offense' do
        inspect_source(cop, 'unless cond; foo else nil end')
        expect(cop.messages).to eq(['Redundant empty `else`-clause.'])
      end
    end

    context 'with an else-clause with side-effects' do
      it "doesn't register an offence" do
        inspect_source(cop, 'unless cond; foo else bar; nil end')
        expect(cop.messages).to be_empty
      end
    end

    context 'with no else-clause' do
      it "doesn't register an offence" do
        inspect_source(cop, 'unless cond; foo end')
        expect(cop.messages).to be_empty
      end
    end
  end

  context 'given a case statement' do
    context 'with a completely empty else-clause' do
      it 'registers an offense' do
        inspect_source(cop, 'case v; when a; foo else end')
        expect(cop.messages).to eq(['Redundant empty `else`-clause.'])
      end
    end

    context 'with an else-clause containing only the literal nil' do
      it 'registers an offense' do
        inspect_source(cop, 'case v; when a; foo; when b; bar; else nil end')
        expect(cop.messages).to eq(['Redundant empty `else`-clause.'])
      end
    end

    context 'with an else-clause with side-effects' do
      it "doesn't register an offence" do
        inspect_source(cop, 'case v; when a; foo; else b; nil end')
        expect(cop.messages).to be_empty
      end
    end

    context 'with no else-clause' do
      it "doesn't register an offence" do
        inspect_source(cop, 'case v; when a; foo; when b; bar; end')
        expect(cop.messages).to be_empty
      end
    end
  end
end
