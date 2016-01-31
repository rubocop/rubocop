# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Performance::RedundantMerge do
  subject(:cop) { described_class.new }

  shared_examples 'redundant_merge' do |method|
    it "autocorrects hash.#{method}(a: 1)" do
      new_source = autocorrect_source(cop, "hash.#{method}(a: 1)")
      expect(new_source).to eq 'hash[:a] = 1'
    end

    it "autocorrects hash.#{method}('abc' => 'value')" do
      new_source = autocorrect_source(cop, "hash.#{method}('abc' => 'value')")
      expect(new_source).to eq "hash['abc'] = 'value'"
    end

    context 'when receiver is a local variable' do
      it "autocorrects hash.#{method}(a: 1, b: 2)" do
        new_source = autocorrect_source(cop, ['hash = {}',
                                              "hash.#{method}(a: 1, b: 2)"])
        expect(new_source).to eq(['hash = {}',
                                  'hash[:a] = 1',
                                  'hash[:b] = 2'].join("\n"))
      end
    end

    context 'when receiver is a method call' do
      it "doesn't autocorrect hash.#{method}(a: 1, b: 2)" do
        new_source = autocorrect_source(cop, "hash.#{method}(a: 1, b: 2)")
        expect(new_source).to eq("hash.#{method}(a: 1, b: 2)")
      end
    end

    %w(if unless while until).each do |kw|
      context "when there is a modifier #{kw}, and more than 1 pair" do
        it "autocorrects it to an #{kw} block" do
          new_source = autocorrect_source(
            cop,
            ['hash = {}',
             "hash.#{method}(a: 1, b: 2) #{kw} condition1 && condition2"])
          expect(new_source).to eq(['hash = {}',
                                    "#{kw} condition1 && condition2",
                                    '  hash[:a] = 1',
                                    '  hash[:b] = 2',
                                    'end'].join("\n"))
        end
      end
    end

    it "doesn't register an error when return value is used" do
      inspect_source(cop, ["variable = hash.#{method}(a: 1)",
                           'puts variable'])
      expect(cop.offenses).to be_empty
    end

    it "formats the error message correctly for hash.#{method}(a: 1)" do
      inspect_source(cop, "hash.#{method}(a: 1)")
      expect(cop.messages).to eq(
        ["Use `hash[:a] = 1` instead of `hash.#{method}(a: 1)`."])
    end
  end

  it_behaves_like('redundant_merge', 'merge!')
  it_behaves_like('redundant_merge', 'update')
end
