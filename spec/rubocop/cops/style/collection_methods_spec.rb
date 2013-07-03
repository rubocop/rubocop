# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    module Style
      describe CollectionMethods do
        let(:cop) { CollectionMethods.new }

        CollectionMethods::PREFERRED_METHODS.keys.each do |method|
          it "registers an offence for #{method} with block" do
            inspect_source(cop, ["[1, 2, 3].#{method} { |e| e + 1 }"])
            expect(cop.offences.size).to eq(1)
            preferred_method = CollectionMethods::PREFERRED_METHODS[method]
            expect(cop.messages)
              .to eq(["Prefer #{preferred_method} over #{method}."])
          end

          it "registers an offence for #{method} with proc param" do
            inspect_source(cop, ["[1, 2, 3].#{method}(&:test)"])
            expect(cop.offences.size).to eq(1)
            preferred_method = CollectionMethods::PREFERRED_METHODS[method]
            expect(cop.messages)
              .to eq(["Prefer #{preferred_method} over #{method}."])
          end

          it "accepts #{method} with more than 1 param" do
            inspect_source(cop, ["[1, 2, 3].#{method}(other, &:test)"])
            expect(cop.offences).to be_empty
          end

          it "accepts #{method} without a block" do
            inspect_source(cop, ["[1, 2, 3].#{method}"])
            expect(cop.offences).to be_empty
          end
        end
      end
    end
  end
end
