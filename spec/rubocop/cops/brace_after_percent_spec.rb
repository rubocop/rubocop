# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe BraceAfterPercent do
      let(:bap) { BraceAfterPercent.new }
      literals = %w(q Q r i I w W x s)

      literals.each do |literal|
        # %i and %I are new in ruby 2.0
        tag = literal.downcase == 'i' ? { ruby: 2.0 } : {}

        it "registers an offence for %#{literal}[", tag  do
          inspect_source(bap,
                         'file.rb',
                         ["puts %#{literal}[test top]"])
          expect(bap.offences.size).to eq(1)
          expect(bap.offences.map(&:message))
            .to eq([BraceAfterPercent::ERROR_MESSAGE])
        end

        it "does not registers an offence for %#{literal}(", tag do
          inspect_source(bap,
                         'file.rb',
                         ["puts %#{literal}(test top)"])
          expect(bap.offences).to be_empty
        end
      end
    end
  end
end
