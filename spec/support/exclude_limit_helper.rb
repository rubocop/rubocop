# frozen_string_literal: true

module ExcludeLimitHelper
  # Reads exclude_limit values from config_to_allow_offenses.
  # Returns a hash like { 'Max' => 81 } or nil if no values were written.
  def read_exclude_limit(cop, parameter_name = nil)
    if parameter_name
      read_exclude_limit(cop)[parameter_name]
    else
      cop.config_to_allow_offenses.fetch(:exclude_limit, {})
    end
  end
end

RSpec.shared_context 'with exclude limit tracking' do
  include ExcludeLimitHelper
end
