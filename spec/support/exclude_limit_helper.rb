# frozen_string_literal: true

require 'tmpdir'

module ExcludeLimitHelper
  # Reads exclude_limit values from the tmp files written by ExcludeLimit.
  # Returns a hash like { 'Max' => 81 } or nil if no values were written.
  def read_exclude_limit(cop, parameter_name = nil)
    if parameter_name
      read_exclude_limit(cop)[parameter_name]
    else
      RuboCop::ExcludeLimit.read_limits(cop.class.badge.to_s)
    end
  end
end

RSpec.shared_context 'with exclude limit tracking' do
  include ExcludeLimitHelper

  around do |example|
    Dir.mktmpdir('rubocop-exclude-limit') do |dir|
      RuboCop::ExcludeLimit.tmp_dir = Pathname.new(dir)
      example.run
    ensure
      RuboCop::ExcludeLimit.tmp_dir = nil
    end
  end
end
