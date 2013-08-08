# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    module Style
      describe AvoidGlobalVars do
        let(:cop) { AvoidGlobalVars.new }

        it 'registers an offence for $custom' do
          inspect_source(cop, ['puts $custom'])
          expect(cop.offences.size).to eq(1)
        end

        AvoidGlobalVars::BUILT_IN_VARS.each do |var|
          it "does not register an offence for built-in variable #{var}" do
            inspect_source(cop, ["puts #{var}"])
            expect(cop.offences).to be_empty
          end
        end

        it 'does not register an offence for backrefs like $1' do
          inspect_source(cop, ['puts $1'])
          expect(cop.offences).to be_empty
        end
      end
    end
  end
end
