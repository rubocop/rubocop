# frozen_string_literal: true

require 'rubocop'

desc 'Generate a new cop template'
task :new_cop, [:cop] do |_task, args|
  cop_name = args.fetch(:cop) do
    warn "usage: bundle exec rake 'new_cop[Department/Name]'"
    exit!
  end

  badge = RuboCop::Cop::Badge.parse(cop_name)
  generator = RuboCop::Cop::Generator.new(cop_name)

  generator.write_source
  generator.write_spec

  if badge.department == :InternalAffairs
    # InternalAffairs cops are required separately, and not added to config/default.yml
    generator.inject_require(root_file_path: 'lib/rubocop/cop/internal_affairs.rb')
  else
    generator.inject_require
    generator.inject_config
  end

  puts generator.todo
end
