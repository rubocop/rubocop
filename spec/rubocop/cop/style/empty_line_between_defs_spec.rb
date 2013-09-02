# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    module Style
      describe EmptyLineBetweenDefs do
        let(:empty_lines) { EmptyLineBetweenDefs.new }
        before do
          EmptyLineBetweenDefs.config = { 'AllowAdjacentOneLineDefs' => false }
        end

        it 'finds offences in inner classes' do
          inspect_source(empty_lines, ['class K',
                                       '  def m',
                                       '  end',
                                       '  class J',
                                       '    def n',
                                       '    end',
                                       '    def o',
                                       '    end',
                                       '  end',
                                       '  # checks something',
                                       '  def p',
                                       '  end',
                                       'end'])
          expect(empty_lines.offences.size).to eq(1)
          expect(empty_lines.offences.map(&:line).sort).to eq([7])
        end

        # Only one def, so rule about empty line *between* defs does not
        # apply.
        it 'accepts a def that follows a line with code' do
          inspect_source(empty_lines, ['x = 0',
                                       'def m',
                                       'end'])
          expect(empty_lines.offences).to be_empty
        end

        # Only one def, so rule about empty line *between* defs does not
        # apply.
        it 'accepts a def that follows code and a comment' do
          inspect_source(empty_lines, ['  x = 0',
                                       '  # 123',
                                       '  def m',
                                       '  end'])
          expect(empty_lines.offences).to be_empty
        end

        it 'accepts the first def without leading empty line in a class' do
          inspect_source(empty_lines, ['class K',
                                       '  def m',
                                       '  end',
                                       'end'])
          expect(empty_lines.offences).to be_empty
        end

        it 'accepts a def that follows an empty line and then a comment' do
          inspect_source(empty_lines, ['class A',
                                       '  # calculates value',
                                       '  def m',
                                       '  end',
                                       '',
                                       '  private',
                                       '  # calculates size',
                                       '  def n',
                                       '  end',
                                       'end',
                                      ])
          expect(empty_lines.offences).to be_empty
        end

        it 'accepts a def that is the first of a module' do
          source = ['module Util',
                    '  public',
                    '  #',
                    '  def html_escape(s)',
                    '  end',
                    'end',
                   ]
          inspect_source(empty_lines, source)
          expect(empty_lines.messages).to be_empty
        end

        it 'accepts a nested def' do
          source = ['def mock_model(*attributes)',
                    '  Class.new do',
                    '    def initialize(attrs)',
                    '    end',
                    '  end',
                    'end',
                   ]
          inspect_source(empty_lines, source)
          expect(empty_lines.messages).to be_empty
        end

        describe 'AllowAdjacentOneLineDefs config parameter' do
          it 'registers an offence for adjacent one-liners by default' do
            source = ['def a; end',
                      'def b; end']
            inspect_source(empty_lines, source)
            expect(empty_lines.offences).to have(1).item
          end

          it 'accepts adjacent one-liners if so configured' do
            EmptyLineBetweenDefs.config = {
              'AllowAdjacentOneLineDefs' => true
            }
            source = ['def a; end',
                      'def b; end']
            inspect_source(empty_lines, source)
            expect(empty_lines.offences).to be_empty
          end

          it 'registers an offence for adjacent defs if some are multi-line' do
            EmptyLineBetweenDefs.config = {
              'AllowAdjacentOneLineDefs' => true
            }
            source = ['def a; end',
                      'def b; end',
                      'def c', # Not a one-liner, so this is an offence.
                      'end',
                      # Also an offence since previous was multi-line:
                      'def d; end'
                     ]
            inspect_source(empty_lines, source)
            expect(empty_lines.offences.map(&:line)).to eq([3, 5])
          end
        end
      end
    end
  end
end
