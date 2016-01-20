# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::ZeroLengthPredicate do
  subject(:cop) { described_class.new }

  before do
    inspect_source(cop, source)
  end

  context 'when checking for 0 length' do
    context 'when receiver is 0' do
      context 'when sender is a length' do
        let(:source) { '[1, 2, 3].length == 0' }

        it 'registers an offense' do
          expect(cop.offenses.size).to eq(1)
          expect(cop.offenses.first.message).to eq(
            'Use `empty?` instead of `length == 0`.'
          )
          expect(cop.highlights).to eq(['[1, 2, 3].length == 0'])
        end
      end

      context 'when sender is a size' do
        let(:source) { '[1, 2, 3].size == 0' }

        it 'registers an offense' do
          expect(cop.offenses.size).to eq(1)
          expect(cop.offenses.first.message).to eq(
            'Use `empty?` instead of `size == 0`.'
          )
          expect(cop.highlights).to eq(['[1, 2, 3].size == 0'])
        end
      end
    end

    context 'when sender is 0' do
      context 'when receiver is a length' do
        let(:source) { '0 == [1, 2, 3].length' }

        it 'registers an offense' do
          expect(cop.offenses.size).to eq(1)
          expect(cop.offenses.first.message).to eq(
            'Use `empty?` instead of `length == 0`.'
          )
          expect(cop.highlights).to eq(['0 == [1, 2, 3].length'])
        end
      end

      context 'when receiver is a size' do
        let(:source) { '0 == [1, 2, 3].size' }

        it 'registers an offense' do
          expect(cop.offenses.size).to eq(1)
          expect(cop.offenses.first.message).to eq(
            'Use `empty?` instead of `size == 0`.'
          )
          expect(cop.highlights).to eq(['0 == [1, 2, 3].size'])
        end
      end
    end
  end

  context 'when checking for non-0 length' do
    context 'when receiver is 0' do
      context 'when sender is a length' do
        context 'when comparing using >' do
          let(:source) { '[1, 2, 3].length > 0' }

          it 'registers an offense' do
            expect(cop.offenses.size).to eq(1)
            expect(cop.offenses.first.message).to eq(
              'Use `!empty?` instead of `length > 0`.'
            )
            expect(cop.highlights).to eq(['[1, 2, 3].length > 0'])
          end
        end

        context 'when comparing using !=' do
          let(:source) { '[1, 2, 3].length != 0' }

          it 'registers an offense' do
            expect(cop.offenses.size).to eq(1)
            expect(cop.offenses.first.message).to eq(
              'Use `!empty?` instead of `length != 0`.'
            )
            expect(cop.highlights).to eq(['[1, 2, 3].length != 0'])
          end
        end
      end

      context 'when sender is a size' do
        context 'when comparing using >' do
          let(:source) { '[1, 2, 3].size > 0' }

          it 'registers an offense' do
            expect(cop.offenses.size).to eq(1)
            expect(cop.offenses.first.message).to eq(
              'Use `!empty?` instead of `size > 0`.'
            )
            expect(cop.highlights).to eq(['[1, 2, 3].size > 0'])
          end
        end

        context 'when comparing using !=' do
          let(:source) { '[1, 2, 3].size != 0' }

          it 'registers an offense' do
            expect(cop.offenses.size).to eq(1)
            expect(cop.offenses.first.message).to eq(
              'Use `!empty?` instead of `size != 0`.'
            )
            expect(cop.highlights).to eq(['[1, 2, 3].size != 0'])
          end
        end
      end
    end

    context 'when sender is 0' do
      context 'when receiver is a length' do
        context 'when comparing using <' do
          let(:source) { ' 0 < [1, 2, 3].length' }

          it 'registers an offense' do
            expect(cop.offenses.size).to eq(1)
            expect(cop.offenses.first.message).to eq(
              'Use `!empty?` instead of `0 < length`.'
            )
            expect(cop.highlights).to eq(['0 < [1, 2, 3].length'])
          end
        end

        context 'when comparing using !=' do
          let(:source) { '0 != [1, 2, 3].length' }

          it 'registers an offense' do
            expect(cop.offenses.size).to eq(1)
            expect(cop.offenses.first.message).to eq(
              'Use `!empty?` instead of `0 != length`.'
            )
            expect(cop.highlights).to eq(['0 != [1, 2, 3].length'])
          end
        end
      end

      context 'when receiver is a size' do
        context 'when comparing using <' do
          let(:source) { '0 < [1, 2, 3].size' }

          it 'registers an offense' do
            expect(cop.offenses.size).to eq(1)
            expect(cop.offenses.first.message).to eq(
              'Use `!empty?` instead of `0 < size`.'
            )
            expect(cop.highlights).to eq(['0 < [1, 2, 3].size'])
          end
        end

        context 'when comparing using !=' do
          let(:source) { '0 != [1, 2, 3].size' }

          it 'registers an offense' do
            expect(cop.offenses.size).to eq(1)
            expect(cop.offenses.first.message).to eq(
              'Use `!empty?` instead of `0 != size`.'
            )
            expect(cop.highlights).to eq(['0 != [1, 2, 3].size'])
          end
        end
      end
    end
  end
end
