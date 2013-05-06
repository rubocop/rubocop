# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe AvoidGlobalVars do
      let(:ap) { AvoidGlobalVars.new }

      it 'registers an offence for $custom' do
        inspect_source(ap, 'file.rb', ['puts $custom'])
        expect(ap.offences.size).to eq(1)
      end

      it 'does not register an offence for $"' do
        inspect_source(ap, 'file.rb', ['puts $"'])

        expect(ap.offences).to be_empty
      end

      it 'does not register an offence for $ORS' do
        inspect_source(ap, 'file.rb', ['puts $0'])
        expect(ap.offences).to be_empty
      end

      it 'does not register an offence for backrefs like $1' do
        inspect_source(ap, 'file.rb', ['puts $1'])
        expect(ap.offences).to be_empty
      end
    end
  end
end
