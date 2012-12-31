# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe EndOfLine do
      let (:eol) { EndOfLine.new }

      it 'registers an offence for CR+LF' do
        inspect_source(eol, 'file.rb', ["x=0\r", ''])
        eol.offences.map(&:message).should ==
          ['Carriage return character detected.']
      end
    end
  end
end
