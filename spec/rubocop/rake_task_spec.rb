# frozen_string_literal: true

require 'spec_helper'
require 'support/file_helper'
require 'rubocop/rake_task'

describe RuboCop::RakeTask do
  include FileHelper

  describe 'defining tasks' do
    it 'creates a rubocop task' do
      RuboCop::RakeTask.new

      expect(Rake::Task.task_defined?(:rubocop)).to be true
    end

    it 'creates a rubocop:auto_correct task' do
      RuboCop::RakeTask.new

      expect(Rake::Task.task_defined?('rubocop:auto_correct')).to be true
    end

    it 'creates a named task' do
      RuboCop::RakeTask.new(:lint_lib)

      expect(Rake::Task.task_defined?(:lint_lib)).to be true
    end

    it 'creates an auto_correct task for the named task' do
      RuboCop::RakeTask.new(:lint_lib)

      expect(Rake::Task.task_defined?('lint_lib:auto_correct')).to be true
    end
  end

  describe 'running tasks' do
    before do
      $stdout = StringIO.new
      $stderr = StringIO.new
      Rake::Task['rubocop'].clear if Rake::Task.task_defined?('rubocop')
    end

    after do
      $stdout = STDOUT
      $stderr = STDERR
    end

    it 'runs with default options' do
      RuboCop::RakeTask.new

      cli = double('cli', run: 0)
      allow(RuboCop::CLI).to receive(:new) { cli }
      expect(cli).to receive(:run).with([])

      Rake::Task['rubocop'].execute
    end

    it 'runs with specified options if a block is given' do
      RuboCop::RakeTask.new do |task|
        task.patterns = ['lib/**/*.rb']
        task.formatters = ['files']
        task.fail_on_error = false
        task.options = ['--display-cop-names']
        task.verbose = false
      end

      cli = double('cli', run: 0)
      allow(RuboCop::CLI).to receive(:new) { cli }
      options = ['--format', 'files', '--display-cop-names', 'lib/**/*.rb']
      expect(cli).to receive(:run).with(options)

      Rake::Task['rubocop'].execute
    end

    it 'allows nested arrays inside formatters, options, and requires' do
      RuboCop::RakeTask.new do |task|
        task.formatters = [['files']]
        task.requires = [['library']]
        task.options = [['--display-cop-names']]
      end

      cli = double('cli', run: 0)
      allow(RuboCop::CLI).to receive(:new) { cli }
      options = ['--format', 'files', '--require', 'library',
                 '--display-cop-names']
      expect(cli).to receive(:run).with(options)

      Rake::Task['rubocop'].execute
    end

    it 'will not error when result is not 0 and fail_on_error is false' do
      RuboCop::RakeTask.new do |task|
        task.fail_on_error = false
      end

      cli = double('cli', run: 1)
      allow(RuboCop::CLI).to receive(:new) { cli }

      expect { Rake::Task['rubocop'].execute }.to_not raise_error
    end

    it 'exits when result is not 0 and fail_on_error is true' do
      RuboCop::RakeTask.new

      cli = double('cli', run: 1)
      allow(RuboCop::CLI).to receive(:new) { cli }

      expect { Rake::Task['rubocop'].execute }.to raise_error(SystemExit)
    end

    it 'uses the default formatter from .rubocop.yml if no formatter ' \
       'option is given', :isolated_environment do
      create_file('.rubocop.yml', ['AllCops:',
                                   '  DefaultFormatter: offenses'])
      create_file('test.rb', '$:')

      RuboCop::RakeTask.new do |task|
        task.options = ['test.rb']
      end

      expect { Rake::Task['rubocop'].execute }.to raise_error(SystemExit)

      expect($stdout.string.strip).to eq(['Running RuboCop...',
                                          '',
                                          '1  Style/SpecialGlobalVars',
                                          '--',
                                          '1  Total'].join("\n"))
      expect($stderr.string.strip).to eq 'RuboCop failed!'
    end

    context 'auto_correct' do
      it 'runs with --auto-correct' do
        RuboCop::RakeTask.new

        cli = double('cli', run: 0)
        allow(RuboCop::CLI).to receive(:new) { cli }
        options = ['--auto-correct']
        expect(cli).to receive(:run).with(options)

        Rake::Task['rubocop:auto_correct'].execute
      end

      it 'runs with with the options that were passed to its parent task' do
        RuboCop::RakeTask.new do |task|
          task.patterns = ['lib/**/*.rb']
          task.formatters = ['files']
          task.fail_on_error = false
          task.options = ['-D']
          task.verbose = false
        end

        cli = double('cli', run: 0)
        allow(RuboCop::CLI).to receive(:new) { cli }
        options = ['--auto-correct', '--format', 'files', '-D', 'lib/**/*.rb']
        expect(cli).to receive(:run).with(options)

        Rake::Task['rubocop:auto_correct'].execute
      end
    end
  end
end
