# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe EmptyLineBetweenDefs do
      let(:empty_lines) { EmptyLineBetweenDefs.new }

      it 'finds offences in inner classes' do
        inspect_source(empty_lines, '', ['class K',
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
        expect(empty_lines.offences.size).to eq(2)
        expect(empty_lines.offences.map(&:line_number).sort).to eq([7, 11])
      end

      # Only one def, so rule about empty line *between* defs does not
      # apply.
      it 'accepts a def that follows a line with code' do
        inspect_source(empty_lines, '', ['x = 0',
                                        'def m',
                                        'end'])
        expect(empty_lines.offences).to be_empty
      end

      # Only one def, so rule about empty line *between* defs does not
      # apply.
      it 'accepts a def that follows code and a comment' do
        inspect_source(empty_lines, '', ['  x = 0',
                                        '  # 123',
                                        '  def m',
                                        '  end'])
        expect(empty_lines.offences).to be_empty
      end

      it 'accepts the first def without leading empty line in a class' do
        inspect_source(empty_lines, '', ['class K',
                                        '  def m',
                                        '  end',
                                        'end'])
        expect(empty_lines.offences).to be_empty
      end

      it 'accepts a def that follows an empty line and then a comment' do
        inspect_source(empty_lines, '', ['class A',
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
        inspect_source(empty_lines, '', source)
        expect(empty_lines.offences.map(&:message)).to be_empty
      end
    end
  end
end
