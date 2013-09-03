# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    module Lint
      describe UselessComparison do
        subject(:cop) { UselessComparison.new }

        UselessComparison::OPS.each do |op|
          it "registers an offence for a simple comparison with #{op}" do
            inspect_source(cop,
                           ["5 #{op} 5",
                            "a #{op} a"
                           ])
            expect(cop.offences.size).to eq(2)
          end

          it "registers an offence for a complex comparison with #{op}" do
            inspect_source(cop,
                           ["5 + 10 * 30 #{op} 5 + 10 * 30",
                            "a.top(x) #{op} a.top(x)"
                           ])
            expect(cop.offences.size).to eq(2)
          end
        end
      end
    end
  end
end
