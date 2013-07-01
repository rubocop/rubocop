# encoding: utf-8
# rubocop:disable LineLength

require 'spec_helper'

module Rubocop
  module Cop
    module Lint
      describe EndAlignment do
        let(:cop) { EndAlignment.new }
        before do
          # TODO: Initialize the config to a default {} value. Currently it's nil.
          EndAlignment.config = {}
        end

        it 'registers an offence for mismatched class end' do
          inspect_source(cop,
                         ['class Test',
                          '  end'
                         ])
          expect(cop.offences.size).to eq(1)
        end

        it 'registers an offence for mismatched module end' do
          inspect_source(cop,
                         ['module Test',
                          '  end'
                         ])
          expect(cop.offences.size).to eq(1)
        end

        it 'registers an offence for mismatched def end' do
          inspect_source(cop,
                         ['def test',
                          '  end'
                         ])
          expect(cop.offences.size).to eq(1)
        end

        it 'registers an offence for mismatched defs end' do
          inspect_source(cop,
                         ['def Test.test',
                          '  end'
                         ])
          expect(cop.offences.size).to eq(1)
        end

        it 'registers an offence for mismatched if end' do
          inspect_source(cop,
                         ['if test',
                          '  end'
                         ])
          expect(cop.offences.size).to eq(1)
        end

        it 'registers an offence for mismatched while end' do
          inspect_source(cop,
                         ['while test',
                          '  end'
                         ])
          expect(cop.offences.size).to eq(1)
        end

        it 'registers an offence for mismatched until end' do
          inspect_source(cop,
                         ['until test',
                          '  end'
                         ])
          expect(cop.offences.size).to eq(1)
        end

        it 'registers an offence for mismatched block end' do
          inspect_source(cop,
                         ['test do |ala|',
                          '  end'
                         ])
          expect(cop.offences.size).to eq(1)
        end

        context 'when the block is a logical operand' do
          it 'accepts a correctly aligned block end' do
            inspect_source(cop,
                           ['(value.is_a? Array) && value.all? do |subvalue|',
                            '  type_check_value(subvalue, array_type)',
                            'end',
                            'a || b do',
                            'end',
                           ])
            expect(cop.offences).to be_empty
          end
        end

        context 'with BlockAlignSchema set to StartOfAssignment' do
          before do
            EndAlignment.config = { 'BlockAlignSchema' => 'StartOfAssignment' }
          end

          it 'accepts end aligned with a variable' do
            inspect_source(cop,
                           ['variable = test do |ala|',
                            'end'
                           ])
            expect(cop.offences).to be_empty
          end

          context 'and the block is an operand' do
            it 'accepts end aligned with a variable' do
              inspect_source(cop,
                             ['b = 1 + preceding_line.reduce(0) do |a, e|',
                              '  a + e.length + newline_length',
                              'end + 1'
                             ])
              expect(cop.offences).to be_empty
            end
          end

          it 'registers an offence for mismatched block end with a variable' do
            inspect_source(cop,
                           ['variable = test do |ala|',
                            '  end'
                           ])
            expect(cop.offences.size).to eq(1)
          end

          it 'accepts end aligned with an instance variable' do
            inspect_source(cop,
                           ['@variable = test do |ala|',
                            'end'
                           ])
            expect(cop.offences).to be_empty
          end

          it 'registers an offence for mismatched block end with an instance variable' do
            inspect_source(cop,
                           ['@variable = test do |ala|',
                            '  end'
                           ])
            expect(cop.offences.size).to eq(1)
          end

          it 'accepts end aligned with a class variable' do
            inspect_source(cop,
                           ['@@variable = test do |ala|',
                            'end'
                           ])
            expect(cop.offences).to be_empty
          end

          it 'registers an offence for mismatched block end with a class variable' do
            inspect_source(cop,
                           ['@@variable = test do |ala|',
                            '  end'
                           ])
            expect(cop.offences.size).to eq(1)
          end

          it 'accepts end aligned with a global variable' do
            inspect_source(cop,
                           ['$variable = test do |ala|',
                            'end'
                           ])
            expect(cop.offences).to be_empty
          end

          it 'registers an offence for mismatched block end with a global variable' do
            inspect_source(cop,
                           ['$variable = test do |ala|',
                            '  end'
                           ])
            expect(cop.offences.size).to eq(1)
          end

          it 'accepts end aligned with a constant' do
            inspect_source(cop,
                           ['CONSTANT = test do |ala|',
                            'end'
                           ])
            expect(cop.offences).to be_empty
          end

          it 'registers an offence for mismatched block end with a constant' do
            inspect_source(cop,
                           ['Module::CONSTANT = test do |ala|',
                            '  end'
                           ])
            expect(cop.offences.size).to eq(1)
          end

          it 'accepts end aligned with an attribute writer method' do
            inspect_source(cop,
                           ['parser.child.consumer = lambda do |token|',
                            '  token << 1',
                            'end'
                           ])
            expect(cop.offences).to be_empty
          end

          it 'registers an offence for mismatched block end with an attribute writer method' do
            inspect_source(cop,
                           ['parser.child.consumer = lambda do |token|',
                            '  token << 1',
                            '  end'
                           ])
            expect(cop.offences.size).to eq(1)
          end

          it 'accepts end aligned with an op-asgn (+=, -=)' do
            inspect_source(cop,
                           ['rb += files.select do |file|',
                            '  file << something',
                            'end'
                           ])
            expect(cop.offences).to be_empty
          end

          it 'registers an offence for mismatched block end with an op-asgn (+=, -=)' do
            inspect_source(cop,
                           ['rb += files.select do |file|',
                            '  file << something',
                            '  end'
                           ])
            expect(cop.offences.size).to eq(1)
          end

          it 'accepts end aligned with an and-asgn (&&=)' do
            inspect_source(cop,
                           ['variable &&= test do |ala|',
                            'end'
                           ])
            expect(cop.offences).to be_empty
          end

          it 'registers an offence for mismatched block end with an and-asgn (&&=)' do
            inspect_source(cop,
                           ['variable &&= test do |ala|',
                            '  end'
                           ])
            expect(cop.offences.size).to eq(1)
          end

          it 'accepts end aligned with an or-asgn (||=)' do
            inspect_source(cop,
                           ['variable ||= test do |ala|',
                            'end'
                           ])
            expect(cop.offences).to be_empty
          end

          it 'registers an offence for mismatched block end with an or-asgn (||=)' do
            inspect_source(cop,
                           ['variable ||= test do |ala|',
                            '  end'
                           ])
            expect(cop.offences.size).to eq(1)
          end

          it 'accepts end aligned with a mass assignment' do
            inspect_source(cop,
                           ['var1, var2 = lambda do |test|',
                            '  [1, 2]',
                            'end'
                           ])
            expect(cop.offences).to be_empty
          end

          it 'registers an offence for mismatched block end with a mass assignment' do
            inspect_source(cop,
                           ['var1, var2 = lambda do |test|',
                            '  [1, 2]',
                            '  end'
                           ])
            expect(cop.offences.size).to eq(1)
          end
        end

        context 'with BlockAlignSchema set to StartOfBlockCommand' do
          before do
            EndAlignment.config = { 'BlockAlignSchema' => 'StartOfBlockCommand' }
          end

          it 'accepts end aligned with the method that invokes the block' do
            inspect_source(cop,
                           ['variable = test do |ala|',
                            '           end'
                           ])
            expect(cop.offences).to be_empty
          end

          context 'and the block is an operand' do
            it 'accepts end aligned with a variable' do
              inspect_source(cop,
                             ['b = 1 + preceding_line.reduce(0) do |a, e|',
                              '          a + e',
                              '        end + 1'
                             ])
              expect(cop.offences).to be_empty
            end
          end

          it 'registers an offence for mismatched block end with the method that invokes the block' do
            inspect_source(cop,
                           ['variable = test do |ala|',
                            'end'
                           ])
            expect(cop.offences.size).to eq(1)
          end

          it 'accepts end aligned with the method when return value is assigned to instance variable' do
            inspect_source(cop,
                           ['@variable = test do |ala|',
                            '            end'
                           ])
            expect(cop.offences).to be_empty
          end

          it 'registers an offence for mismatched block end when return value is assigned to instance variable' do
            inspect_source(cop,
                           ['@variable = test do |ala|',
                            'end'
                           ])
            expect(cop.offences.size).to eq(1)
          end

          it 'accepts end aligned with the method when return value is assigned to class variable' do
            inspect_source(cop,
                           ['@@variable = test do |ala|',
                            '             end'
                           ])
            expect(cop.offences).to be_empty
          end

          it 'registers an offence for mismatched block end when return value is assigned to class variable' do
            inspect_source(cop,
                           ['@@variable = test do |ala|',
                            'end'
                           ])
            expect(cop.offences.size).to eq(1)
          end

          it 'accepts end aligned with the method when return value is assigned to global variable' do
            inspect_source(cop,
                           ['$variable = test do |ala|',
                            '            end'
                           ])
            expect(cop.offences).to be_empty
          end

          it 'registers an offence for mismatched block end when return value is assigned to global variable' do
            inspect_source(cop,
                           ['$variable = test do |ala|',
                            'end'
                           ])
            expect(cop.offences.size).to eq(1)
          end

          it 'accepts end aligned with the method when return value is assigned to constant' do
            inspect_source(cop,
                           ['CONSTANT = test do |ala|',
                            '           end'
                           ])
            expect(cop.offences).to be_empty
          end

          it 'registers an offence for mismatched block end when return value is assigned to constant' do
            inspect_source(cop,
                           ['Module::CONSTANT = test do |ala|',
                            'end'
                           ])
            expect(cop.offences.size).to eq(1)
          end

          it 'accepts end aligned with the method when return value is assigned to attribute writer method' do
            inspect_source(cop,
                           ['parser.child.consumer = lambda do |token|',
                            '                          token << 1',
                            '                        end'
                           ])
            expect(cop.offences).to be_empty
          end

          it 'registers an offence for mismatched block end when return value is assigned to attribute writer method' do
            inspect_source(cop,
                           ['parser.child.consumer = lambda do |token|',
                            '  token << 1',
                            'end'
                           ])
            expect(cop.offences.size).to eq(1)
          end

          it 'accepts end aligned with the method when return value is assigned using op-asgn (+=, -=)' do
            inspect_source(cop,
                           ['rb += files.select do |file|',
                            '        file << something',
                            '      end'
                           ])
            expect(cop.offences).to be_empty
          end

          it 'registers an offence for mismatched block end when return value is assigned using op-asgn (+=, -=)' do
            inspect_source(cop,
                           ['rb += files.select do |file|',
                            '  file << something',
                            'end'
                           ])
            expect(cop.offences.size).to eq(1)
          end

          it 'accepts end aligned with the method when return value is assigned using and-asgn (&&=)' do
            inspect_source(cop,
                           ['variable &&= test do |ala|',
                            '             end'
                           ])
            expect(cop.offences).to be_empty
          end

          it 'registers an offence for mismatched block end when return value is assigned using and-asgn (&&=)' do
            inspect_source(cop,
                           ['variable &&= test do |ala|',
                            'end'
                           ])
            expect(cop.offences.size).to eq(1)
          end

          it 'accepts end aligned with the method when return value is assigned using or-asgn (||=)' do
            inspect_source(cop,
                           ['variable ||= test do |ala|',
                            '             end'
                           ])
            expect(cop.offences).to be_empty
          end

          it 'registers an offence for mismatched block end when return value is assigned using or-asgn (||=)' do
            inspect_source(cop,
                           ['variable ||= test do |ala|',
                            'end'
                           ])
            expect(cop.offences.size).to eq(1)
          end

          it 'accepts end aligned with the method when return value is assigned using mass assignment' do
            inspect_source(cop,
                           ['var1, var2 = lambda do |test|',
                            '               [1, 2]',
                            '             end'
                           ])
            expect(cop.offences).to be_empty
          end

          it 'registers an offence for mismatched block end when return value is assigned using mass assignment' do
            inspect_source(cop,
                           ['var1, var2 = lambda do |test|',
                            '  [1, 2]',
                            'end'
                           ])
            expect(cop.offences.size).to eq(1)
          end
        end
      end
    end
  end
end
