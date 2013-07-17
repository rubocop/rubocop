# encoding: utf-8

require 'spec_helper'

module Rubocop
  module AutoCorrection
    describe CharacterLiteral do
      let(:cop) { Cop::Style::CharacterLiteral.new }
      let(:correction) { CharacterLiteral.new }

      it "auto-corrects ?x to 'x'" do
        new_source = autocorrect_source(cop, correction, 'x = ?x')
        expect(new_source).to eq("x = 'x'")
      end

      it 'auto-corrects ?\n to "\\n"' do
        new_source = autocorrect_source(cop, correction, 'x = ?\n')
        expect(new_source).to eq('x = "\\n"')
      end
    end
  end
end
