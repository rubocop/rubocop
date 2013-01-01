# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe UnnecessaryThen do
      let (:un_then) { UnnecessaryThen.new }

      # if

      it 'registers an offence for then in multiline if' do
        inspect_source(un_then, '', ['if cond then',
                                     'end',
                                     "if cond then\t",
                                     'end',
                                     "if cond then  ",
                                     'end',
                                     'if cond then # bad',
                                     'end'])
        un_then.offences.size.should == 4
      end

      it 'accepts multiline if without then' do
        inspect_source(un_then, '', ['if cond',
                                     'end'])
        un_then.offences.map(&:message).sort.should == []
      end

      it 'accepts one line if/then/ends' do
        inspect_source(un_then, '', ['if cond then run end'])
        un_then.offences.map(&:message).sort.should == []
      end

      it 'accepts table style if/then/elsif/ends' do
        inspect_source(un_then, '',
                       ['if    @io == $stdout then str << "$stdout"',
                        'elsif @io == $stdin  then str << "$stdin"',
                        'elsif @io == $stderr then str << "$stderr"',
                        'else                      str << @io.class.to_s',
                        'end'])
        un_then.offences.map(&:message).sort.should == []
      end

      # unless

      it 'registers an offence for then in multiline unless' do
        inspect_source(un_then, '', ['unless cond then',
                                     'end'])
        un_then.offences.map(&:message).sort.should ==
          ['Never use then for multi-line if/unless.']
      end

      it 'accepts multiline unless without then' do
        inspect_source(un_then, '', ['unless cond',
                                     'end'])
        un_then.offences.map(&:message).sort.should == []
      end

      it 'accepts one line unless/then/ends' do
        inspect_source(un_then, '', ['unless cond then run end'])
        un_then.offences.map(&:message).sort.should == []
      end
    end
  end
end
