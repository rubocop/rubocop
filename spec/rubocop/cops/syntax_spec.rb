# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe Syntax do
      let(:sc) { Syntax.new }

      it 'registers an offence for unused variables', ruby: 2.0 do
        sc.inspect('file.rb', ['x = 5', 'puts 10'], nil, nil)
        expect(sc.offences.size).to eq(1)
        expect(sc.offences.first.message)
          .to eq('Assigned but unused variable - x')
      end
    end
  end
end
