require 'spec_helper'

describe 'Check for Ruby style errors in' do
  ignored_file_paths = []
  ignored_file_paths << Dir[Rails.root.to_s + '/db/**/*.rb']
  ignored_file_paths << Dir[Rails.root.to_s + '/tmp/**/*.rb']
  ignored_file_paths << Dir[Rails.root.to_s + '/public/assets/**/*.rb']

  rubocop_config = Rails.root.to_s + '/.rubocop.yml'
  file_paths = Dir[Rails.root.to_s + '/**/*.rb'] - ignored_file_paths.flatten
  output = `rubocop #{file_paths.join(' ')} --format simple`

  file_path = nil
  errors = output.lines.each_with_object({}) do |line, errors|
    line.chomp!
    if line.start_with?('== ') && line.end_with?(' ==')
      file_path = line.gsub('== ', '').gsub(' ==', '')
      errors[file_path] = []
    elsif line.blank?
      file_path = nil
    else
      errors[file_path] << line if !file_path.nil?
    end
  end

  errors.each do |file_path, lines|
    it file_path do
      lines.should be_empty, lines.join("\n")
    end
  end
end
