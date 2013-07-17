# encoding: utf-8

require 'spec_helper'

module Rubocop
  module AutoCorrection
    describe StringLiterals do
      let(:cop) { Cop::Style::StringLiterals.new }
      let(:correction) { StringLiterals.new }

      it 'auto-corrects " with \'' do
        new_source = autocorrect_source(cop, correction, 's = "abc"')
        expect(new_source).to eq("s = 'abc'")
      end
    end
  end
end
