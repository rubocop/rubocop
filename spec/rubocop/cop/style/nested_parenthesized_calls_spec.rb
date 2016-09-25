# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::NestedParenthesizedCalls do
  subject(:cop) { described_class.new }

  before(:each) do
    inspect_source(cop, source)
  end

  context 'on a non-parenthesized method call' do
    let(:source) { 'puts 1, 2' }

    it "doesn't register an offense" do
      expect(cop.offenses).to be_empty
    end
  end

  context 'on a method call with no arguments' do
    let(:source) { 'puts' }

    it "doesn't register an offense" do
      expect(cop.offenses).to be_empty
    end
  end

  context 'on a nested, parenthesized method call' do
    let(:source) { 'puts(compute(something))' }

    it "doesn't register an offense" do
      expect(cop.offenses).to be_empty
    end
  end

  context 'on a non-parenthesized call nested in a parenthesized one' do
    context 'with a single argument to the nested call' do
      let(:source) { 'puts(compute something)' }

      it 'registers an offense' do
        expect(cop.offenses.size).to eq(1)
        expect(cop.messages).to eq(
          ['Add parentheses to nested method call `compute something`.']
        )
        expect(cop.highlights).to eq(['compute something'])
      end

      it 'auto-corrects by adding parentheses' do
        new_source = autocorrect_source(cop, source)
        expect(new_source).to eq('puts(compute(something))')
      end
    end

    context 'with multiple arguments to the nested call' do
      let(:source) { 'puts(compute first, second)' }

      it 'registers an offense' do
        expect(cop.offenses.size).to eq(1)
        expect(cop.messages).to eq(
          ['Add parentheses to nested method call `compute first, second`.']
        )
        expect(cop.highlights).to eq(['compute first, second'])
      end

      it 'auto-corrects by adding parentheses' do
        new_source = autocorrect_source(cop, 'puts(compute first, second)')
        expect(new_source).to eq('puts(compute(first, second))')
      end
    end
  end

  context 'on a call with no arguments, nested in a parenthesized one' do
    let(:source) { 'puts(compute)' }

    it "doesn't register an offense" do
      expect(cop.offenses).to be_empty
    end
  end

  context 'on an aref, nested in a parenthesized method call' do
    let(:source) { 'method(obj[1])' }

    it "doesn't register an offense" do
      expect(cop.offenses).to be_empty
    end
  end

  context 'on a deeply nested argument' do
    let(:source) { 'method(block_taker { another_method 1 })' }

    it "doesn't register an offense" do
      expect(cop.offenses).to be_empty
    end
  end

  context 'on an RSpec matcher' do
    let(:source) { 'expect(obj).to(be true)' }

    it "doesn't register an offense" do
      expect(cop.offenses).to be_empty
    end
  end

  context 'on a call to a setter method' do
    let(:source) { 'expect(object1.attr = 1).to eq 1' }

    it "doesn't register an offense" do
      expect(cop.offenses).to be_empty
    end
  end
end
