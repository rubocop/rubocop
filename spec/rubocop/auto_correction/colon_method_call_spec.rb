# encoding: utf-8

require 'spec_helper'

module Rubocop
  module AutoCorrection
    describe ColonMethodCall do
      let(:cop) { Cop::Style::ColonMethodCall.new }
      let(:correction) { ColonMethodCall.new }

      it 'auto-corrects "::" with "."' do
        new_source = autocorrect_source(cop, correction, 'test::method')
        expect(new_source).to eq('test.method')
      end
    end
  end
end
