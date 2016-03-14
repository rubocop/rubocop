# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::TargetFinder, :isolated_environment do
  include FileHelper

  subject(:target_finder) do
    described_class.new(config_store, options)
  end
  let(:config_store) { RuboCop::ConfigStore.new }
  let(:options) { { force_exclusion: force_exclusion, debug: debug } }
  let(:force_exclusion) { false }
  let(:debug) { false }

  before do
    create_file('dir1/ruby1.rb',   '# encoding: utf-8')
    create_file('dir1/ruby2.rb',   '# encoding: utf-8')
    create_file('dir1/file.txt',   '# encoding: utf-8')
    create_file('dir1/file',       '# encoding: utf-8')
    create_file('dir1/executable', '#!/usr/bin/env ruby')
    create_file('dir2/ruby3.rb',   '# encoding: utf-8')
  end

  describe '#find' do
    let(:found_files) { target_finder.find(args) }
    let(:found_basenames) { found_files.map { |f| File.basename(f) } }
    let(:args) { [] }

    it 'returns absolute paths' do
      expect(found_files).not_to be_empty
      found_files.each do |file|
        expect(file.sub(/^[A-Z]:/, '')).to start_with('/')
      end
    end

    context 'when no argument is passed' do
      let(:args) { [] }

      it 'finds files under the current directory' do
        Dir.chdir('dir1') do
          expect(found_files).not_to be_empty
          found_files.each do |file|
            expect(file).to include('/dir1/')
            expect(file).not_to include('/dir2/')
          end
        end
      end
    end

    context 'when a directory path is passed' do
      let(:args) { ['../dir2'] }

      it 'finds files under the specified directory' do
        Dir.chdir('dir1') do
          expect(found_files).not_to be_empty
          found_files.each do |file|
            expect(file).to include('/dir2/')
            expect(file).not_to include('/dir1/')
          end
        end
      end
    end

    context 'when a file is passed' do
      let(:args) { ['dir2/file'] }

      it 'picks the file' do
        expect(found_basenames).to eq(['file'])
      end
    end

    context 'when a pattern is passed' do
      let(:args) { ['dir1/*2.rb'] }

      it 'finds files which match the pattern' do
        expect(found_basenames).to eq(['ruby2.rb'])
      end
    end

    context 'when same paths are passed' do
      let(:args) { %w(dir1 dir1) }

      it 'does not return duplicated file paths' do
        count = found_basenames.count { |f| f == 'ruby1.rb' }
        expect(count).to eq(1)
      end
    end

    context 'when some paths are specified in the configuration Exclude ' \
            'and they are explicitly passed as arguments' do
      before do
        create_file('.rubocop.yml', [
                      'AllCops:',
                      '  Exclude:',
                      '    - dir1/ruby1.rb',
                      "    - 'dir2/*'"
                    ])

        create_file('dir1/.rubocop.yml', [
                      'AllCops:',
                      '  Exclude:',
                      '    - executable'
                    ])
      end

      let(:args) do
        ['dir1/ruby1.rb', 'dir1/ruby2.rb', 'dir1/exe*', 'dir2/ruby3.rb']
      end

      context 'normally' do
        it 'does not exclude them' do
          expect(found_basenames)
            .to eq(['ruby1.rb', 'ruby2.rb', 'executable', 'ruby3.rb'])
        end
      end

      context "when it's forced to adhere file exclusion configuration" do
        let(:force_exclusion) { true }

        it 'excludes them' do
          expect(found_basenames).to eq(['ruby2.rb'])
        end
      end
    end
  end

  describe '#find_files' do
    let(:found_files) { target_finder.find_files(base_dir, flags) }
    let(:found_basenames) { found_files.map { |f| File.basename(f) } }
    let(:base_dir) { Dir.pwd }
    let(:flags) { 0 }

    it 'does not search excluded top level directories' do
      config = double('config')
      exclude_property = { 'Exclude' => [File.expand_path('dir1/**/*')] }
      allow(config).to receive(:for_all_cops).and_return(exclude_property)
      allow(config_store).to receive(:for).and_return(config)

      expect(found_basenames).not_to include('ruby1.rb')
      expect(found_basenames).to include('ruby3.rb')
    end

    it 'works also if a folder is named ","' do
      create_file(',/ruby4.rb', '# encoding: utf-8')

      config = double('config')
      exclude_property = { 'Exclude' => [File.expand_path('dir1/**/*')] }
      allow(config).to receive(:for_all_cops).and_return(exclude_property)
      allow(config_store).to receive(:for).and_return(config)

      expect(found_basenames).not_to include('ruby1.rb')
      expect(found_basenames).to include('ruby3.rb')
      expect(found_basenames).to include('ruby4.rb')
    end
  end

  describe '#target_files_in_dir' do
    let(:found_files) { target_finder.target_files_in_dir(base_dir) }
    let(:found_basenames) { found_files.map { |f| File.basename(f) } }
    let(:base_dir) { '.' }

    it 'picks files with extension .rb' do
      rb_file_count = found_files.count { |f| f.end_with?('.rb') }
      expect(rb_file_count).to eq(3)
    end

    it 'picks ruby executable files with no extension' do
      expect(found_basenames).to include('executable')
    end

    it 'does not pick files with no extension and no ruby shebang' do
      expect(found_basenames).not_to include('file')
    end

    it 'picks ruby executable files with no extension' do
      expect(found_basenames).to include('executable')
    end

    it 'does not pick directories' do
      found_basenames = found_files.map { |f| File.basename(f) }
      expect(found_basenames).not_to include('dir1')
    end

    it 'picks files specified to be included in config' do
      config = double('config')
      allow(config).to receive(:file_to_include?) do |file|
        File.basename(file) == 'file'
      end
      allow(config)
        .to receive(:for_all_cops).and_return('Exclude' => [])
      allow(config).to receive(:file_to_exclude?).and_return(false)
      allow(config_store).to receive(:for).and_return(config)

      expect(found_basenames).to include('file')
    end

    it 'does not pick files specified to be excluded in config' do
      config = double('config').as_null_object
      allow(config)
        .to receive(:for_all_cops).and_return('Exclude' => [])
      allow(config).to receive(:file_to_include?).and_return(false)
      allow(config).to receive(:file_to_exclude?) do |file|
        File.basename(file) == 'ruby2.rb'
      end
      allow(config_store).to receive(:for).and_return(config)

      expect(found_basenames).not_to include('ruby2.rb')
    end

    context 'when an exception is raised while reading file' do
      around do |example|
        original_stderr = $stderr
        $stderr = StringIO.new
        begin
          example.run
        ensure
          $stderr = original_stderr
        end
      end

      before do
        allow_any_instance_of(File).to receive(:readline).and_raise(EOFError)
      end

      context 'and debug mode is enabled' do
        let(:debug) { true }

        it 'outputs error message' do
          found_files
          expect($stderr.string).to include('Unprocessable file')
        end
      end

      context 'and debug mode is disabled' do
        let(:debug) { false }

        it 'outputs nothing' do
          found_files
          expect($stderr.string).to be_empty
        end
      end
    end
  end
end
