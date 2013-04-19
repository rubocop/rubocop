# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe HandleExceptions do
      let(:he) { HandleExceptions.new }

      it 'registers an offence for empty rescue block' do
        inspect_source(he,
                       'file.rb',
                       ['begin',
                        '  something',
                        'rescue',
                        '  #do nothing',
                        'end'])
        expect(he.offences.size).to eq(1)
        expect(he.offences.map(&:message))
          .to eq([HandleExceptions::ERROR_MESSAGE])
      end

      it 'does not register an offence for rescue with body' do
        inspect_source(he,
                       'file.rb',
                       ['begin',
                        '  something',
                        '  return',
                        'rescue',
                        '  file.close',
                        'end'])
        expect(he.offences).to be_empty
      end
    end
  end
end
