# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Rails::ActionFilter, :config do
  subject(:cop) { described_class.new(config) }

  context 'when style is action' do
    let(:cop_config) { { 'EnforcedStyle' => 'action' } }

    described_class::FILTER_METHODS.each do |method|
      it "registers an offense for #{method}" do
        inspect_source(cop,
                       ["#{method} :name"])
        expect(cop.offenses.size).to eq(1)
      end

      it "registers an offense for #{method} with block" do
        inspect_source(cop,
                       ["#{method} { |controller| something }"])
        expect(cop.offenses.size).to eq(1)
      end

    end

    described_class::ACTION_METHODS.each do |method|
      it "accepts #{method}" do
        inspect_source(cop,
                       ["#{method} :something"])
        expect(cop.offenses).to be_empty
      end
    end
  end

  context 'when style is filter' do
    let(:cop_config) { { 'EnforcedStyle' => 'filter' } }

    described_class::ACTION_METHODS.each do |method|
      it "registers an offense for #{method}" do
        inspect_source(cop,
                       ["#{method} :name"])
        expect(cop.offenses.size).to eq(1)
      end

      it "registers an offense for #{method} with block" do
        inspect_source(cop,
                       ["#{method} { |controller| something }"])
        expect(cop.offenses.size).to eq(1)
      end

    end

    described_class::FILTER_METHODS.each do |method|
      it "accepts #{method}" do
        inspect_source(cop,
                       ["#{method} :something"])
        expect(cop.offenses).to be_empty
      end
    end
  end
end
