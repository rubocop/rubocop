# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe PercentR do
      let(:apr) { PercentR.new }

      it 'registers an offence for %r with zero or one slash in regexp' do
        inspect_source(apr, 'file.rb', ['x =~ %r(/home)',
                                        'y =~ %r(etc)'])
        expect(apr.offences.map(&:message))
          .to eq([PercentR::ERROR_MESSAGE] * 2)
      end

      it 'accepts %r with at least two slashes in regexp' do
        inspect_source(apr, 'file.rb', ['x =~ %r(/home/)',
                                        'y =~ %r(/////)'])
        expect(apr.offences.map(&:message)).to be_empty
      end

      it 'accepts slash delimiters for regexp' do
        inspect_source(apr, 'file.rb', ['x =~ /\/home/'])
        expect(apr.offences.map(&:message)).to be_empty
      end
    end
  end
end
