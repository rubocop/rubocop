# encoding: utf-8

require 'spec_helper'
require 'rubocop/rake_task'

describe RuboCop::RakeTask do
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
    before(:each) do
      $stdout = StringIO.new
      $stderr = StringIO.new
      Rake::Task['rubocop'].clear if Rake::Task.task_defined?('rubocop')
    end

    after(:each) do
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
