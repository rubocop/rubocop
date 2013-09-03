# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    module Lint
      describe Eval do
        subject(:a) { Eval.new }

        it 'registers an offence for eval as function' do
          inspect_source(a,
                         ['eval(something)'])
          expect(a.offences.size).to eq(1)
          expect(a.messages)
            .to eq([Eval::MSG])
        end

        it 'registers an offence for eval as command' do
          inspect_source(a,
                         ['eval something'])
          expect(a.offences.size).to eq(1)
          expect(a.messages)
            .to eq([Eval::MSG])
        end

        it 'does not register an offence for eval as variable' do
          inspect_source(a,
                         ['eval = something'])
          expect(a.offences).to be_empty
        end

        it 'does not register an offence for eval as method' do
          inspect_source(a,
                         ['something.eval'])
          expect(a.offences).to be_empty
        end
      end
    end
  end
end
