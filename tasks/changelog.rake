# frozen_string_literal: true

autoload :Changelog, "#{__dir__}/changelog"

namespace :changelog do
  %i[new fix change].each do |type|
    desc "Create a Changelog entry (#{type})"
    task type, [:id] do |_task, args|
      ref_type = :pull if args[:id]
      path = Changelog::Entry.new(type: type, ref_id: args[:id], ref_type: ref_type).write
      cmd = "git add #{path}"
      system cmd
      puts "Entry '#{path}' created and added to git index"
    end
  end

  desc 'Merge entries and delete them'
  task :merge do
    raise 'No entries!' unless Changelog.pending?

    Changelog.new.merge!.and_delete!
    cmd = "git commit -a -m 'Update Changelog'"
    puts cmd
    system cmd
  end

  task :check_clean do
    next unless Changelog.pending?

    puts '*** Pending changelog entries!'
    puts 'Do `bundle exec rake changelog:merge`'
    exit(1)
  end
end
