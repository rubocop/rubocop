# frozen_string_literal: true

namespace :references do
  desc 'Verify configuration references availability'
  task :verify do |_task|
    config = YAML.load_file('config/default.yml', permitted_classes: [Symbol, Regexp])
    references = config.values.map do |config_entry|
      Array(config_entry.fetch('References', config_entry.fetch('Reference', [])))
    end
    references.flatten!.map! { |entry| URI(entry) }.select!(&:hostname)

    has_failures = false
    references.to_set.each do |reference|
      failure = begin
        response = Net::HTTP.get_response(reference)
        unless response.is_a?(Net::HTTPSuccess) || response.is_a?(Net::HTTPRedirection)
          response.code
        end
      rescue StandardError => e
        e
      end

      if failure
        has_failures = true
        puts "ERROR: #{reference} (#{failure})"
      end
    end

    exit(1) if has_failures
  end
end
