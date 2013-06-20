# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    module Style
      describe RegexpLiteral do
        let(:rl) { RegexpLiteral.new }
        let(:msg) do
          'Use %r for regular expressions matching more ' +
            "than one '/' character."
        end

        context 'when a regexp uses // delimiters' do
          it 'registers an offence for two slashes in regexp' do
            inspect_source(rl, ['x =~ /home\/\//',
                                'y =~ /etc\/top\//'])
            expect(rl.offences.map(&:message)).to eq([msg] * 2)
          end

          it 'accepts zero or one slash in regexp' do
            inspect_source(rl, ['x =~ /\/home/',
                                'y =~ /\//',
                                'z =~ /a/'])
            expect(rl.offences).to be_empty
          end
        end

        context 'when a regexp uses %r delimiters' do
          let(:msg) do
            'Use %r only for regular expressions matching more ' +
              "than one '/' character."
          end

          it 'accepts regexp with two or more slashes' do
            inspect_source(rl, ['x =~ %r(/home/)'])
            expect(rl.offences).to be_empty
          end

          it 'registers an offence for zero or one slash in regexp' do
            inspect_source(rl, ['x =~ %r(/home)',
                                'y =~ %r(etc)'])
            expect(rl.offences.map(&:message)).to eq([msg] * 2)
          end

          it 'accepts at least two slashes in regexp' do
            inspect_source(rl, ['x =~ %r(/home/)',
                                'y =~ %r(/////)'])
            expect(rl.offences).to be_empty
          end
        end
      end
    end
  end
end
