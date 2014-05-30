# encoding: utf-8

require 'spec_helper'
require 'stringio'
require 'ostruct'

module RuboCop
  module Formatter
    describe DisabledConfigFormatter do
      subject(:formatter) { described_class.new(output) }
      let(:output) do
        o = StringIO.new
        def o.path
          '.rubocop_todo.yml'
        end
        o
      end
      let(:offenses) do
        [RuboCop::Cop::Offense.new(:convention, location, 'message', 'Cop1'),
         RuboCop::Cop::Offense.new(:convention, location, 'message', 'Cop2')]
      end
      let(:location) { OpenStruct.new(line: 1, column: 5) }
      before { $stdout = StringIO.new }

      describe '#finished' do
        it 'displays YAML configuration disabling all cops with offenses' do
          formatter.file_finished('test.rb', offenses)
          formatter.finished(['test.rb'])
          expect(output.string).to eq(described_class::HEADING +
                                      ['',
                                       '',
                                       '# Offense count: 1',
                                       'Cop1:',
                                       '  Enabled: false',
                                       '',
                                       '# Offense count: 1',
                                       'Cop2:',
                                       '  Enabled: false',
                                       ''].join("\n"))
          expect($stdout.string)
            .to eq(['Created .rubocop_todo.yml.',
                    'Run `rubocop --config .rubocop_todo.yml`, or',
                    'add inherit_from: .rubocop_todo.yml in a .rubocop.yml ' \
                    'file.',
                    ''].join("\n"))
        end
      end
    end
  end
end
