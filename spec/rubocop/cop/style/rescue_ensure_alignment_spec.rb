# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::Style::RescueEnsureAlignment do
  subject(:cop) { described_class.new }

  shared_examples 'common behavior' do |keyword|
    context 'bad alignment' do
      it 'registers an offense when used with begin' do
        inspect_source(cop, ['begin',
                             '  something',
                             "    #{keyword}",
                             '    error',
                             'end'])
        expect(cop.messages).to eq(["`#{keyword}` at 3, 4 is not aligned with" \
                                    ' `end` at 5, 0.'])
      end

      it 'registers an offense when used with def' do
        inspect_source(cop, ['def test',
                             '  something',
                             "    #{keyword}",
                             '    error',
                             'end'])
        expect(cop.messages).to eq(["`#{keyword}` at 3, 4 is not aligned with" \
                                    ' `end` at 5, 0.'])
      end

      it 'registers an offense when used with defs' do
        inspect_source(cop, ['def Test.test',
                             '  something',
                             "    #{keyword}",
                             '    error',
                             'end'])
        expect(cop.messages).to eq(["`#{keyword}` at 3, 4 is not aligned with" \
                                    ' `end` at 5, 0.'])
      end

      it 'auto-corrects' do
        corrected = autocorrect_source(cop, ['begin',
                                             '  something',
                                             "    #{keyword}",
                                             '    error',
                                             'end'])
        expect(corrected).to eq ['begin',
                                 '  something',
                                 keyword,
                                 '    error',
                                 'end'].join("\n")
      end
    end

    it 'accepts correct alignment' do
      inspect_source(cop, ['begin',
                           '  something',
                           keyword,
                           '    error',
                           'end'])
      expect(cop.messages).to be_empty
    end
  end

  context 'rescue' do
    it_behaves_like 'common behavior', 'rescue'

    it 'accepts the modifier form' do
      inspect_source(cop, 'test rescue nil')
      expect(cop.messages).to be_empty
    end
  end

  context 'ensure' do
    it_behaves_like 'common behavior', 'ensure'
  end
end
