# frozen_string_literal: true

require 'bump'

namespace :cut_release do
  def update_file(path)
    content = File.read(path)
    File.write(path, yield(content))
  end

  %w[major minor patch pre].each do |release_type|
    desc "Cut a new #{release_type} release, create release notes and update documents."
    task release_type => 'changelog:check_clean' do
      run(release_type)
    end
  end

  def version_sans_patch(version)
    version.split('.').take(2).join('.')
  end

  def update_readme(old_version, new_version)
    update_file('README.md') do |readme|
      readme.sub(
        "gem 'rubocop', '~> #{version_sans_patch(old_version)}', require: false",
        "gem 'rubocop', '~> #{version_sans_patch(new_version)}', require: false"
      )
    end
  end

  # Replace `<<next>>` (and variations) with version being cut.
  def update_cop_versions(_old_version, new_version)
    update_file('config/default.yml') do |default|
      default.gsub(/['"]?<<\s*next\s*>>['"]?/i, "'#{version_sans_patch(new_version)}'")
    end
    RuboCop::ConfigLoader.default_configuration = nil # invalidate loaded conf
  end

  def update_docs(old_version, new_version)
    update_file('docs/antora.yml') do |antora_metadata|
      antora_metadata.sub('version: ~', "version: '#{version_sans_patch(new_version)}'")
    end

    update_file('docs/modules/ROOT/pages/installation.adoc') do |installation|
      installation.sub(
        "gem 'rubocop', '~> #{version_sans_patch(old_version)}', require: false",
        "gem 'rubocop', '~> #{version_sans_patch(new_version)}', require: false"
      )
    end
  end

  def update_issue_template(old_version, new_version)
    update_file('.github/ISSUE_TEMPLATE/bug_report.md') do |issue_template|
      issue_template.sub("#{old_version} (using Parser ", "#{new_version} (using Parser ")
    end
  end

  def update_contributing_doc(old_version, new_version)
    update_file('CONTRIBUTING.md') do |contributing_doc|
      contributing_doc.sub("#{old_version} (using Parser ", "#{new_version} (using Parser ")
    end
  end

  def add_header_to_changelog(version)
    update_file('CHANGELOG.md') do |changelog|
      changelog.sub("## master (unreleased)\n\n", '\0' \
                                                  "## #{version} (#{Time.now.strftime('%F')})\n\n")
    end
  end

  def create_release_notes(version)
    release_notes = new_version_changes.strip
    contributor_links = user_links(release_notes)

    File.open("relnotes/v#{version}.md", 'w') do |file|
      file << release_notes
      file << "\n\n"
      file << contributor_links
      file << "\n"
    end
  end

  def new_version_changes
    changelog = File.read('CHANGELOG.md')
    _, _, new_changes, _older_changes = changelog.split(/^## .*$/, 4)
    new_changes
  end

  def user_links(text)
    names = text.scan(/\[@(\S+)\]\[\]/).map(&:first).uniq
    names.map { |name| "[@#{name}]: https://github.com/#{name}" }.join("\n")
  end

  def run(release_type)
    old_version = Bump::Bump.current
    Bump::Bump.run(release_type, commit: false, bundle: false, tag: false)
    new_version = Bump::Bump.current

    update_cop_versions(old_version, new_version)
    Rake::Task['update_cops_documentation'].invoke
    update_readme(old_version, new_version)
    update_docs(old_version, new_version)
    update_issue_template(old_version, new_version)
    update_contributing_doc(old_version, new_version)
    add_header_to_changelog(new_version)
    create_release_notes(new_version)

    puts "Changed version from #{old_version} to #{new_version}."
  end
end
