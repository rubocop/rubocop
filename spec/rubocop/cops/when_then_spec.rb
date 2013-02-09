# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe WhenThen do
      let (:wt) { WhenThen.new }

      it 'registers an offence for when x;' do
        inspect_source(wt, 'file.rb', ['case a',
                                       'when b; c',
                                       'end'])
        wt.offences.map(&:message).should ==
          ['Never use "when x;". Use "when x then" instead.']
      end

      it 'accepts when x then' do
        inspect_source(wt, 'file.rb', ['case a',
                                       'when b then c',
                                       'end'])
        wt.offences.map(&:message).should == []
      end

      it 'accepts ; separating statements in the body of when' do
        inspect_source(wt, 'file.rb', ['case a',
                                       'when b then c; d',
                                       'end',
                                       '',
                                       'case e',
                                       'when f',
                                       '  g; h',
                                       'end'])
        wt.offences.map(&:message).should == []
      end
    end
  end
end
