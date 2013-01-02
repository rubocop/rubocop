# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe IfThenElse do
      let (:if_then_else) { IfThenElse.new }

      # if

      it 'registers an offence for then in multiline if' do
        inspect_source(if_then_else, '', ['if cond then',
                                          'end',
                                          "if cond then\t",
                                          'end',
                                          "if cond then  ",
                                          'end',
                                          'if cond then # bad',
                                          'end'])
        if_then_else.offences.size.should == 4
      end

      it 'accepts multiline if without then' do
        inspect_source(if_then_else, '', ['if cond',
                                          'end'])
        if_then_else.offences.map(&:message).sort.should == []
      end

      it 'registers an offence for one line if/then/end' do
        inspect_source(if_then_else, '', ['if cond then run else dont end'])
        if_then_else.offences.map(&:message).sort.should ==
          ['Favor the ternary operator (?:) over if/then/else/end constructs.']
      end

      it 'registers an offence for one line if/;/end' do
        inspect_source(if_then_else, '', ['if cond; run else dont end'])
        if_then_else.offences.map(&:message).sort.should ==
          ['Never use if x; Use the ternary operator instead.']
      end

      it 'accepts table style if/then/elsif/ends' do
        inspect_source(if_then_else, '',
                       ['if    @io == $stdout then str << "$stdout"',
                        'elsif @io == $stdin  then str << "$stdin"',
                        'elsif @io == $stderr then str << "$stderr"',
                        'else                      str << @io.class.to_s',
                        'end'])
        if_then_else.offences.map(&:message).sort.should == []
      end

      # unless

      it 'registers an offence for then in multiline unless' do
        inspect_source(if_then_else, '', ['unless cond then',
                                          'end'])
        if_then_else.offences.map(&:message).sort.should ==
          ['Never use then for multi-line if/unless.']
      end

      it 'accepts multiline unless without then' do
        inspect_source(if_then_else, '', ['unless cond',
                                          'end'])
        if_then_else.offences.map(&:message).sort.should == []
      end

      it 'registers an offence for one line unless/then/ends' do
        inspect_source(if_then_else, '', ['unless cond then run end'])
        if_then_else.offences.map(&:message).sort.should ==
          ['Favor the ternary operator (?:) over if/then/else/end constructs.']
      end
    end
  end
end
