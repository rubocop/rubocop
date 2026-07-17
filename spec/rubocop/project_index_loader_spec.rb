# frozen_string_literal: true

RSpec.describe RuboCop::ProjectIndexLoader do
  describe '.bundled_gem_source_files' do
    it 'returns the Ruby files under each bundled gem lib directory' do
      Dir.mktmpdir do |gem_dir|
        FileUtils.mkdir_p(File.join(gem_dir, 'lib', 'fake'))
        source = File.join(gem_dir, 'lib', 'fake', 'gem_base.rb')
        File.write(source, "class GemBase\nend\n")
        spec = instance_double(Gem::Specification, full_gem_path: gem_dir)
        allow(Bundler).to receive(:load).and_return(instance_double(Bundler::Runtime,
                                                                    specs: [spec]))

        expect(described_class.bundled_gem_source_files).to eq([source])
      end
    end

    it 'returns no files outside a bundle' do
      allow(Bundler::SharedHelpers).to receive(:in_bundle?).and_return(nil)

      expect(described_class.bundled_gem_source_files).to be_empty
    end

    it 'returns no files and warns when the bundle cannot be loaded' do
      allow(Bundler).to receive(:load).and_raise(Bundler::GemfileNotFound)

      files = nil
      expect do
        files = described_class.bundled_gem_source_files
      end.to output(/Indexing the project only/).to_stderr
      expect(files).to be_empty
    end
  end

  describe 'AllCops/ProjectIndexIncludesGems', :project_index do
    let(:child_source) do
      <<~RUBY
        class Child < GemBase
          def initialize
            @foo = 1
          end
        end
      RUBY
    end

    def missing_super_offenses(project_dir)
      offenses = project_index_offenses(project_dir)
      offenses.select { |offense| offense['cop_name'] == 'Lint/MissingSuper' }
    end

    def with_fake_gem_project(include_gems:)
      Dir.mktmpdir do |tmpdir|
        stage_fake_gem(tmpdir)

        project_dir = File.join(tmpdir, 'project')
        FileUtils.mkdir_p(project_dir)
        File.write(File.join(project_dir, 'child.rb'), child_source)
        config = {
          'AllCops' => { 'UseProjectIndex' => true, 'ProjectIndexIncludesGems' => include_gems }
        }
        write_rubocop_config(project_dir, config)

        yield project_dir
      end
    end

    def stage_fake_gem(tmpdir)
      gem_source = File.join(tmpdir, 'gem', 'lib', 'gem_base.rb')
      FileUtils.mkdir_p(File.dirname(gem_source))
      File.write(gem_source, "class GemBase\nend\n")
      allow(described_class).to receive(:bundled_gem_source_files).and_return([gem_source])
    end

    it 'resolves ancestry through gem sources when enabled' do
      with_fake_gem_project(include_gems: true) do |project_dir|
        expect(missing_super_offenses(project_dir)).to be_empty
      end
    end

    it 'keeps gem ancestry unresolved when disabled' do
      with_fake_gem_project(include_gems: false) do |project_dir|
        expect(missing_super_offenses(project_dir).size).to eq(1)
      end
    end
  end
end
