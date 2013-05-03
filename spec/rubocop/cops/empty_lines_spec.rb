# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe EmptyLines do
      let(:empty_lines) { EmptyLines.new }

      it 'registers an offence for consecutive empty lines' do
        inspect_source(empty_lines, 'file.rb',
                       ['test = 5', '', '', '', 'top'])
        expect(empty_lines.offences.size).to eq(2)
      end

      it 'does not register an offence for empty lines in a string' do
        inspect_source(empty_lines, 'file.rb', ['result = "test



                                                 string"'])
        expect(empty_lines.offences).to be_empty
      end
    end
  end
end
