# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    module Lint
      describe AssignmentInCondition do
        let(:cond_asgn) { AssignmentInCondition.new }

        it 'registers an offence for lvar assignment in condition' do
          inspect_source(cond_asgn,
                         ['if test = 10',
                          'end'
                         ])
          expect(cond_asgn.offences.size).to eq(1)
        end

        it 'registers an offence for lvar assignment in while condition' do
          inspect_source(cond_asgn,
                         ['while test = 10',
                          'end'
                         ])
          expect(cond_asgn.offences.size).to eq(1)
        end

        it 'registers an offence for lvar assignment in until condition' do
          inspect_source(cond_asgn,
                         ['until test = 10',
                          'end'
                         ])
          expect(cond_asgn.offences.size).to eq(1)
        end

        it 'registers an offence for ivar assignment in condition' do
          inspect_source(cond_asgn,
                         ['if @test = 10',
                          'end'
                         ])
          expect(cond_asgn.offences.size).to eq(1)
        end

        it 'registers an offence for clvar assignment in condition' do
          inspect_source(cond_asgn,
                         ['if @@test = 10',
                          'end'
                         ])
          expect(cond_asgn.offences.size).to eq(1)
        end

        it 'registers an offence for gvar assignment in condition' do
          inspect_source(cond_asgn,
                         ['if $test = 10',
                          'end'
                         ])
          expect(cond_asgn.offences.size).to eq(1)
        end

        it 'registers an offence for constant assignment in condition' do
          inspect_source(cond_asgn,
                         ['if TEST = 10',
                          'end'
                         ])
          expect(cond_asgn.offences.size).to eq(1)
        end

        it 'accepts == in condition' do
          inspect_source(cond_asgn,
                         ['if test == 10',
                          'end'
                         ])
          expect(cond_asgn.offences).to be_empty
        end

        it 'accepts ||= in condition' do
          inspect_source(cond_asgn,
                         ['raise StandardError unless foo ||= bar'])
          expect(cond_asgn.offences).to be_empty
        end
      end
    end
  end
end
