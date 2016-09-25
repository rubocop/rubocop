# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::ZeroLengthPredicate do
  subject(:cop) { described_class.new }

  before do
    inspect_source(cop, source)
  end

  shared_examples 'code with offense' do |code, message, expected|
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

  shared_examples 'code without offense' do |code|
    let(:source) { code }

    it 'does not register any offense' do
      expect(cop.offenses).to be_empty
    end
  end

  context 'with arrays' do
    it_behaves_like 'code with offense', '[1, 2, 3].length == 0',
                    'Use `empty?` instead of `length == 0`.',
                    '[1, 2, 3].empty?'
    it_behaves_like 'code with offense', '[1, 2, 3].size == 0',
                    'Use `empty?` instead of `size == 0`.',
                    '[1, 2, 3].empty?'
    it_behaves_like 'code with offense', '0 == [1, 2, 3].length',
                    'Use `empty?` instead of `0 == length`.',
                    '[1, 2, 3].empty?'
    it_behaves_like 'code with offense', '0 == [1, 2, 3].size',
                    'Use `empty?` instead of `0 == size`.',
                    '[1, 2, 3].empty?'

    it_behaves_like 'code with offense', '[1, 2, 3].length < 1',
                    'Use `empty?` instead of `length < 1`.',
                    '[1, 2, 3].empty?'
    it_behaves_like 'code with offense', '[1, 2, 3].size < 1',
                    'Use `empty?` instead of `size < 1`.',
                    '[1, 2, 3].empty?'
    it_behaves_like 'code with offense', '1 > [1, 2, 3].length',
                    'Use `empty?` instead of `1 > length`.',
                    '[1, 2, 3].empty?'
    it_behaves_like 'code with offense', '1 > [1, 2, 3].size',
                    'Use `empty?` instead of `1 > size`.',
                    '[1, 2, 3].empty?'

    it_behaves_like 'code with offense', '[1, 2, 3].length > 0',
                    'Use `!empty?` instead of `length > 0`.',
                    '![1, 2, 3].empty?'
    it_behaves_like 'code with offense', '[1, 2, 3].size > 0',
                    'Use `!empty?` instead of `size > 0`.',
                    '![1, 2, 3].empty?'
    it_behaves_like 'code with offense', '[1, 2, 3].length != 0',
                    'Use `!empty?` instead of `length != 0`.',
                    '![1, 2, 3].empty?'
    it_behaves_like 'code with offense', '[1, 2, 3].size != 0',
                    'Use `!empty?` instead of `size != 0`.',
                    '![1, 2, 3].empty?'

    it_behaves_like 'code with offense', '0 < [1, 2, 3].length',
                    'Use `!empty?` instead of `0 < length`.',
                    '![1, 2, 3].empty?'
    it_behaves_like 'code with offense', '0 < [1, 2, 3].size',
                    'Use `!empty?` instead of `0 < size`.',
                    '![1, 2, 3].empty?'
    it_behaves_like 'code with offense', '0 != [1, 2, 3].length',
                    'Use `!empty?` instead of `0 != length`.',
                    '![1, 2, 3].empty?'
    it_behaves_like 'code with offense', '0 != [1, 2, 3].size',
                    'Use `!empty?` instead of `0 != size`.',
                    '![1, 2, 3].empty?'
  end

  context 'with hashes' do
    it_behaves_like 'code with offense', '{ a: 1, b: 2 }.size == 0',
                    'Use `empty?` instead of `size == 0`.',
                    '{ a: 1, b: 2 }.empty?'
    it_behaves_like 'code with offense', '0 == { a: 1, b: 2 }.size',
                    'Use `empty?` instead of `0 == size`.',
                    '{ a: 1, b: 2 }.empty?'

    it_behaves_like 'code with offense', '{ a: 1, b: 2 }.size != 0',
                    'Use `!empty?` instead of `size != 0`.',
                    '!{ a: 1, b: 2 }.empty?'
    it_behaves_like 'code with offense', '0 != { a: 1, b: 2 }.size',
                    'Use `!empty?` instead of `0 != size`.',
                    '!{ a: 1, b: 2 }.empty?'
  end

  context 'with strings' do
    it_behaves_like 'code with offense', '"string".size == 0',
                    'Use `empty?` instead of `size == 0`.',
                    '"string".empty?'
    it_behaves_like 'code with offense', '0 == "string".size',
                    'Use `empty?` instead of `0 == size`.',
                    '"string".empty?'

    it_behaves_like 'code with offense', '"string".size != 0',
                    'Use `!empty?` instead of `size != 0`.',
                    '!"string".empty?'
    it_behaves_like 'code with offense', '0 != "string".size',
                    'Use `!empty?` instead of `0 != size`.',
                    '!"string".empty?'
  end

  context 'with collection variables' do
    it_behaves_like 'code with offense', 'collection.size == 0',
                    'Use `empty?` instead of `size == 0`.',
                    'collection.empty?'
    it_behaves_like 'code with offense', '0 == collection.size',
                    'Use `empty?` instead of `0 == size`.',
                    'collection.empty?'

    it_behaves_like 'code with offense', 'collection.size != 0',
                    'Use `!empty?` instead of `size != 0`.',
                    '!collection.empty?'
    it_behaves_like 'code with offense', '0 != collection.size',
                    'Use `!empty?` instead of `0 != size`.',
                    '!collection.empty?'
  end

  context 'when name of the variable is `size` or `length`' do
    it_behaves_like 'code without offense', 'size == 0'
    it_behaves_like 'code without offense', 'length == 0'

    it_behaves_like 'code without offense', '0 == size'
    it_behaves_like 'code without offense', '0 == length'

    it_behaves_like 'code without offense', 'size <= 0'
    it_behaves_like 'code without offense', 'length > 0'

    it_behaves_like 'code without offense', '0 <= size'
    it_behaves_like 'code without offense', '0 > length'

    it_behaves_like 'code without offense', 'size != 0'
    it_behaves_like 'code without offense', 'length != 0'

    it_behaves_like 'code without offense', '0 != size'
    it_behaves_like 'code without offense', '0 != length'
  end
end
