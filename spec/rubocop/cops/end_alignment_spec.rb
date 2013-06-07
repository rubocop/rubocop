# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe EndAlignment do
      let(:end_align) { EndAlignment.new }

      it 'registers an offence for mismatched class end' do
        inspect_source(end_align,
                       ['class Test',
                        '  end'
                       ])
        expect(end_align.offences.size).to eq(1)
      end

      it 'registers an offence for mismatched module end' do
        inspect_source(end_align,
                       ['module Test',
                        '  end'
                       ])
        expect(end_align.offences.size).to eq(1)
      end

      it 'registers an offence for mismatched def end' do
        inspect_source(end_align,
                       ['def test',
                        '  end'
                       ])
        expect(end_align.offences.size).to eq(1)
      end

      it 'registers an offence for mismatched defs end' do
        inspect_source(end_align,
                       ['def Test.test',
                        '  end'
                       ])
        expect(end_align.offences.size).to eq(1)
      end

      it 'registers an offence for mismatched if end' do
        inspect_source(end_align,
                       ['if test',
                        '  end'
                       ])
        expect(end_align.offences.size).to eq(1)
      end

      it 'registers an offence for mismatched while end' do
        inspect_source(end_align,
                       ['while test',
                        '  end'
                       ])
        expect(end_align.offences.size).to eq(1)
      end

      it 'registers an offence for mismatched until end' do
        inspect_source(end_align,
                       ['until test',
                        '  end'
                       ])
        expect(end_align.offences.size).to eq(1)
      end

      it 'registers an offence for mismatched block end' do
        pending
        inspect_source(end_align,
                       ['test do |ala|',
                        '  end'
                       ])
        expect(end_align.offences.size).to eq(1)
      end
    end
  end
end
