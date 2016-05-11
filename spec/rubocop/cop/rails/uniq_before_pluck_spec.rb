# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Rails::UniqBeforePluck do
  let(:corrected) { 'Model.uniq.pluck(:id)' }
  subject(:cop) { described_class.new }

  shared_examples_for 'UniqBeforePluck cop' do |source, action|
    if action == :correct
      it 'finds and corrects use of uniq after pluck' do
        inspect_source(cop, source)
        expect(cop.messages).to eq([described_class::MSG])
        expect(cop.highlights).to eq(['uniq'])
        expect(autocorrect_source(cop, source)).to eq(corrected)
      end
    else
      it 'ignores the source without any errors' do
        inspect_source(cop, source)
        expect(cop.messages).to be_empty
        expect(cop.highlights).to be_empty
        expect(cop.offenses).to be_empty
        expect(autocorrect_source(cop, source)).to eq(source)
      end
    end
  end

  it_behaves_like 'UniqBeforePluck cop',
                  'Model.pluck(:id).uniq', :correct

  it_behaves_like 'UniqBeforePluck cop',
                  ['Model.pluck(:id)', '  .uniq'], :correct

  it_behaves_like 'UniqBeforePluck cop',
                  ['Model.pluck(:id).', '  uniq'], :correct

  context 'uniq before pluck' do
    it_behaves_like 'UniqBeforePluck cop',
                    'Model.where(foo: 1).uniq.pluck(:something)', :ignore
  end

  context 'uniq without a receiver' do
    it_behaves_like 'UniqBeforePluck cop',
                    'uniq.something', :ignore
  end

  context 'uniq without pluck' do
    it_behaves_like 'UniqBeforePluck cop',
                    'Model.uniq', :ignore
  end

  context 'uniq with a block' do
    it_behaves_like 'UniqBeforePluck cop',
                    'Model.where(foo: 1).pluck(:id).uniq { |k| k[0] }', :ignore
  end
end
