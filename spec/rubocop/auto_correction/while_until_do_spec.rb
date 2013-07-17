# encoding: utf-8

require 'spec_helper'

module Rubocop
  module AutoCorrection
    describe WhileUntilDo do
      let(:cop) { Cop::Style::WhileUntilDo.new }
      let(:correction) { WhileUntilDo.new }

      it 'auto-corrects the usage of "do" in multiline while' do
        new_source = autocorrect_source(cop, correction, ['while cond do',
                                        'end'])
        expect(new_source).to eq("while cond \nend")
      end

      it 'auto-corrects the usage of "do" in multiline until' do
        new_source = autocorrect_source(cop, correction, ['until cond do',
                                        'end'])
        expect(new_source).to eq("until cond \nend")
      end
    end
  end
end
