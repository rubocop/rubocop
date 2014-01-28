# encoding: utf-8

require 'spec_helper'
require 'stringio'
require 'ostruct'

module Rubocop
  module Formatter
    describe DisabledConfigFormatter do
      subject(:formatter) { described_class.new(output) }
      let(:output) do
        o = StringIO.new
        def o.path
          'rubocop-todo.yml'
        end
        o
      end
      let(:offences) do
        [Rubocop::Cop::Offence.new(:convention, location, 'message', 'Cop1'),
         Rubocop::Cop::Offence.new(:convention, location, 'message', 'Cop2')]
      end
      let(:location) { OpenStruct.new(line: 1, column: 5) }
      before { $stdout = StringIO.new }

      describe '#finished' do
        it 'displays YAML configuration disabling all cops with offences' do
          formatter.file_finished('test.rb', offences)
          formatter.finished(['test.rb'])
          expect(output.string).to eq(described_class::HEADING +
                                      ['',
                                       '',
                                       '# Offence count: 1',
                                       'Cop1:',
                                       '  Enabled: false',
                                       '',
                                       '# Offence count: 1',
                                       'Cop2:',
                                       '  Enabled: false',
                                       ''].join("\n"))
          expect($stdout.string)
            .to eq(['Created rubocop-todo.yml.',
                    'Run rubocop with --config rubocop-todo.yml, or',
                    'add inherit_from: rubocop-todo.yml in a .rubocop.yml ' \
                    'file.',
                    ''].join("\n"))
        end
      end
    end
  end
end
