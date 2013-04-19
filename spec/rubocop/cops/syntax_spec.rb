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

      describe '#process_line' do
        it 'processes warnings correctly' do
          l, s, m = sc.process_line('admin.rb:1: warning: possibly useless')
          expect(l).to eq(1)
          expect(s).to eq(:warning)
          expect(m).to eq('Possibly useless')
        end

        it 'processes errors correctly' do
          l, s, m = sc.process_line('admin.rb:1: unterminated string meets')
          expect(l).to eq(1)
          expect(s).to eq(:error)
          expect(m).to eq('Unterminated string meets')
        end
      end
    end
  end
end
