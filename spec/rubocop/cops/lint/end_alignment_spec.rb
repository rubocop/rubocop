# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    module Lint
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
          inspect_source(end_align,
                         ['test do |ala|',
                          '  end'
                         ])
          expect(end_align.offences.size).to eq(1)
        end

        context 'align the end to the beginning of the line when' do
          it 'block is assigned to a variable' do
            inspect_source(end_align,
                           ['variable = test do |ala|',
                            'end'
                           ])
            expect(end_align.offences.size).to eq(0)
            inspect_source(end_align,
                           ['variable = test do |ala|',
                            '  end'
                           ])
            expect(end_align.offences.size).to eq(1)
          end

          it 'block is assigned to an instance variable' do
            inspect_source(end_align,
                           ['@variable = test do |ala|',
                            'end'
                           ])
            expect(end_align.offences.size).to eq(0)
            inspect_source(end_align,
                           ['@variable = test do |ala|',
                            '  end'
                           ])
            expect(end_align.offences.size).to eq(1)
          end

          it 'block is assigned to a class variable' do
            inspect_source(end_align,
                           ['@@variable = test do |ala|',
                            'end'
                           ])
            expect(end_align.offences.size).to eq(0)
            inspect_source(end_align,
                           ['@@variable = test do |ala|',
                            '  end'
                           ])
            expect(end_align.offences.size).to eq(1)
          end

          it 'block is assigned to a global variable' do
            inspect_source(end_align,
                           ['$variable = test do |ala|',
                            'end'
                           ])
            expect(end_align.offences.size).to eq(0)
            inspect_source(end_align,
                           ['$variable = test do |ala|',
                            '  end'
                           ])
            expect(end_align.offences.size).to eq(1)
          end

          it 'block is assigned to a constant' do
            inspect_source(end_align,
                           ['CONSTANT = test do |ala|',
                            'end'
                           ])
            expect(end_align.offences.size).to eq(0)
            inspect_source(end_align,
                           ['Module::CONSTANT = test do |ala|',
                            '  end'
                           ])
            expect(end_align.offences.size).to eq(1)
          end

          it 'block is assigned to object method' do
            inspect_source(end_align,
                           ['parser.child.consumer = lambda do |token|',
                            '  token << 1',
                            'end'
                           ])
            expect(end_align.offences.size).to eq(0)

            inspect_source(end_align,
                           ['parser.child.consumer = lambda do |token|',
                            '  token << 1',
                            '  end'
                           ])
            expect(end_align.offences.size).to eq(1)
          end

          it 'block is used with op-asgn (+=, etc)' do
            inspect_source(end_align,
                           ['rb += files.select do |file|',
                            '  file << something',
                            'end'
                           ])
            expect(end_align.offences.size).to eq(0)
            inspect_source(end_align,
                           ['rb += files.select do |file|',
                            '  file << something',
                            '  end'
                           ])
            expect(end_align.offences.size).to eq(1)
          end

          it 'block is assigned with and-asgn (&&=)' do
            inspect_source(end_align,
                           ['variable &&= test do |ala|',
                            'end'
                           ])
            expect(end_align.offences.size).to eq(0)
            inspect_source(end_align,
                           ['variable &&= test do |ala|',
                            '  end'
                           ])
            expect(end_align.offences.size).to eq(1)
          end

          it 'block is assigned with or-asgn (||=)' do
            inspect_source(end_align,
                           ['variable ||= test do |ala|',
                            'end'
                           ])
            expect(end_align.offences.size).to eq(0)
            inspect_source(end_align,
                           ['variable ||= test do |ala|',
                            '  end'
                           ])
            expect(end_align.offences.size).to eq(1)
          end
        end
      end
    end
  end
end
