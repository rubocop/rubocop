# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    module Lint
      describe LiteralInCondition do
        let(:cop) { LiteralInCondition.new }

        %w(1 2.0 [1] {}).each do |lit|
          it "registers an offence for literal #{lit} in condition" do
            inspect_source(cop,
                           ["if x && #{lit}",
                            '  top',
                            'end'
                           ])
            expect(cop.offences.size).to eq(1)
          end
        end

        %w(1 2.0 [1] {}).each do |lit|
          it "accepts literal #{lit} if it's not an and/or operand" do
            inspect_source(cop,
                           ["if test(#{lit})",
                            '  top',
                            'end'
                           ])
            expect(cop.offences).to be_empty
          end
        end
      end
    end
  end
end
