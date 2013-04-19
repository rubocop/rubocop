# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe EnsureReturn do
      let(:er) { EnsureReturn.new }

      it 'registers an offence for return in ensure' do
        inspect_source(er,
                       'file.rb',
                       ['begin',
                        '  something',
                        'ensure',
                        '  file.close',
                        '  return',
                        'end'])
        expect(er.offences.size).to eq(1)
        expect(er.offences.map(&:message))
          .to eq([EnsureReturn::ERROR_MESSAGE])
      end

      it 'does not register an offence for return outside ensure' do
        inspect_source(er,
                       'file.rb',
                       ['begin',
                        '  something',
                        '  return',
                        'ensure',
                        '  file.close',
                        'end'])
        expect(er.offences).to be_empty
      end
    end
  end
end
