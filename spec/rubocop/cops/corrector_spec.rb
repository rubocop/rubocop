# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    describe Corrector do
      describe '#rewrite' do
        let(:location) do
          source_buffer = Parser::Source::Buffer.new('test', 1)
          source_buffer.source = "a\n"
          Parser::Source::Range.new(source_buffer, 0, 1)
        end

        def create_offences(node)
          offence =
            Offence.new(:convention, location, 'message', 'Syntax', node: node)
          [offence]
        end

        def create_corrections(correction)
          { 'Syntax' => correction }
        end

        def do_autocorrect(source, correction)
          processed_source = parse_source(source)
          offences = create_offences(processed_source.ast)
          corrections = create_corrections(correction)

          corrector = Corrector.new(processed_source.buffer, corrections)
          corrector.rewrite(offences)
        end

        it 'allows removal of a range' do
          source = 'true and false'

          correction = lambda do |corrector, node|
            corrector.remove(node.loc.operator)
          end

          expect(do_autocorrect(source, correction)).to eq 'true  false'
        end

        it 'allows insertion before a source range' do
          source = 'true and false'

          correction = lambda do |corrector, node|
            corrector.insert_before(node.loc.operator, ';nil ')
          end

          expect(do_autocorrect(source, correction))
            .to eq('true ;nil and false')
        end

        it 'allows insertion after a source range' do
          source = 'true and false'

          correction = lambda do |corrector, node|
            corrector.insert_after(node.loc.operator, ' nil;')
          end

          expect(do_autocorrect(source, correction))
            .to eq('true and nil; false')
        end

        it 'allows replacement of a range' do
          source = 'true and false'

          correction = lambda do |corrector, node|
            corrector.replace(node.loc.operator, 'or')
          end

          expect(do_autocorrect(source, correction))
            .to eq('true or false')
        end
      end
    end
  end
end
