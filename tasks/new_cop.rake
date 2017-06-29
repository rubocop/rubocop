# frozen_string_literal: true

require 'rubocop'

desc 'Generate a new cop template'
task :new_cop, [:cop] do |_task, args|
  cop_name = args.fetch(:cop) do
    raise ArgumentError, 'One argument is required'
  end

  generator = RuboCop::Cop::Generator.new(cop_name)

  generator.write_source
  generator.write_spec
  generator.inject_require

  puts generator.todo
end
