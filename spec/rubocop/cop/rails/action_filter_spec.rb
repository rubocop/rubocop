# encoding: utf-8

require 'spec_helper'
require 'tempfile'

describe RuboCop::Cop::Rails::ActionFilter, :config do
  subject(:cop) { described_class.new(config) }

  context 'when style is action' do
    let(:cop_config) { { 'EnforcedStyle' => 'action' } }

    described_class::FILTER_METHODS.each do |method|
      it "registers an offense for #{method}" do
        inspect_source_file(cop, "#{method} :name")
        expect(cop.offenses.size).to eq(1)
      end

      it "registers an offense for #{method} with block" do
        inspect_source_file(cop, "#{method} { |controller| something }")
        expect(cop.offenses.size).to eq(1)
      end
    end

    described_class::ACTION_METHODS.each do |method|
      it "accepts #{method}" do
        inspect_source_file(cop, "#{method} :something")
        expect(cop.offenses).to be_empty
      end
    end

    it 'auto-corrects to preferred method' do
      new_source = autocorrect_source_file(cop, 'before_filter :test')
      expect(new_source).to eq('before_action :test')
    end
  end

  context 'when style is filter' do
    let(:cop_config) { { 'EnforcedStyle' => 'filter' } }

    described_class::ACTION_METHODS.each do |method|
      it "registers an offense for #{method}" do
        inspect_source_file(cop, "#{method} :name")
        expect(cop.offenses.size).to eq(1)
      end

      it "registers an offense for #{method} with block" do
        inspect_source_file(cop, "#{method} { |controller| something }")
        expect(cop.offenses.size).to eq(1)
      end
    end

    described_class::FILTER_METHODS.each do |method|
      it "accepts #{method}" do
        inspect_source_file(cop, "#{method} :something")
        expect(cop.offenses).to be_empty
      end
    end

    it 'auto-corrects to preferred method' do
      new_source = autocorrect_source_file(cop, 'before_action :test')
      expect(new_source).to eq('before_filter :test')
    end
  end
end
