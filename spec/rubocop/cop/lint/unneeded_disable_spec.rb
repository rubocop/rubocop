# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::Lint::UnneededDisable do
  describe '.check' do
    let(:cop) { described_class.new }
    let(:file) { 'example.rb' }

    before(:each) do
      cop.check(file, offenses, cop_disabled_line_ranges, comments)
    end

    context 'when there are no disabled lines' do
      let(:offenses) { [] }
      let(:cop_disabled_line_ranges) { { file => [] } }
      let(:comments) { [] }

      it 'returns an empty array' do
        expect(cop.offenses).to eq([])
      end
    end

    context 'when there are disabled lines' do
      let(:comments) { { file => [OpenStruct.new(loc: loc)] } }
      let(:loc) do
        OpenStruct.new(line: expression.line,
                       column: expression.column,
                       expression: expression)
      end
      let(:expression) { OpenStruct.new(line: 1, column: 0, source: source) }

      context 'and there are no offenses' do
        let(:offenses) { [] }

        context 'and a comment disables' do
          context 'one cop' do
            let(:source) { '# rubocop:disable Metrics/MethodLength' }
            let(:cop_disabled_line_ranges) do
              { file => { 'Metrics/MethodLength' => [1..Float::INFINITY] } }
            end

            it 'returns an offense' do
              expect(cop.messages)
                .to eq(['Unnecessary disabling of Metrics/MethodLength.'])
            end

            it 'gives the right cop name' do
              expect(cop.name).to eq('Lint/UnneededDisable')
            end
          end

          context 'an unknown cop' do
            let(:source) { '# rubocop:disable UnknownCop' }
            let(:cop_disabled_line_ranges) do
              { file => { 'UnknownCop' => [1..Float::INFINITY] } }
            end

            it 'returns an offense' do
              expect(cop.messages)
                .to eq(['Unnecessary disabling of UnknownCop.'])
            end
          end

          context 'all cops' do
            let(:source) { '# rubocop:disable all' }
            let(:cop_disabled_line_ranges) do
              {
                file => {
                  'Metrics/MethodLength' => [1..Float::INFINITY],
                  'Metrics/ClassLength' => [1..Float::INFINITY]
                  # etc... (no need to include all cops here)
                }
              }
            end

            it 'returns an offense' do
              expect(cop.messages)
                .to eq(['Unnecessary disabling of all cops.'])
            end
          end
        end
      end

      context 'and there is an offense' do
        let(:offenses) do
          [
            RuboCop::Cop::Offense.new(:convention,
                                      OpenStruct.new(line: 7, column: 0),
                                      'Tab detected.',
                                      'Style/Tab')
          ]
        end

        context 'and a comment disables' do
          context 'that cop' do
            let(:source) { '# rubocop:disable Style/Tab' }
            let(:cop_disabled_line_ranges) do
              { file => { 'Style/Tab' => [1..100] } }
            end

            it 'returns an empty array' do
              expect(cop.offenses).to be_empty
            end
          end

          context 'that cop but on other lines' do
            let(:source) { '# rubocop:disable Style/Tab' }
            let(:cop_disabled_line_ranges) do
              { file => { 'Style/Tab' => [10..12] } }
            end
            let(:expression) do
              OpenStruct.new(line: 10, column: 0, source: source)
            end

            it 'returns an offense' do
              expect(cop.messages)
                .to eq(['Unnecessary disabling of Style/Tab.'])
            end
          end

          context 'all cops' do
            let(:source) { '# rubocop:disable all' }
            let(:cop_disabled_line_ranges) do
              {
                file => {
                  'Metrics/MethodLength' => [1..Float::INFINITY],
                  'Metrics/ClassLength' => [1..Float::INFINITY]
                  # etc... (no need to include all cops here)
                }
              }
            end

            it 'returns an empty array' do
              expect(cop.offenses).to be_empty
            end
          end
        end
      end
    end
  end
end
