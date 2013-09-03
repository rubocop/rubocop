# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    module Style
      describe AsciiIdentifiers do
        subject(:ascii) { AsciiIdentifiers.new }

        it 'registers an offence for a variable name with non-ascii chars' do
          inspect_source(ascii,
                         ['# encoding: utf-8',
                          'älg = 1'])
          expect(ascii.offences.size).to eq(1)
          expect(ascii.messages)
            .to eq([AsciiIdentifiers::MSG])
        end

        it 'accepts identifiers with only ascii chars' do
          inspect_source(ascii,
                         ['x.empty?'])
          expect(ascii.offences).to be_empty
        end

        it 'does not get confused by a byte order mark' do
          bom = "\xef\xbb\xbf"
          inspect_source(ascii,
                         [bom + '# encoding: utf-8',
                          "puts 'foo'"])
          expect(ascii.offences).to be_empty
        end

        it 'does not get confused by an empty file' do
          inspect_source(ascii,
                         [''])
          expect(ascii.offences).to be_empty
        end
      end
    end
  end
end
