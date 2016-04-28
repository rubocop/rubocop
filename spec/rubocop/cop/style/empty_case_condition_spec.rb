# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::EmptyCaseCondition do
  subject(:cop) { described_class.new }

  shared_examples 'detect/correct empty case, accept non-empty case' do
    it 'registers an offense' do
      inspect_source(cop, source)
      expect(cop.messages).to eq [described_class::MSG]
    end

    it 'correctly autocorrects' do
      expect(autocorrect_source(cop, source)).to eq corrected_source.join("\n")
    end

    let(:source_with_case) { source.map { |s| s.gsub(/case/, 'case :a') } }

    it 'accepts the source with case' do
      inspect_source(cop, source_with_case)
      expect(cop.messages).to be_empty
    end
  end

  context 'given a case statement with an empty case' do
    context 'with multiple when branches and an else' do
      let(:source) do
        ['case',
         'when 1 == 2',
         '  foo',
         'when 1 == 1',
         '  bar',
         'else',
         '  baz',
         'end']
      end
      let(:corrected_source) do
        ['if 1 == 2',
         '  foo',
         'elsif 1 == 1',
         '  bar',
         'else',
         '  baz',
         'end']
      end

      it_behaves_like 'detect/correct empty case, accept non-empty case'
    end

    context 'with multiple when branches and no else' do
      let(:source) do
        ['case',
         'when 1 == 2',
         '  foo',
         'when 1 == 1',
         '  bar',
         'end']
      end
      let(:corrected_source) do
        ['if 1 == 2',
         '  foo',
         'elsif 1 == 1',
         '  bar',
         'end']
      end

      it_behaves_like 'detect/correct empty case, accept non-empty case'
    end

    context 'with a single when branch and an else' do
      let(:source) do
        ['case',
         'when 1 == 2',
         '  foo',
         'else',
         '  bar',
         'end']
      end
      let(:corrected_source) do
        ['if 1 == 2',
         '  foo',
         'else',
         '  bar',
         'end']
      end

      it_behaves_like 'detect/correct empty case, accept non-empty case'
    end

    context 'with a single when branch and no else' do
      let(:source) do
        ['case',
         'when 1 == 2',
         '  foo',
         'end']
      end
      let(:corrected_source) do
        ['if 1 == 2',
         '  foo',
         'end']
      end

      it_behaves_like 'detect/correct empty case, accept non-empty case'
    end

    context 'with a when branch including comma-delimited alternatives' do
      let(:source) do
        ['case',
         'when false',
         '  foo',
         'when nil, false, 1',
         '  bar',
         'when false, 1',
         '  baz',
         'end']
      end
      let(:corrected_source) do
        ['if false',
         '  foo',
         'elsif nil || false || 1',
         '  bar',
         'elsif false || 1',
         '  baz',
         'end']
      end

      it_behaves_like 'detect/correct empty case, accept non-empty case'
    end

    context 'with when branches using then' do
      let(:source) do
        ['case',
         'when false then foo',
         'when nil, false, 1 then bar',
         'when false, 1 then baz',
         'end']
      end
      let(:corrected_source) do
        ['if false then foo',
         'elsif nil || false || 1 then bar',
         'elsif false || 1 then baz',
         'end']
      end

      it_behaves_like 'detect/correct empty case, accept non-empty case'
    end
  end
end
