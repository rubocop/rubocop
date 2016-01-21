# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Performance::TimesMap do
  subject(:cop) { described_class.new }

  before do
    inspect_source(cop, source)
  end

  shared_examples 'map_or_collect' do |method|
    context ".times.#{method}" do
      context 'with a block' do
        let(:source) { "4.times.#{method} { |i| i.to_s }" }

        it 'registers an offense' do
          expect(cop.offenses.size).to eq(1)
          expect(cop.offenses.first.message).to eq(
            "Use `Array.new` with a block instead of `.times.#{method}`."
          )
          expect(cop.highlights).to eq(["4.times.#{method} { |i| i.to_s }"])
        end
      end

      context 'with an explicitly passed block' do
        let(:source) { "4.times.#{method}(&method(:foo))" }

        it 'registers an offense' do
          expect(cop.offenses.size).to eq(1)
          expect(cop.offenses.first.message).to eq(
            "Use `Array.new` with a block instead of `.times.#{method}`."
          )
          expect(cop.highlights).to eq(["4.times.#{method}(&method(:foo))"])
        end
      end

      context 'without a block' do
        let(:source) { "4.times.#{method}" }

        it "doesn't register an offense" do
          expect(cop.offenses).to be_empty
        end
      end

      context 'called on nothing' do
        let(:source) { "times.#{method} { |i| i.to_s }" }

        it "doesn't register an offense" do
          expect(cop.offenses).to be_empty
        end
      end
    end
  end

  it_behaves_like 'map_or_collect', 'map'
  it_behaves_like 'map_or_collect', 'collect'
end
