# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe FavorPercentR do
      let(:fpr) { FavorPercentR.new }

      it 'registers an offence for // with two slashes in regexp' do
        inspect_source(fpr, 'file.rb', ['x =~ /home\/\//',
                                        'y =~ /etc\/top\//'])
        expect(fpr.offences.map(&:message))
          .to eq([FavorPercentR::ERROR_MESSAGE] * 2)
      end

      it 'accepts // with only one slash in regexp' do
        inspect_source(fpr, 'file.rb', ['x =~ /\/home/',
                                        'y =~ /\//)'])
        expect(fpr.offences.map(&:message)).to be_empty
      end

      it 'accepts %r delimiters for regexp with two or more slashes' do
        inspect_source(fpr, 'file.rb', ['x =~ %r(/home/)'])
        expect(fpr.offences.map(&:message)).to be_empty
      end
    end
  end
end
