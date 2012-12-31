# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe EmptyLines do
      let (:empty_lines) { EmptyLines.new }

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
        empty_lines.offences.size.should == 2
        empty_lines.offences.map(&:line).sort.should == ['    def o',
                                                         '  def p']
      end

      # Only one def, so rule about empty line *between* defs does not
      # apply.
      it 'accepts a def that follows a line with code' do
        inspect_source(empty_lines, '', ['x = 0',
                                        'def m',
                                        'end'])
        empty_lines.offences.size.should == 0
      end

      # Only one def, so rule about empty line *between* defs does not
      # apply.
      it 'accepts a def that follows code and a comment' do
        inspect_source(empty_lines, '', ['  x = 0',
                                        '  # 123',
                                        '  def m',
                                        '  end'])
        empty_lines.offences.size.should == 0
      end

      it 'accepts the first def without leading empty line in a class' do
        inspect_source(empty_lines, '', ['class K',
                                        '  def m',
                                        '  end',
                                        'end'])
        empty_lines.offences.size.should == 0
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
        empty_lines.offences.size.should == 0
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
        empty_lines.offences.map(&:message).should == []
      end
    end
  end
end
