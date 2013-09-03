# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    module Style
      describe CollectionMethods do
        CollectionMethods.config = {
          'PreferredMethods' => {
            'collect' => 'map',
            'inject' => 'reduce',
            'detect' => 'find',
            'find_all' => 'select'
          }
        }

        subject(:cop) { CollectionMethods.new }

        CollectionMethods.preferred_methods.keys.each do |method|
          it "registers an offence for #{method} with block" do
            inspect_source(cop, ["[1, 2, 3].#{method} { |e| e + 1 }"])
            expect(cop.offences.size).to eq(1)
            preferred_method = CollectionMethods.preferred_methods[method]
            expect(cop.messages)
              .to eq(["Prefer #{preferred_method} over #{method}."])
          end

          it "registers an offence for #{method} with proc param" do
            inspect_source(cop, ["[1, 2, 3].#{method}(&:test)"])
            expect(cop.offences.size).to eq(1)
            preferred_method = CollectionMethods.preferred_methods[method]
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

          it 'auto-corrects to preferred method' do
            new_source = autocorrect_source(cop, 'some.collect(&:test)')
            expect(new_source).to eq('some.map(&:test)')
          end
        end
      end
    end
  end
end
