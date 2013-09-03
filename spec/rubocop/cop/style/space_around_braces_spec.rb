# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    module Style
      describe SpaceAroundBraces do
        subject(:space) { SpaceAroundBraces.new }

        it 'registers an offence for left brace without spaces' do
          inspect_source(space, ['each{ puts }'])
          expect(space.messages).to eq(
            ["Surrounding space missing for '{'."])
        end

        it 'registers an offence for right brace without inner space' do
          inspect_source(space, ['each { puts}'])
          expect(space.messages).to eq(
            ["Space missing to the left of '}'."])
        end

        it 'accepts an empty hash literal with no space inside' do
          inspect_source(space,
                         ['view_hash.each do |view_key|',
                          'end',
                          '@views = {}',
                          ''])
          expect(space.messages).to be_empty
        end

        it 'accepts string interpolation braces with no space inside' do
          inspect_source(space,
                         ['"A=#{a}"',
                          ':"#{b}"',
                          '/#{c}/',
                          '`#{d}`',
                          'sprintf("#{message.gsub(/%/, \'%%\')}", line)'])
          expect(space.messages).to be_empty
        end

        it 'accepts braces around a hash literal argument' do
          inspect_source(space, ["new({'user' => user_params})"])
          expect(space.messages).to be_empty
        end
      end
    end
  end
end
