# encoding: utf-8

require 'spec_helper'

module Rubocop
  module Cop
    module Style
      describe CommentAnnotation do
        before do
          CommentAnnotation.config = {
            'Keywords' => %w(TODO FIXME OPTIMIZE HACK REVIEW)
          }
        end
        subject(:cop) { CommentAnnotation.new }

        it 'registers an offence for a missing colon' do
          inspect_source(cop, ['# TODO make better'])
          expect(cop.offences.size).to eq(1)
        end

        it 'registers an offence for a missing colon after configured word' do
          CommentAnnotation.config = {
            'Keywords' => %w(ISSUE)
          }
          inspect_source(cop, ['# ISSUE wrong order'])
          expect(cop.offences.size).to eq(1)
        end

        context 'when used with the clang formatter' do
          let(:formatter) { Formatter::ClangStyleFormatter.new(output) }
          let(:output) { StringIO.new }

          it 'marks the annotation keyword' do
            inspect_source(cop, ['# TODO:make better'])
            formatter.report_file('t', cop.offences)
            expect(output.string).to eq(["t:1:3: C: #{CommentAnnotation::MSG}",
                                         '# TODO:make better',
                                         '  ^^^^^',
                                         ''].join("\n"))
          end
        end

        it 'registers an offence for lower case' do
          inspect_source(cop, ['# fixme: does not work'])
          expect(cop.offences.size).to eq(1)
        end

        it 'registers an offence for capitalized annotation keyword' do
          inspect_source(cop, ['# Optimize: does not work'])
          expect(cop.offences.size).to eq(1)
        end

        it 'registers an offence for upper case with colon but no note' do
          inspect_source(cop, ['# HACK:'])
          expect(cop.offences.size).to eq(1)
        end

        it 'accepts upper case keyword with colon, space and note' do
          inspect_source(cop, ['# REVIEW: not sure about this'])
          expect(cop.offences).to be_empty
        end

        it 'accepts upper case keyword alone' do
          inspect_source(cop, ['# OPTIMIZE'])
          expect(cop.offences).to be_empty
        end

        it 'accepts a comment that is obviously a code example' do
          inspect_source(cop, ['# Todo.destroy(1)'])
          expect(cop.offences).to be_empty
        end

        it 'accepts a keyword that is just the beginning of a sentence' do
          inspect_source(cop,
                         ["# Optimize if you want. I wouldn't recommend it.",
                          '# Hack is a fun game.'])
          expect(cop.offences).to be_empty
        end

        it 'accepts a word without colon if not in the configuration' do
          CommentAnnotation.config = {
            'Keywords' => %w(FIXME OPTIMIZE HACK REVIEW)
          }
          inspect_source(cop, ['# TODO make better'])
          expect(cop.offences).to be_empty
        end
      end
    end
  end
end
