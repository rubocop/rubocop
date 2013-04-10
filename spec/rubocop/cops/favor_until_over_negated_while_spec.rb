# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe FavorUntilOverNegatedWhile do
      let(:fav_until) { FavorUntilOverNegatedWhile.new }

      it 'registers an offence for while with exclamation point condition' do
        inspect_source(fav_until, 'file.rb',
                       ['while !a_condition',
                        '  some_method',
                        'end',
                        'some_method while !a_condition',
                       ])
        expect(fav_until.offences.map(&:message)).to eq(
          ['Favor until over while for negative conditions.'] * 2)
      end

      it 'registers an offence for while with "not" condition' do
        inspect_source(fav_until, 'file.rb',
                       ['while (not a_condition)',
                        '  some_method',
                        'end',
                        'some_method while not a_condition'])
        expect(fav_until.offences.map(&:message)).to eq(
          ['Favor until over while for negative conditions.'] * 2)
        expect(fav_until.offences.map(&:line_number)).to eq([1, 4])
      end

      it 'accepts an while where only part of the contition is negated' do
        inspect_source(fav_until, 'file.rb',
                       ['while !a_condition && another_condition',
                        '  some_method',
                        'end',
                        'while not a_condition or another_condition',
                        '  some_method',
                        'end',
                        'some_method while not a_condition or other_cond'])
        expect(fav_until.offences.map(&:message)).to be_empty
      end
    end
  end
end
