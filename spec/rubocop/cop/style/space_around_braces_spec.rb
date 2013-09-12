# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    module Style
      describe SpaceAroundBraces do
        subject(:cop) { SpaceAroundBraces.new }

        it 'registers an offence for left brace without spaces' do
          inspect_source(cop, ['each{ puts }'])
          expect(cop.messages).to eq(["Surrounding space missing for '{'."])
          expect(cop.highlights).to eq(['{'])
        end

        it 'registers an offence for right brace without inner space' do
          inspect_source(cop, ['each { puts}'])
          expect(cop.messages).to eq(
            ["Space missing to the left of '}'."])
          expect(cop.highlights).to eq(['}'])
        end

        it 'accepts an empty hash literal with no space inside' do
          inspect_source(cop,
                         ['view_hash.each do |view_key|',
                          'end',
                          '@views = {}',
                          ''])
          expect(cop.messages).to be_empty
        end

        it 'accepts string interpolation braces with no space inside' do
          inspect_source(cop,
                         ['"A=#{a}"',
                          ':"#{b}"',
                          '/#{c}/',
                          '`#{d}`',
                          'sprintf("#{message.gsub(/%/, \'%%\')}", line)'])
          expect(cop.messages).to be_empty
        end

        it 'accepts braces around a hash literal argument' do
          inspect_source(cop, ["new({'user' => user_params})"])
          expect(cop.messages).to be_empty
        end
      end
    end
  end
end
