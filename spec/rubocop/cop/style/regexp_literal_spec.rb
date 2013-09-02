# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    module Style
      describe RegexpLiteral do
        let(:rl) { RegexpLiteral.new }
        before { RegexpLiteral.config = { 'MaxSlashes' => 1 } }

        context 'when a regexp uses // delimiters' do
          context 'when MaxSlashes is 1' do
            it 'registers an offence for two slashes in regexp' do
              inspect_source(rl, ['x =~ /home\/\//',
                                  'y =~ /etc\/top\//'])
              expect(rl.messages)
                .to eq(['Use %r for regular expressions matching more ' +
                        "than 1 '/' character."] * 2)
            end

            it 'accepts zero or one slash in regexp' do
              inspect_source(rl, ['x =~ /\/home/',
                                  'y =~ /\//',
                                  'w =~ /\//m',
                                  'z =~ /a/'])
              expect(rl.offences).to be_empty
            end
          end

          context 'when MaxSlashes is 0' do
            before { RegexpLiteral.config = { 'MaxSlashes' => 0 } }

            it 'registers an offence for one slash in regexp' do
              inspect_source(rl, ['x =~ /home\//'])
              expect(rl.messages)
                .to eq(['Use %r for regular expressions matching more ' +
                        "than 0 '/' characters."])
            end

            it 'accepts zero slashes in regexp' do
              inspect_source(rl, ['z =~ /a/'])
              expect(rl.offences).to be_empty
            end
          end
        end

        context 'when a regexp uses %r delimiters' do
          context 'when MaxSlashes is 1' do
            it 'registers an offence for zero or one slash in regexp' do
              inspect_source(rl, ['x =~ %r(/home)',
                                  'y =~ %r(etc)'])
              expect(rl.messages)
                .to eq(['Use %r only for regular expressions matching more ' +
                        "than 1 '/' character."] * 2)
            end

            it 'accepts regexp with two or more slashes' do
              inspect_source(rl, ['x =~ %r(/home/)',
                                  'y =~ %r(/////)'])
              expect(rl.offences).to be_empty
            end
          end

          context 'when MaxSlashes is 0' do
            before { RegexpLiteral.config = { 'MaxSlashes' => 0 } }

            it 'registers an offence for zero slashes in regexp' do
              inspect_source(rl, ['y =~ %r(etc)'])
              expect(rl.messages)
                .to eq(['Use %r only for regular expressions matching more ' +
                        "than 0 '/' characters."])
            end

            it 'accepts regexp with one slash' do
              inspect_source(rl, ['x =~ %r(/home)'])
              expect(rl.offences).to be_empty
            end
          end
        end
      end
    end
  end
end
