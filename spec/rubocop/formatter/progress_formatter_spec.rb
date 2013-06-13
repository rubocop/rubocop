# encoding: utf-8

require 'spec_helper'
require 'stringio'

module Rubocop
  describe Formatter::ProgressFormatter do
    let(:formatter) { Formatter::ProgressFormatter.new(output) }
    let(:output) { StringIO.new }

    let(:files) do
      %w(lib/rubocop.rb spec/spec_helper.rb bin/rubocop).map do |path|
        File.expand_path(path)
      end
    end

    describe '#file_finished' do
      before do
        formatter.started(files)
        formatter.file_started(files.first, {})
      end

      shared_examples 'calls #report_file_as_mark' do
        it 'calls #report_as_with_mark' do
          formatter.should_receive(:report_file_as_mark)
          formatter.file_finished(files.first, offences)
        end
      end

      context 'when no offences are detected' do
        let(:offences) { [] }
        include_examples 'calls #report_file_as_mark'
      end

      context 'when any offences are detected' do
        let(:offences) { [double('offence').as_null_object] }
        include_examples 'calls #report_file_as_mark'
      end
    end

    describe '#report_file_as_mark' do
      before do
        formatter.report_file_as_mark(files.first, offences)
      end

      def offence_with_severity(severity)
        Cop::Offence.new(severity, Cop::Location.new(1, 0, ['a']), 'message',
                         'CopName')
      end

      context 'when no offences are detected' do
        let(:offences) { [] }

        it 'prints "."' do
          expect(output.string).to eq('.')
        end
      end

      context 'when a refactor severity offence is detected' do
        let(:offences) { [offence_with_severity(:refactor)] }

        it 'prints "R"' do
          expect(output.string).to eq('R')
        end
      end

      context 'when a refactor convention offence is detected' do
        let(:offences) { [offence_with_severity(:convention)] }

        it 'prints "C"' do
          expect(output.string).to eq('C')
        end
      end

      context 'when different severity offences are detected' do
        let(:offences) do
          [
            offence_with_severity(:refactor),
            offence_with_severity(:error)
          ]
        end

        it 'prints highest level mark' do
          expect(output.string).to eq('E')
        end
      end
    end

    describe '#finished' do
      before do
        formatter.reports_summary = true

        formatter.started(files)
        formatter.file_started(files[0], {})
        formatter.file_finished(files[0],
                                [Cop::Offence.new(:convention,
                                                  Cop::Location.new(2, 2,
                                                                    ['a']),
                                                  'foo',
                                                  'Cop')
        ])
        formatter.file_started(files[1], {})
        formatter.file_finished(files[1], [
        ])
        formatter.file_started(files[2], {})
        formatter.file_finished(files[2], [
          Cop::Offence.new(:convention, Cop::Location.new(6, 0, ['a']), 'foo',
                           'Cop'),
          Cop::Offence.new(:error, Cop::Location.new(5, 1, ['a']), 'bar',
                           'Cop')
        ])
      end

      it 'reports all detected offences for all failed files' do
        formatter.finished(files)
        expect(output.string).to include([
          '== lib/rubocop.rb ==',
          'C:  2:  2: foo',
          '',
          '== bin/rubocop ==',
          'E:  5:  1: bar',
          'C:  6:  0: foo'
        ].join("\n"))
      end

      it 'calls #report_summary' do
        formatter.should_receive(:report_summary)
        formatter.finished(files)
      end

      context 'when #report_summary? is false' do
        before { formatter.reports_summary = false }
        it 'reports nothing' do
          output.string = ''
          formatter.finished(files)
          expect(output.string).to eq("\n")
        end
      end
    end
  end
end
