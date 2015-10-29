# encoding: utf-8

require 'spec_helper'

module RuboCop
  module Formatter
    describe DisabledConfigFormatter do
      subject(:formatter) { described_class.new(output, command_line_args) }
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
        context 'with default exclusion limit' do
          let(:command_line_args) { %w(--auto-gen-config) }
          it 'displays a file exclusion list up to a maximum of 15 offences' do
            exclusion_list = []
            file_list = []

            15.times do |index|
              file_name = format('test_%02d.rb', index)
              formatter.file_started(file_name, {})
              formatter.file_finished(file_name, offenses)
              file_list << file_name
              exclusion_list << "    - '#{file_name}'"
            end

            file_list << 'test.rb'
            formatter.file_started('test.rb', {})
            formatter.file_finished('test.rb', [offenses.first])
            formatter.finished(file_list)
            expect(output.string).to eq(format(described_class::HEADING,
                                               command_line_args.join(' ')) +
                                        ['',
                                         '',
                                         '# Offense count: 16',
                                         'Cop1:',
                                         '  Enabled: false',
                                         '',
                                         '# Offense count: 15',
                                         'Cop2:',
                                         '  Exclude:',
                                         exclusion_list,
                                         ''].flatten.join("\n"))
          end
        end

        context 'with exclusion limit' do
          let(:command_line_args) { %w(--auto-gen-config --exclude-limit 5) }
          it 'can be configured' do
            exclusion_list = []
            file_list = []
            options = {
              cli_options: {
                exclude_limit: 5
              }
            }

            15.times do |index|
              file_name = format('test_%02d.rb', index)
              formatter.file_started(file_name, options)
              formatter.file_finished(file_name, offenses)
              file_list << file_name
              exclusion_list << "    - '#{file_name}'"
            end

            file_list << 'test.rb'
            formatter.file_started('test.rb', options)
            formatter.file_finished('test.rb', [offenses.first])
            formatter.finished(file_list)
            expect(output.string).to eq(format(described_class::HEADING,
                                               command_line_args.join(' ')) +
                                        ['',
                                         '',
                                         '# Offense count: 16',
                                         'Cop1:',
                                         '  Enabled: false',
                                         '',
                                         '# Offense count: 15',
                                         'Cop2:',
                                         '  Enabled: false',
                                         ''].flatten.join("\n"))
          end
        end

        context 'with other parameters passed to it' do
          let(:command_line_args) do
            %w(--rails --auto-gen-config --exclude-limit 5)
          end
          it 'can indicate all parameters passed to it' do
            options = {
              cli_options: {
                rails: true,
                exclude_limit: 5
              }
            }

            formatter.file_started('test_a.rb', options)
            formatter.file_finished('test_a.rb', offenses)
            formatter.finished(['test_a.rb'])

            expect(output.string).to eq(format(described_class::HEADING,
                                               '--rails --auto-gen-config ' \
                                               '--exclude-limit 5') +
                                               ['',
                                                '',
                                                '# Offense count: 1',
                                                'Cop1:',
                                                '  Exclude:',
                                                "    - 'test_a.rb'",
                                                '',
                                                '# Offense count: 1',
                                                'Cop2:',
                                                '  Exclude:',
                                                "    - 'test_a.rb'",
                                                ''].join("\n"))
          end
        end
      end
    end
  end
end
