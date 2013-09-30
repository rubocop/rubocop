# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    module Style
      describe AsciiComments do
        subject(:ascii) { AsciiComments.new }

        it 'registers an offence for a comment with non-ascii chars' do
          inspect_source(ascii,
                         ['# encoding: utf-8',
                          '# 这是什么？'])
          expect(ascii.offences.size).to eq(1)
          expect(ascii.messages)
            .to eq(['Use only ascii symbols in comments.'])
        end

        it 'accepts comments with only ascii chars' do
          inspect_source(ascii,
                         ['# AZaz1@$%~,;*_`|'])
          expect(ascii.offences).to be_empty
        end
      end
    end
  end
end
