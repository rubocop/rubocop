# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::ZeroLengthPredicate do
  subject(:cop) { described_class.new }

  before do
    inspect_source(cop, source)
  end

  shared_examples 'registers offense' do |code, message, expected|
    context "when checking #{code}" do
      let(:source) { code }

      it 'registers an offense' do
        expect(cop.offenses.size).to eq(1)
        expect(cop.offenses.first.message).to eq(message)
        expect(cop.highlights).to eq([code])
      end

      it 'auto-corrects' do
        expect(autocorrect_source(cop, code)).to eq expected
      end
    end
  end

  it_behaves_like 'registers offense', '[1, 2, 3].length == 0',
                  'Use `empty?` instead of `length == 0`.',
                  '[1, 2, 3].empty?'
  it_behaves_like 'registers offense', '[1, 2, 3].size == 0',
                  'Use `empty?` instead of `size == 0`.',
                  '[1, 2, 3].empty?'
  it_behaves_like 'registers offense', '0 == [1, 2, 3].length',
                  'Use `empty?` instead of `0 == length`.',
                  '[1, 2, 3].empty?'
  it_behaves_like 'registers offense', '0 == [1, 2, 3].size',
                  'Use `empty?` instead of `0 == size`.',
                  '[1, 2, 3].empty?'

  it_behaves_like 'registers offense', '[1, 2, 3].length < 1',
                  'Use `empty?` instead of `length < 1`.',
                  '[1, 2, 3].empty?'
  it_behaves_like 'registers offense', '[1, 2, 3].size < 1',
                  'Use `empty?` instead of `size < 1`.',
                  '[1, 2, 3].empty?'
  it_behaves_like 'registers offense', '1 > [1, 2, 3].length',
                  'Use `empty?` instead of `1 > length`.',
                  '[1, 2, 3].empty?'
  it_behaves_like 'registers offense', '1 > [1, 2, 3].size',
                  'Use `empty?` instead of `1 > size`.',
                  '[1, 2, 3].empty?'

  it_behaves_like 'registers offense', '[1, 2, 3].length > 0',
                  'Use `!empty?` instead of `length > 0`.',
                  '![1, 2, 3].empty?'
  it_behaves_like 'registers offense', '[1, 2, 3].size > 0',
                  'Use `!empty?` instead of `size > 0`.',
                  '![1, 2, 3].empty?'
  it_behaves_like 'registers offense', '[1, 2, 3].length != 0',
                  'Use `!empty?` instead of `length != 0`.',
                  '![1, 2, 3].empty?'
  it_behaves_like 'registers offense', '[1, 2, 3].size != 0',
                  'Use `!empty?` instead of `size != 0`.',
                  '![1, 2, 3].empty?'

  it_behaves_like 'registers offense', '0 < [1, 2, 3].length',
                  'Use `!empty?` instead of `0 < length`.',
                  '![1, 2, 3].empty?'
  it_behaves_like 'registers offense', '0 < [1, 2, 3].size',
                  'Use `!empty?` instead of `0 < size`.',
                  '![1, 2, 3].empty?'
  it_behaves_like 'registers offense', '0 != [1, 2, 3].length',
                  'Use `!empty?` instead of `0 != length`.',
                  '![1, 2, 3].empty?'
  it_behaves_like 'registers offense', '0 != [1, 2, 3].size',
                  'Use `!empty?` instead of `0 != size`.',
                  '![1, 2, 3].empty?'
end
