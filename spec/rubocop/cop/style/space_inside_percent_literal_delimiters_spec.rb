# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::SpaceInsidePercentLiteralDelimiters do
  subject(:cop) { described_class.new }

  %w[i I w W x].each do |type|
    [%w[{ }], %w[( )], %w([ ]), %w[! !]].each do |(ldelim, rdelim)|
      context "for #{type} type and #{[ldelim, rdelim]} delimiters" do
        define_method(:example) do |content|
          ['%', type, ldelim, content, rdelim].join
        end

        def expect_corrected(source, expected)
          expect(autocorrect_source(cop, source)).to eq expected
        end

        it 'registers an offense for unnecessary spaces' do
          source = example(' 1 2  ')
          inspect_source(cop, source)
          expect(cop.offenses.size).to eq(2)
          expect(cop.messages.uniq).to eq([described_class::MSG])
          expect(cop.highlights).to eq([' ', '  '])
          expect_corrected(source, example('1 2'))
        end

        it 'registers an offense for spaces after first delimiter' do
          source = example(' 1 2')
          inspect_source(cop, source)
          expect(cop.offenses.size).to eq(1)
          expect_corrected(source, example('1 2'))
        end

        it 'registers an offense for spaces before final delimiter' do
          source = example('1 2 ')
          inspect_source(cop, source)
          expect(cop.offenses.size).to eq(1)
          expect_corrected(source, example('1 2'))
        end

        it 'registers an offense for literals with escaped and other spaces' do
          source = example(' \ a b c\  ')
          inspect_source(cop, source)
          expect(cop.offenses.size).to eq(2)
          expect_corrected(source, example('\ a b c\ '))
        end

        it 'accepts literals without additional spaces' do
          inspect_source(cop, example('a b c'))
          expect(cop.messages).to be_empty
        end

        it 'accepts literals with escaped spaces' do
          inspect_source(cop, example('\ a b c\ '))
          expect(cop.messages).to be_empty
        end

        it 'accepts multi-line literals' do
          inspect_source(cop, ["%#{type}(",
                               '  a',
                               '  b',
                               '  c',
                               ')'])
          expect(cop.messages).to be_empty
        end

        it 'accepts multi-line literals within a method' do
          inspect_source(cop, ['def foo',
                               "  %#{type}(",
                               '    a',
                               '    b',
                               '    c',
                               '  )',
                               'end'])
          expect(cop.messages).to be_empty
        end

        it 'accepts newlines and additional following alignment spaces' do
          inspect_source(cop, ["%#{type}(a b",
                               '   c)'])
          expect(cop.messages).to be_empty
        end

        it 'accepts spaces between entries' do
          inspect_source(cop, example('a  b  c'))
          expect(cop.messages).to be_empty
        end
      end
    end
  end

  it 'accepts other percent literals' do
    %w[q r s].each do |type|
      inspect_source(cop, "%#{type}( a  b c )")
      expect(cop.messages).to be_empty
    end
  end
end
