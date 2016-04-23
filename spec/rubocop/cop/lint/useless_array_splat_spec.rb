# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Lint::UselessArraySplat do
  subject(:cop) { described_class.new }

  shared_examples 'detecting and correcting offenses' do
    let(:source) { "#{binding} = *#{source_rhs}" }

    it 'registers an offense and autocorrects' do
      inspect_source(cop, source)

      expect(cop.offenses.size).to eq(1)
      expect(cop.offenses.first.message).to eq('Unnecessary array splat.')
      expect(cop.highlights).to eq(['*'])
      expect(autocorrect_source(cop, source)).to eq(source.delete('*'))
    end
  end

  shared_examples 'detect and correct no offenses' do
    let(:source) { "#{binding} = #{source_rhs}" }

    it 'registers and corrects no offenses' do
      inspect_source(cop, source)

      expect(cop.offenses).to be_empty
      expect(autocorrect_source(cop, source)).to eq(source)
    end
  end

  {
    'variable' => 'a',
    'instance variable' => '@a',
    'class variable' => '@@a',
    'constant' => 'A',
    'global variable' => '$a'
  }.each do |type, var|
    {
      'a single' => var,
      'more than one' => [var, var].join(', ')
    }.each do |count, binding|
      context "when splatting into #{count} #{type}" do
        let(:binding) { binding }

        context 'with splat' do
          context 'for an array literal' do
            let(:source_rhs) { '[1, 2, 3]' }

            include_examples 'detecting and correcting offenses'
          end

          context 'for a constructed Array' do
            let(:source_rhs) { 'Array.new(3) { 42 }' }

            include_examples 'detecting and correcting offenses'
          end

          context 'for a constructed Array without a block' do
            let(:source_rhs) { 'Array.new(3)' }

            include_examples 'detecting and correcting offenses'
          end

          %w(i I w W).each do |literal_type|
            context "for a %#{literal_type} literal" do
              let(:source_rhs) { "%#{literal_type}{1 2 3}" }

              include_examples 'detecting and correcting offenses'
            end
          end
        end

        context 'without splat' do
          context 'for an array' do
            let(:source_rhs) { '[]' }

            include_examples 'detect and correct no offenses'
          end

          context 'for a symbol' do
            let(:source_rhs) { ':a' }

            include_examples 'detect and correct no offenses'
          end

          context 'for a variable' do
            let(:source_rhs) { 'foo' }

            include_examples 'detect and correct no offenses'
          end
        end
      end
    end
  end
end
