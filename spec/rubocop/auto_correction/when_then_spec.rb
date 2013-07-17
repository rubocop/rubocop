# encoding: utf-8

require 'spec_helper'

module Rubocop
  module AutoCorrection
    describe WhenThen do
      let(:cop) { Cop::Style::WhenThen.new }
      let(:correction) { WhenThen.new }

      it 'auto-corrects "when x;" with "when x then"' do
        new_source = autocorrect_source(cop, correction, ['case a',
                                                          'when b; c',
                                                          'end'])
        expect(new_source).to eq("case a\nwhen b then c\nend")
      end
    end
  end
end
