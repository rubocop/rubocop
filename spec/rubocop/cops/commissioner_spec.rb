# encoding: utf-8
# rubocop:disable LineLength

require 'spec_helper'

module Rubocop
  module Cop
    describe Commissioner do
      describe '#investigate' do
        it 'returns all offences found by the cops' do
          cop = double(Cop, offences: [1])
          commissioner = Commissioner.new([cop])
          source = []
          ast, comments, tokens, src_buffer, _ = parse_source(source)

          expect(commissioner.investigate(src_buffer, source, tokens, ast, comments)).to eq [1]
        end

        it 'traverses the AST and invoke cops specific callbacks' do
          cop = double(Cop, offences: [])
          cop.should_receive(:on_def)

          commissioner = Commissioner.new([cop])
          source = ['def method', '1', 'end']
          ast, comments, tokens, src_buffer, _ = parse_source(source)

          commissioner.investigate(src_buffer, source, tokens, ast, comments)
        end

        it 'passes the input params to all cops that implement their own #investigate method' do
          source = []
          ast, comments, tokens, src_buffer, _ = parse_source(source)
          cop = double(Cop, offences: [])
          cop.should_receive(:investigate).with(src_buffer, source, tokens, ast, comments)

          commissioner = Commissioner.new([cop])

          commissioner.investigate(src_buffer, source, tokens, ast, comments)
        end

        it 'stores all errors raised by the cops' do
          cop = double(Cop, offences: [])
          cop.stub(:on_def) { raise RuntimeError }

          commissioner = Commissioner.new([cop])
          source = ['def method', '1', 'end']
          ast, comments, tokens, src_buffer, _ = parse_source(source)

          commissioner.investigate(src_buffer, source, tokens, ast, comments)

          expect(commissioner.errors[cop]).to have(1).item
          expect(commissioner.errors[cop][0]).to be_instance_of(RuntimeError)
        end

        context 'when passed :raise_error option' do
          it 're-raises the exception received while processing' do
          cop = double(Cop, offences: [])
          cop.stub(:on_def) { raise RuntimeError }

          commissioner = Commissioner.new([cop], raise_error: true)
          source = ['def method', '1', 'end']
          ast, comments, tokens, src_buffer, _ = parse_source(source)

          expect do
            commissioner.investigate(src_buffer, source, tokens, ast, comments)
          end.to raise_error(RuntimeError)
          end
        end
      end
    end
  end
end
